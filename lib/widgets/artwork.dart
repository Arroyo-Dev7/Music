import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:on_audio_query_forked/on_audio_query.dart';

import '../utils/song_colors.dart';

/// Carátula de una canción. Si no tiene, muestra un degradado único por canción.
class Artwork extends StatelessWidget {
  const Artwork({
    super.key,
    required this.id,
    required this.width,
    required this.height,
    this.radius = 14,
    this.pixelSize = 300,
  });

  const Artwork.square({
    super.key,
    required this.id,
    required double size,
    this.radius = 14,
    this.pixelSize = 300,
  })  : width = size,
        height = size;

  final int id;
  final double width;
  final double height;
  final double radius;

  /// Resolución con la que se pide la imagen (más alto = más nítida).
  final int pixelSize;

  @override
  Widget build(BuildContext context) {
    final colors = ambientColors(id);

    return QueryArtworkWidget(
      id: id,
      type: ArtworkType.AUDIO,
      size: pixelSize,
      quality: 100,
      artworkWidth: width,
      artworkHeight: height,
      artworkFit: BoxFit.cover,
      artworkBorder: BorderRadius.circular(radius),
      nullArtworkWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.music_note_rounded,
            color: Colors.white54,
            size: math.min(width, height) * 0.4,
          ),
        ),
      ),
    );
  }
}
