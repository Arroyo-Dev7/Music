import 'package:flutter/widgets.dart';

/// Alto de la barra de navegación flotante (incluye su margen inferior).
const double kNavBlockHeight = 76;

/// Alto del mini reproductor flotante (incluye su margen inferior).
const double kMiniBlockHeight = 77;

/// Espacio que las pestañas deben dejar abajo para que el contenido
/// no quede tapado por la barra flotante. Se anima solo al aparecer el mini reproductor.
class DockInset extends InheritedWidget {
  const DockInset({super.key, required this.bottom, required super.child});

  final double bottom;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DockInset>()?.bottom ?? 24;

  @override
  bool updateShouldNotify(DockInset oldWidget) => bottom != oldWidget.bottom;
}
