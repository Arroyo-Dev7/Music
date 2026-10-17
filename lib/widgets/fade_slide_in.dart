import 'package:flutter/material.dart';

/// Entrada suave (aparece y sube) para los primeros elementos de una lista.
/// Cada elemento tarda un poco más que el anterior, lo que crea efecto cascada.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (index > 9) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 28),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
