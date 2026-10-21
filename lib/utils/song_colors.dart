import 'package:flutter/material.dart';

/// Paleta nocturna acotada: ámbar, terracota, vino y teal apagado.
/// Cada canción elige un par, pero todo sigue oliendo a la misma sala.
List<Color> ambientColors(int id) {
  const hues = [32.0, 18.0, 8.0, 350.0, 28.0, 195.0];
  final hue = hues[id.abs() % hues.length];
  final shift = (id.abs() % 11) * 1.4;
  return [
    HSLColor.fromAHSL(1, (hue + shift) % 360, 0.38, 0.30).toColor(),
    HSLColor.fromAHSL(1, (hue + 18 + shift) % 360, 0.32, 0.14).toColor(),
  ];
}
