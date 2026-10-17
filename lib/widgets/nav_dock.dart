import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/perf_flags.dart';
import 'dock_inset.dart';
import 'mini_player.dart';

/// Zona inferior flotante: mini reproductor + barra de navegación de vidrio.
/// La pastilla de color se desliza siguiendo el gesto de las páginas.
class NavDock extends StatelessWidget {
  const NavDock({
    super.key,
    required this.services,
    required this.position,
    required this.onSelect,
  });

  final AppServices services;

  /// Posición fraccionaria de la página (0.0, 0.4, 1.0, ...).
  final ValueListenable<double> position;
  final ValueChanged<int> onSelect;

  static const _items = [
    _NavData('Canciones', Icons.music_note_outlined, Icons.music_note_rounded),
    _NavData(
      'Favoritas',
      Icons.favorite_border_rounded,
      Icons.favorite_rounded,
    ),
    _NavData('Listas', Icons.queue_music_outlined, Icons.queue_music_rounded),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: _Glass(
                child: Container(
                  height: kNavBlockHeight - 12,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.cardHigh.withValues(
                      alpha: kGlassBlur ? 0.72 : 0.94,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white12),
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
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.accentGradient,
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accent.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
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

/// Panel de vidrio. Con [kGlassBlur] desactivado no aplica desenfoque.
/// OJO: no envolver en RepaintBoundary; BackdropFilter necesita ver lo que hay
/// pintado detrás en la misma capa.
class _Glass extends StatelessWidget {
  const _Glass({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kGlassBlur) return child;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: kGlassSigma, sigmaY: kGlassSigma),
      child: child,
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

  /// 1.0 = pestaña activa, 0.0 = lejos de ella.
  final double closeness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(AppColors.textMuted, Colors.white, closeness)!;

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
              size: 22,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 11,
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
