import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/library_result.dart';
import 'permission_service.dart';

/// Lee las canciones del dispositivo y las mantiene en memoria para que
/// favoritos y listas puedan buscarlas por ID.
class LibraryService {
  LibraryService({PermissionService permissions = const PermissionService()})
    : _permissions = permissions;

  final PermissionService _permissions;
  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// Audios más cortos que esto (tonos, notificaciones) se descartan.
  static const int _minDurationMs = 30000;

  List<SongModel> _songs = const [];
  Map<int, SongModel> _byId = const {};

  List<SongModel> get songs => _songs;

  /// Convierte IDs guardados en canciones. Ignora las que ya no existen.
  List<SongModel> songsFor(Iterable<int> ids) =>
      ids.map((id) => _byId[id]).whereType<SongModel>().toList();

  Future<LibraryResult> loadSongs() async {
    try {
      final status = await _permissions.requestAudio();
      if (status.isPermanentlyDenied) {
        return const LibraryResult(LibraryStatus.permanentlyDenied);
      }
      if (!status.isGranted) {
        return const LibraryResult(LibraryStatus.denied);
      }

      // El plugin tiene su propia comprobación interna de permisos.
      var pluginOk = await _audioQuery.permissionsStatus().timeout(
        const Duration(seconds: 10),
      );
      if (!pluginOk) {
        pluginOk = await _audioQuery.permissionsRequest().timeout(
          const Duration(seconds: 15),
        );
      }
      if (!pluginOk) {
        return const LibraryResult(LibraryStatus.error);
      }

      final all = await _audioQuery
          .querySongs(
            sortType: SongSortType.TITLE,
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true,
          )
          .timeout(const Duration(seconds: 30));

      final songs = all
          .where(
            (s) =>
                (s.isMusic ?? false) &&
                (s.duration ?? 0) > _minDurationMs &&
                s.uri != null,
          )
          .toList();

      _songs = songs;
      _byId = {for (final s in songs) s.id: s};

      return LibraryResult(
        songs.isEmpty ? LibraryStatus.empty : LibraryStatus.ready,
        songs,
      );
    } on TimeoutException {
      debugPrint('Tiempo de espera agotado leyendo canciones');
      return const LibraryResult(LibraryStatus.error);
    } catch (e, st) {
      debugPrint('Error cargando biblioteca: $e\n$st');
      return const LibraryResult(LibraryStatus.error);
    }
  }
}
