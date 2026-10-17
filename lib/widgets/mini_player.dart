import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart' show MediaItem;

import '../screens/now_playing_screen.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/perf_flags.dart';
import '../utils/routes.dart';
import '../utils/song_colors.dart';
import 'artwork.dart';
import 'gradient_play_button.dart';

/// Mini player premium con composición elegante y feedback claro.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MediaItem?>(
      valueListenable: services.player.currentItem,
      builder: (context, item, _) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomCenter,
          child: item == null
              ? const SizedBox.shrink()
              : _MiniCard(item: item, services: services),
        );
      },
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.item, required this.services});

  final MediaItem item;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final player = services.player;
    final songId = int.tryParse(item.id) ?? 0;
    final colors = ambientColors(songId);

    final content = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10, width: 0.6),
        boxShadow: AppColors.cardShadow,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colors[0].withValues(alpha: 0.72),
            AppColors.cardHigh,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 13,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Artwork.square(
                        id: songId,
                        size: 48,
                        radius: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ) ??
                              const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.artist ?? 'Artista desconocido',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: player.playing,
                    builder: (context, playing, _) => GradientPlayButton(
                      size: 46,
                      playing: playing,
                      onPressed: playing ? player.pause : player.play,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded),
                    color: AppColors.textPrimary,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      player.next();
                    },
                  ),
                ],
              ),
            ),
            _ProgressLine(services: services),
          ],
        ),
      ),
    );

    final card = kGlassBlur
        ? ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10, width: 0.6),
                  color: Colors.white.withValues(alpha: 0.02),
                ),
                child: content,
              ),
            ),
          )
        : content;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        slideUpRoute((_) => NowPlayingScreen(services: services)),
      ),
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
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: card,
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final player = services.player;
    return RepaintBoundary(
      child: ValueListenableBuilder<Duration?>(
        valueListenable: player.duration,
        builder: (context, durationValue, _) {
          final total = durationValue ?? Duration.zero;
          return StreamBuilder<Duration>(
            stream: player.miniPositionStream,
            initialData: player.position,
            builder: (context, positionSnap) {
              final position = positionSnap.data ?? Duration.zero;
              final value = total.inMilliseconds == 0
                  ? 0.0
                  : (position.inMilliseconds / total.inMilliseconds)
                          .clamp(0.0, 1.0);
              return LinearProgressIndicator(
                value: value,
                minHeight: 3,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              );
            },
          );
        },
      ),
    );
  }
}

// Reuse existing perf flags if present.
// We intentionally keep the interpolation and blur affordable.















































































































































































































































"}]}  Co***assistant to=functions.push_files  <>