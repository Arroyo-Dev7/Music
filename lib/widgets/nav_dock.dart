import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/perf_flags.dart';
import '../utils/scroll_perf.dart';
import 'dock_inset.dart';
import 'mini_player.dart';

/// Mini reproductor + barra de sala. El indicador de oro sigue el gesto.
class NavDock extends StatelessWidget {
  const NavDock({
    super.key,
    required this.services,
    required this.position,
    required this.onSelect,
  });

  final AppServices services;
  final ValueListenable<double> position;
  final ValueChanged<int> onSelect;

  static const _items = [
    _NavData('Archivo', Icons.graphic_eq_rounded, Icons.graphic_eq_rounded),
    _NavData(
      'Guardadas',
      Icons.favorite_border_rounded,
      Icons.favorite_rounded,
    ),
    _NavData('Listas', Icons.library_music_outlined, Icons.library_music_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(services: services),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: _Glass(
                child: Container(
                  height: kNavBlockHeight - 12,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.cardHigh.withValues(
                      alpha: kGlassBlur ? 0.78 : 0.96,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final itemW = c.maxWidth / _items.length;
                      return ValueListenableBuilder<double>(
                        valueListenable: position,
                        builder: (context, pos, _) {
                          final clamped = pos.clamp(0.0, _items.length - 1.0);
                          return Stack(
                            children: [
                              Positioned(
                                left: clamped * itemW,
                                top: 0,
                                bottom: 0,
                                width: itemW,
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  for (var i = 0; i < _items.length; i++)
                                    SizedBox(
                                      width: itemW,
                                      child: _NavItem(
                                        data: _items[i],
                                        closeness: (1 - (pos - i).abs()).clamp(
                                          0.0,
                                          1.0,
                                        ),
                                        onTap: () => onSelect(i),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kGlassBlur) return child;
    return ValueListenableBuilder<bool>(
      valueListenable: ScrollPerf.active,
      child: child,
      builder: (context, scrolling, child) {
        if (scrolling) return child!;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: kGlassSigma, sigmaY: kGlassSigma),
          child: child,
        );
      },
    );
  }
}

class _NavData {
  const _NavData(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.closeness,
    required this.onTap,
  });

  final _NavData data;
  final double closeness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(AppColors.textMuted, AppColors.ink, closeness)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              closeness > 0.5 ? data.activeIcon : data.icon,
              size: 20,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              data.label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 10.5,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
