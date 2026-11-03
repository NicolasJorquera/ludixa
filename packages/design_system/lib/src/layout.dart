import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Reglas de adaptación de la ficha UX (tamaños y texto al 200 %).
abstract final class LudixaLayout {
  /// Ancho compacto (< 360 dp): márgenes menores y listas en vez de grillas.
  static bool compact(BuildContext context) => MediaQuery.sizeOf(context).width < 360;

  /// Texto grande (desde 150 %): los menús fluyen a una columna y los
  /// botones pasan debajo de su texto.
  static bool largeText(BuildContext context) => _scale(context) >= 1.5;

  /// Ancho máximo del contenido en tablets y plegables (ficha UX: < 560 dp,
  /// centrado).
  static const double maxContentWidth = 560;

  /// Margen lateral de una pantalla: 12 dp en compacto, [base] en estándar y
  /// el que centra el contenido en [maxContentWidth] en pantallas anchas.
  static double gutter(BuildContext context, {double base = 16}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return math.min(base, 12);
    return math.max(base, (width - maxContentWidth) / 2);
  }

  /// Relleno de una lista de pantalla completa con [gutter] a los lados.
  static EdgeInsets page(BuildContext context, {double top = 0, double bottom = 24}) {
    final side = gutter(context);
    return EdgeInsets.fromLTRB(side, top, side, bottom);
  }

  /// Relleno lateral extra para listas de filas que ya traen 16 dp propios.
  static EdgeInsets rows(BuildContext context, {double bottom = 24}) =>
      EdgeInsets.fromLTRB(math.max(0, gutter(context) - 16), 0, math.max(0, gutter(context) - 16), bottom);

  /// Columnas de una grilla de tarjetas: las que caben en [available] con un
  /// ancho mínimo de [minWidth] que crece con el texto.
  static int columns(BuildContext context, double available, {required double minWidth, int max = 3}) =>
      (available / (minWidth * _scale(context))).floor().clamp(1, max);

  static double _scale(BuildContext context) => MediaQuery.textScalerOf(context).scale(10) / 10;
}

/// Un texto y su dato en la misma línea cuando caben; si no, el dato baja a
/// la línea siguiente en vez de partir palabras.
class LudixaSplitLine extends StatelessWidget {
  const LudixaSplitLine({super.key, required this.start, required this.end});

  final Widget start;
  final Widget end;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 8,
    runSpacing: 2,
    children: [start, end],
  );
}
