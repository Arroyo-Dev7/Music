import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../services/app_services.dart';
import '../utils/playback_actions.dart';
import 'fade_slide_in.dart';
import 'song_tile.dart';

/// Lista de canciones para usar dentro de un CustomScrollView.
/// Al tocar una, la cola del reproductor pasa a ser esta lista.
class SliverSongList extends StatelessWidget {
  const SliverSongList({
    super.key,
    required this.songs,
    required this.services,
    this.onRemove,
  });

  final List<SongModel> songs;
  final AppServices services;
  final void Function(SongModel song)? onRemove;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: songs.length,
      itemBuilder: (context, i) {
        final song = songs[i];
        return FadeSlideIn(
          key: ValueKey(song.id),
          index: i,
          child: SongTile(
            song: song,
            services: services,
            onTap: () => playSongs(context, services, songs, i),
            onRemove: onRemove == null ? null : () => onRemove!(song),
          ),
        );
      },
    );
  }
}
