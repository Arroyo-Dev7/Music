import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../services/app_services.dart';

/// Reproduce [songs] desde [index] y avisa con un SnackBar si algo falla.
Future<void> playSongs(
  BuildContext context,
  AppServices services,
  List<SongModel> songs,
  int index,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await services.player.playQueue(songs, index);
  } catch (e) {
    debugPrint('Error al reproducir: $e');
    messenger.showSnackBar(
      const SnackBar(content: Text('No se pudo reproducir esta canción.')),
    );
  }
}

/// Reproduce [songs] en orden aleatorio.
Future<void> shuffleSongs(
  BuildContext context,
  AppServices services,
  List<SongModel> songs,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await services.player.playShuffled(songs);
  } catch (e) {
    debugPrint('Error al reproducir: $e');
    messenger.showSnackBar(
      const SnackBar(content: Text('No se pudo reproducir esta lista.')),
    );
  }
}
