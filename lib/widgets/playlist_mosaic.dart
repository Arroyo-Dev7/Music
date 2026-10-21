import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../theme/app_theme.dart';
import 'artwork.dart';

/// Portada de una lista: mosaico 2x2 con las carátulas de sus canciones.
/// Con menos de 4 canciones muestra la carátula de la primera.
class PlaylistMosaic extends StatelessWidget {
  const PlaylistMosaic({super.key, required this.songs, this.radius = 16});

  final List<SongModel> songs;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final covers = songs.take(4).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: covers.isEmpty
          ? Container(
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient.scale(0.6),
              ),
              child: const Center(
                child: Icon(
                  Icons.queue_music_rounded,
                  color: Colors.white70,
                  size: 48,
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, c) {
                if (covers.length < 4) {
                  return Artwork(
                    id: covers.first.id,
                    width: c.maxWidth,
                    height: c.maxHeight,
                    radius: 0,
                    pixelSize: 256,
                    fadeIn: false,
                  );
                }
                final w = c.maxWidth / 2;
                final h = c.maxHeight / 2;
                Widget cell(SongModel s) => Artwork(
                      id: s.id,
                      width: w,
                      height: h,
                      radius: 0,
                      pixelSize: 192,
                      fadeIn: false,
                    );
                return Column(
                  children: [
                    Row(children: [cell(covers[0]), cell(covers[1])]),
                    Row(children: [cell(covers[2]), cell(covers[3])]),
                  ],
                );
              },
            ),
    );
  }
}
