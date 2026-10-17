import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist.dart';

/// Crea, edita y guarda las listas de reproducción en el teléfono.
class PlaylistService extends ChangeNotifier {
  PlaylistService(this._prefs) {
    final raw = _prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      _playlists.addAll(
        list.map((e) => Playlist.fromJson(e as Map<String, dynamic>)),
      );
    } catch (e) {
      debugPrint('No se pudieron leer las listas guardadas: $e');
    }
  }

  static const _key = 'playlists';

  final SharedPreferences _prefs;
  final List<Playlist> _playlists = [];

  List<Playlist> get playlists => List.unmodifiable(_playlists);

  Playlist? byId(String id) {
    for (final p in _playlists) {
      if (p.id == id) return p;
    }
    return null;
  }

  Playlist create(String name) {
    final playlist = Playlist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
    );
    _playlists.add(playlist);
    _commit();
    return playlist;
  }

  void rename(String id, String name) {
    final playlist = byId(id);
    if (playlist == null) return;
    playlist.name = name.trim();
    _commit();
  }

  void delete(String id) {
    _playlists.removeWhere((p) => p.id == id);
    _commit();
  }

  /// Devuelve false si la canción ya estaba en la lista.
  bool addSong(String playlistId, int songId) {
    final playlist = byId(playlistId);
    if (playlist == null || playlist.songIds.contains(songId)) return false;
    playlist.songIds.add(songId);
    _commit();
    return true;
  }

  void removeSong(String playlistId, int songId) {
    byId(playlistId)?.songIds.remove(songId);
    _commit();
  }

  void _commit() {
    unawaited(
      _prefs.setString(
        _key,
        jsonEncode(_playlists.map((p) => p.toJson()).toList()),
      ),
    );
    notifyListeners();
  }
}
