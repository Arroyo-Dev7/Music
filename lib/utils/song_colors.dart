import 'package:flutter/material.dart';

/// Par de colores único por canción: se usa en fondos y carátulas vacías.
List<Color> ambientColors(int id) {
  final hue = (id * 47) % 360;
  return [
    HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.38).toColor(),
    HSLColor.fromAHSL(1, ((hue + 40) % 360).toDouble(), 0.6, 0.20).toColor(),
  ];
}
