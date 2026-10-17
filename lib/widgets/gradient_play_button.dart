import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Botón circular de play/pausa con degradado y brillo.
class GradientPlayButton extends StatelessWidget {
  const GradientPlayButton({
    super.key,
    required this.playing,
    required this.onPressed,
    this.size = 72,
  });

  final bool playing;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.accentGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.45),
            blurRadius: size * 0.4,
            spreadRadius: -2,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                key: ValueKey(playing),
                size: size * 0.52,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
