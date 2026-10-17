import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart'
    show MediaItem;

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/song_colors.dart';
import '../widgets/add_to_playlist_sheet.dart';
import '../widgets/artwork.dart';
import '../widgets/playback_controls.dart';
import '../widgets/seek_bar.dart';

/// Pantalla de reproducción completa con fondo ambiental (carátula difuminada).
/// Desliza hacia abajo para cerrar; desliza la carátula para cambiar de canción.
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<MediaItem?>(
        stream: services.player.currentItemStream,
        builder: (context, snapshot) {
          final item = snapshot.data;
          if (item == null) return const _NothingPlaying();
          return _Body(item: item, services: services);
        },
      ),
    );
  }
}

class _NothingPlaying extends StatelessWidget {
  const _NothingPlaying();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              iconSize: 32,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const Expanded(child: Center(child: Text('No hay nada sonando.'))),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.item, required this.services});

  final MediaItem item;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final player = services.player;
    final songId = int.tryParse(item.id) ?? -1;
    final colors = ambientColors(songId);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 700) {
          Navigator.of(context).maybePop();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _AmbientBackground(songId: songId),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        iconSize: 32,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'REPRODUCIENDO',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Agregar a una lista',
                        icon: const Icon(Icons.playlist_add_rounded),
                        onPressed: () =>
                            showAddToPlaylistSheet(context, services, songId),
                      ),
                    ],
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final side = math.max(
                          120.0,
                          math.min(c.maxWidth, c.maxHeight) - 16,
                        );
                        return Center(
                          child: StreamBuilder<bool>(
                            stream: player.playingStream,
                            initialData: false,
                            builder: (context, snap) {
                              final playing = snap.data ?? false;
                              return AnimatedScale(
                                scale: playing ? 1 : 0.88,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutCubic,
                                child: GestureDetector(
                                  onHorizontalDragEnd: (details) {
                                    final v = details.primaryVelocity ?? 0;
                                    if (v < -300) {
                                      HapticFeedback.selectionClick();
                                      player.next();
                                    } else if (v > 300) {
                                      HapticFeedback.selectionClick();
                                      player.previous();
                                    }
                                  },
                                  child: Container(
                                    width: side,
                                    height: side,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors[0]
                                              .withValues(alpha: 0.55),
                                          blurRadius: 50,
                                          spreadRadius: -8,
                                          offset: const Offset(0, 24),
                                        ),
                                      ],
                                    ),
                                    child: Artwork.square(
                                      id: songId,
                                      size: side,
                                      radius: 28,
                                      pixelSize: 1000,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.artist ?? 'Artista desconocido',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListenableBuilder(
                        listenable: services.favorites,
                        builder: (context, _) {
                          final isFavorite =
                              services.favorites.isFavorite(songId);
                          return IconButton(
                            tooltip: isFavorite
                                ? 'Quitar de favoritas'
                                : 'Marcar como favorita',
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              services.favorites.toggle(songId);
                            },
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(isFavorite),
                                size: 30,
                                color: isFavorite
                                    ? AppColors.accentAlt
                                    : Colors.white70,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SeekBar(player: player),
                  const SizedBox(height: 8),
                  PlaybackControls(player: player),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fondo: la carátula muy difuminada sobre un degradado. Cambia con fundido.
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground({required this.songId});

  final int songId;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final colors = ambientColors(songId);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Stack(
        key: ValueKey(songId),
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
          ),
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Artwork(
              id: songId,
              width: size.width,
              height: size.height,
              radius: 0,
              pixelSize: 400,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  AppColors.background.withValues(alpha: 0.93),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
