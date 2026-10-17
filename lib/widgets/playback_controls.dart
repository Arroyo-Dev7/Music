import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';

import '../models/repeat_mode.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import 'gradient_play_button.dart';

/// Aleatorio, anterior, play/pausa, siguiente y repetir.
class PlaybackControls extends StatelessWidget {
  const PlaybackControls({super.key, required this.player});

  final PlayerService player;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StreamBuilder<bool>(
          stream: player.shuffleStream,
          initialData: false,
          builder: (context, snap) {
            final on = snap.data ?? false;
            return _ToggleIcon(
              icon: Icons.shuffle_rounded,
              active: on,
              tooltip: on ? 'Aleatorio: activado' : 'Aleatorio: desactivado',
              onTap: player.toggleShuffle,
            );
          },
        ),
        _SkipButton(icon: Icons.skip_previous_rounded, onTap: player.previous),
        StreamBuilder<bool>(
          stream: player.playingStream,
          initialData: false,
          builder: (context, snap) {
            final playing = snap.data ?? false;
            return GradientPlayButton(
              size: 76,
              playing: playing,
              onPressed: playing ? player.pause : player.play,
            );
          },
        ),
        _SkipButton(icon: Icons.skip_next_rounded, onTap: player.next),
        StreamBuilder<RepeatMode>(
          stream: player.repeatModeStream,
          initialData: RepeatMode.off,
          builder: (context, snap) {
            final mode = snap.data ?? RepeatMode.off;
            return _ToggleIcon(
              icon: mode == RepeatMode.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              active: mode != RepeatMode.off,
              tooltip: switch (mode) {
                RepeatMode.off => 'Repetir: desactivado',
                RepeatMode.all => 'Repetir todas',
                RepeatMode.one => 'Repetir esta canción',
              },
              onTap: player.cycleRepeatMode,
            );
          },
        ),
      ],
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.icon, required this.onTap});

  final IconData icon;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 42,
      color: Colors.white,
      icon: Icon(icon),
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  const _ToggleIcon({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final String tooltip;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: active ? AppColors.accent : Colors.white70,
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.accent : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
