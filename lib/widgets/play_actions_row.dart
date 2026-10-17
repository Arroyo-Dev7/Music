import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pressable.dart';

/// Par de botones grandes: "Reproducir" y "Aleatorio".
class PlayActionsRow extends StatelessWidget {
  const PlayActionsRow({
    super.key,
    required this.onPlay,
    required this.onShuffle,
  });

  final VoidCallback onPlay;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _Pill(
              label: 'Reproducir',
              icon: Icons.play_arrow_rounded,
              filled: true,
              onTap: onPlay,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Pill(
              label: 'Aleatorio',
              icon: Icons.shuffle_rounded,
              filled: false,
              onTap: onShuffle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: filled ? AppColors.accentGradient : null,
          color: filled ? null : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(26),
          border: filled ? null : Border.all(color: Colors.white12),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
