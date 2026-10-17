import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../models/repeat_mode.dart';
import '../utils/song_extensions.dart';

/// Envuelve el reproductor. Las pantallas y widgets solo hablan con esta
/// clase, así que si algún día cambias de librería de audio, tocas un archivo.
///
/// Rendimiento: el estado que casi toda la interfaz necesita (canción actual,
/// reproduciendo, aleatorio, repetir, duración) se escucha UNA sola vez aquí y
/// se expone como [ValueListenable]. Así los widgets no abren cada uno su
/// propio StreamBuilder y siempre tienen un valor inicial correcto (sin el
/// parpadeo de "sin datos" del primer fotograma).
class PlayerService {
  PlayerService() {
    _shuffle.value = _player.shuffleModeEnabled;
    _repeat.value = _toRepeatMode(_player.loopMode);
    _subs.addAll([
      _player.sequenceStateStream.listen(_onSequenceState),
      _player.playingStream.listen((v) => _playing.value = v),
      _player.durationStream.listen((d) => _duration.value = d),
      _player.shuffleModeEnabledStream.listen((v) => _shuffle.value = v),
      _player.loopModeStream
          .listen((m) => _repeat.value = _toRepeatMode(m)),
    ]);
  }

  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<Object?>> _subs = [];

  /// IDs de la lista cargada ahora en el reproductor.
  List<int>? _loadedIds;

  // ---- Estado que la interfaz puede escuchar ----

  final ValueNotifier<MediaItem?> _currentItem = ValueNotifier(null);
  final ValueNotifier<int?> _currentSongId = ValueNotifier(null);
  final ValueNotifier<bool> _playing = ValueNotifier(false);
  final ValueNotifier<Duration?> _duration = ValueNotifier(null);
  final ValueNotifier<bool> _shuffle = ValueNotifier(false);
  final ValueNotifier<RepeatMode> _repeat = ValueNotifier(RepeatMode.off);

  /// Canción que suena ahora (null si no hay ninguna). Solo notifica cuando
  /// cambia la canción, no cuando cambian aleatorio/repetir.
  ValueListenable<MediaItem?> get currentItem => _currentItem;

  /// ID de la canción actual; solo notifica cuando cambia.
  ValueListenable<int?> get currentSongId => _currentSongId;

  ValueListenable<bool> get playing => _playing;
  ValueListenable<Duration?> get duration => _duration;
  ValueListenable<bool> get shuffleEnabled => _shuffle;
  ValueListenable<RepeatMode> get repeatMode => _repeat;

  /// Posición actual (para usarla como valor inicial de un StreamBuilder).
  Duration get position => _player.position;

  /// Posición a la frecuencia por defecto de just_audio (cada ~200 ms).
  /// Úsala solo en la pantalla de reproducción.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Posición con frecuencia reducida (≈2 actualizaciones por segundo) para
  /// la barrita del mini reproductor, que mide ~330 px y no necesita más.
  late final Stream<Duration> miniPositionStream = _player.createPositionStream(
    steps: 300,
    minPeriod: const Duration(milliseconds: 250),
    maxPeriod: const Duration(milliseconds: 500),
  );

  // ---- Acciones ----

  /// Reproduce la canción [index] de [songs] y sigue con las siguientes.
  Future<void> playQueue(List<SongModel> songs, int index) async {
    final ids = songs.map((s) => s.id).toList();
    if (_loadedIds != null && listEquals(_loadedIds, ids)) {
      await _player.seek(Duration.zero, index: index);
    } else {
      await _player.setAudioSources(
        songs.map(_toSource).toList(),
        initialIndex: index,
      );
      _loadedIds = ids;
      if (_player.shuffleModeEnabled) await _player.shuffle();
    }
    unawaited(_player.play());
  }

  /// Activa aleatorio y empieza por una canción al azar.
  Future<void> playShuffled(List<SongModel> songs) async {
    if (songs.isEmpty) return;
    await _player.shuffle();
    await _player.setShuffleModeEnabled(true);
    await playQueue(songs, Random().nextInt(songs.length));
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> next() => _player.seekToNext();
  Future<void> previous() => _player.seekToPrevious();
  Future<void> seek(Duration position) => _player.seek(position);

  /// Alterna: sin repetir → repetir todas → repetir una → sin repetir.
  Future<void> cycleRepeatMode() {
    final next = switch (_player.loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    return _player.setLoopMode(next);
  }

  Future<void> toggleShuffle() async {
    final enable = !_player.shuffleModeEnabled;
    if (enable) await _player.shuffle();
    await _player.setShuffleModeEnabled(enable);
  }

  Future<void> dispose() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    _currentItem.dispose();
    _currentSongId.dispose();
    _playing.dispose();
    _duration.dispose();
    _shuffle.dispose();
    _repeat.dispose();
    await _player.dispose();
  }

  // ---- Internos ----

  void _onSequenceState(SequenceState? state) {
    final tag = state?.currentSource?.tag;
    final item = tag is MediaItem ? tag : null;
    // sequenceStateStream también emite al cambiar aleatorio/repetir; solo
    // propagamos cuando de verdad cambió la canción.
    if (item?.id == _currentItem.value?.id) return;
    _currentItem.value = item;
    _currentSongId.value = item == null ? null : int.tryParse(item.id);
  }

  RepeatMode _toRepeatMode(LoopMode mode) => switch (mode) {
        LoopMode.off => RepeatMode.off,
        LoopMode.all => RepeatMode.all,
        LoopMode.one => RepeatMode.one,
      };

  AudioSource _toSource(SongModel s) {
    return AudioSource.uri(
      Uri.parse(s.uri!),
      tag: MediaItem(
        id: s.id.toString(),
        title: s.title,
        artist: s.artistName,
        album: s.album,
        artUri: s.albumId == null
            ? null
            : Uri.parse('content://media/external/audio/albumart/${s.albumId}'),
      ),
    );
  }
}
