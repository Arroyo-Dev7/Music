import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tres barras que "bailan" mientras suena la canción.
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

  double _height(double t, double phase) =>
      0.35 + 0.65 * ((math.sin(t + phase) + 1) / 2);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 * math.pi;
        final heights = [_height(t, 0), _height(t, 2), _height(t, 4)];
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final h in heights)
                Container(
                  width: widget.size * 0.18,
                  height: widget.size * h,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
