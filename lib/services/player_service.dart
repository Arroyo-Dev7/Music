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
class PlayerService {
  final AudioPlayer _player = AudioPlayer();

  /// IDs de la lista cargada ahora en el reproductor.
  List<int>? _loadedIds;

  // ---- Estado que la interfaz puede escuchar ----

  /// Canción que suena ahora (null si no hay ninguna).
  Stream<MediaItem?> get currentItemStream =>
      _player.sequenceStateStream.map<MediaItem?>((state) {
        final tag = state?.currentSource?.tag;
        return tag is MediaItem ? tag : null;
      });

  /// ID de la canción actual; solo emite cuando cambia.
  Stream<int?> get currentSongIdStream => currentItemStream
      .map<int?>((item) => item == null ? null : int.tryParse(item.id))
      .distinct();

  Stream<bool> get playingStream => _player.playingStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<bool> get shuffleStream => _player.shuffleModeEnabledStream;

  Stream<RepeatMode> get repeatModeStream =>
      _player.loopModeStream.map<RepeatMode>(_toRepeatMode);

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

  Future<void> dispose() => _player.dispose();

  // ---- Internos ----

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
