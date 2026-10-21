import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pressable.dart';

/// Par de acciones: un botón de oro y otro en contorno, sin pastillas genéricas.
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: _Action(
              label: 'Escuchar',
              icon: Icons.play_arrow_rounded,
              filled: true,
              onTap: onPlay,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: _Action(
              label: 'Mezclar',
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

class _Action extends StatelessWidget {
  const _Action({
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
    final fg = filled ? AppColors.ink : AppColors.cream;
    return Pressable(
      onTap: onTap,
      scale: 0.97,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: filled ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: filled ? null : Border.all(color: AppColors.hairline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
