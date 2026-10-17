import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tres barras que "bailan" mientras suena la canción.
///
/// Se dibujan con un CustomPainter ligado directamente a la animación: cada
/// fotograma solo se repinta (no se reconstruye ni se recalcula el layout),
/// y vive en su propia capa para no arrastrar a la tarjeta que la contiene.
class EqualizerBars extends StatefulWidget {
  const EqualizerBars({
    super.key,
    required this.animate,
    this.color = Colors.white,
    this.size = 20,
  });

  final bool animate;
  final Color color;
  final double size;

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(EqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _BarsPainter(animation: _controller, color: widget.color),
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.animation, required this.color})
      : super(repaint: animation);

  final Animation<double> animation;
  final Color color;

  static const _phases = [0.0, 2.0, 4.0];

  double _height(double t, double phase) =>
      0.35 + 0.65 * ((math.sin(t + phase) + 1) / 2);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * 2 * math.pi;
    final barW = size.width * 0.18;
    // Mismo reparto que Row(spaceEvenly): 4 huecos iguales para 3 barras.
    final gap = (size.width - barW * _phases.length) / (_phases.length + 1);
    final paint = Paint()..color = color;

    for (var i = 0; i < _phases.length; i++) {
      final h = size.height * _height(t, _phases[i]);
      final left = gap * (i + 1) + barW * i;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height - h, barW, h),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter oldDelegate) => oldDelegate.color != color;
}
