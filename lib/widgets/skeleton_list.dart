import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Esqueleto que "respira" mientras se carga la biblioteca (en vez de un spinner).
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key});

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = Color.lerp(
          AppColors.card,
          AppColors.cardHigh,
          Curves.easeInOut.transform(_controller.value),
        )!;

        Widget block(double w, double h, double r) => Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(r),
              ),
            );

        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.paddingOf(context).top + 28,
            16,
            0,
          ),
          children: [
            block(90, 12, 6),
            const SizedBox(height: 12),
            block(220, 34, 10),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(child: block(double.infinity, 52, 26)),
                const SizedBox(width: 12),
                Expanded(child: block(double.infinity, 52, 26)),
              ],
            ),
            const SizedBox(height: 22),
            for (var i = 0; i < 7; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    block(56, 56, 14),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          block(double.infinity, 14, 7),
                          const SizedBox(height: 8),
                          block(120, 11, 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
