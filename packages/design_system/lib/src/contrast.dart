import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Relación de contraste WCAG 2.x entre dos colores opacos (de 1 a 21).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Umbrales WCAG AA.
abstract final class ContrastLevel {
  /// Texto normal.
  static const text = 4.5;

  /// Texto grande (≥ 24 px, o ≥ 18,66 px en negrita), iconos y bordes de controles.
  static const large = 3.0;
}
