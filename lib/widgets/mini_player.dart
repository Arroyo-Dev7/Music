import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart'
    show MediaItem;

import '../screens/now_playing_screen.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import 'artwork.dart';
import 'gradient_play_button.dart';

/// Ficha compacta de lo que suena: carátula, título en serif y un hilo de oro.
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
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 8),
        decoration: BoxDecoration(
          color: AppColors.cardHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.hairline),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                child: Row(
                  children: [
                    Artwork.square(
                      id: songId,
                      size: 46,
                      radius: 10,
                      pixelSize: 128,
                      fadeIn: false,
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
                            style: const TextStyle(
                              fontFamily: AppFonts.display,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              height: 1.15,
                              color: AppColors.cream,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.artist ?? 'Artista desconocido',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppFonts.body,
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: player.playing,
                      builder: (context, playing, _) => GradientPlayButton(
                        size: 40,
                        playing: playing,
                        onPressed: playing ? player.pause : player.play,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      color: AppColors.cream,
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
                  : (position.inMilliseconds / total.inMilliseconds).clamp(
                      0.0,
                      1.0,
                    );
              return LinearProgressIndicator(
                value: value,
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              );
            },
          );
        },
      ),
    );
  }
}
