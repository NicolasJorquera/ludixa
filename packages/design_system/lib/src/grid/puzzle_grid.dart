import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Dimensiones de una grilla de puzzle.
@immutable
final class GridDimensions {
  const GridDimensions({required this.columns, required this.rows});

  final int columns;
  final int rows;

  int get cellCount => columns * rows;

  int indexOf(int row, int column) => row * columns + column;

  int rowOf(int index) => index ~/ columns;

  int columnOf(int index) => index % columns;
}

/// Grilla común a los tres juegos.
///
/// - Calcula el tamaño de celda a partir del ancho disponible (sin pasar de
///   [maxCellExtent]), así que no depende de la escala de texto.
/// - Un único detector de gestos traduce posiciones a índices: tocar, mantener
///   pulsado y arrastrar (selección de la Sopa), sin un detector por celda.
/// - Cada celda tiene su propio nodo semántico con la etiqueta que da
///   [semanticLabelFor] y las acciones de tocar y mantener pulsado, para que
///   TalkBack pueda jugar.
class PuzzleGrid extends StatelessWidget {
  const PuzzleGrid({
    super.key,
    required this.dimensions,
    required this.cellBuilder,
    required this.semanticLabelFor,
    this.onCellTap,
    this.onCellLongPress,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.gap = 0,
    this.maxCellExtent = 64,
    this.fixedCellExtent,
    this.semanticLabel,
    this.longPressDuration = kLongPressTimeout,
  });

  final GridDimensions dimensions;

  /// Contenido de la celda [index], dibujado en un cuadrado de [extent].
  final Widget Function(BuildContext context, int index, double extent) cellBuilder;

  /// Etiqueta traducida de la celda ("Fila 5, columna 5, vacía").
  final String Function(int index) semanticLabelFor;

  final ValueChanged<int>? onCellTap;
  final ValueChanged<int>? onCellLongPress;

  /// Arrastre: celda donde empieza, cada celda nueva que se cruza y el final.
  final ValueChanged<int>? onDragStart;
  final ValueChanged<int>? onDragUpdate;
  final VoidCallback? onDragEnd;

  /// Separación entre celdas (el Buscaminas usa 3).
  final double gap;
  final double maxCellExtent;

  /// Tamaño de celda fijo. Lo usa [ZoomableBoard] para grillas más grandes que
  /// la pantalla.
  final double? fixedCellExtent;

  /// Descripción de la grilla completa ("Tablero de Sudoku").
  final String? semanticLabel;

  /// Identificador del nodo del tablero (en Android, su resource-id). Lo usan
  /// las pruebas de accesibilidad para medir sus celdas aparte.
  static const semanticsIdentifier = 'puzzle-grid';

  /// Cuánto hay que mantener pulsado (el Buscaminas la deja ajustar).
  final Duration longPressDuration;

  /// Tamaño de celda que ocupa todo [width].
  static double fitCellExtent(double width, GridDimensions dimensions, {double gap = 0}) =>
      (width - gap * (dimensions.columns - 1)) / dimensions.columns;

  @override
  Widget build(BuildContext context) {
    // Los dígitos y letras de la grilla escalan hasta el 130 % (ficha UX):
    // más allá no caben en su celda y se recomienda el zoom.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final extent =
              fixedCellExtent ??
              math.min(maxCellExtent, fitCellExtent(constraints.maxWidth, dimensions, gap: gap)).floorToDouble();
          final width = extent * dimensions.columns + gap * (dimensions.columns - 1);
          final height = extent * dimensions.rows + gap * (dimensions.rows - 1);
          final pitch = extent + gap;

          int? indexAt(Offset local) {
            if (local.dx < 0 || local.dy < 0 || local.dx >= width || local.dy >= height) return null;
            final column = (local.dx / pitch).floor();
            final row = (local.dy / pitch).floor();
            // Un toque en la separación entre celdas no cuenta.
            if (local.dx - column * pitch > extent || local.dy - row * pitch > extent) return null;
            return dimensions.indexOf(row, column);
          }

          // Centrada si sobra ancho (cuando la celda llega a maxCellExtent).
          return Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Semantics(
              container: true,
              label: semanticLabel,
              identifier: PuzzleGrid.semanticsIdentifier,
              child: _GridGestures(
                indexAt: indexAt,
                onTap: onCellTap,
                onLongPress: onCellLongPress,
                onDragStart: onDragStart,
                onDragUpdate: onDragUpdate,
                onDragEnd: onDragEnd,
                longPressDuration: longPressDuration,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      for (var i = 0; i < dimensions.cellCount; i++)
                        Positioned(
                          left: dimensions.columnOf(i) * pitch,
                          top: dimensions.rowOf(i) * pitch,
                          width: extent,
                          height: extent,
                          // Nodo propio por celda aunque no tenga acciones (selección
                          // por arrastre): así el lector la recorre una a una. La
                          // etiqueta describe la celda entera: el contenido no se
                          // anuncia aparte (si no, "L" se leería dos veces).
                          child: Semantics(
                            container: true,
                            excludeSemantics: true,
                            label: semanticLabelFor(i),
                            button: onCellTap != null,
                            onTap: onCellTap == null ? null : () => onCellTap!(i),
                            onLongPress: onCellLongPress == null ? null : () => onCellLongPress!(i),
                            child: cellBuilder(context, i, extent),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GridGestures extends StatefulWidget {
  const _GridGestures({
    required this.indexAt,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.longPressDuration = kLongPressTimeout,
  });

  final int? Function(Offset local) indexAt;
  final Duration longPressDuration;
  final Widget child;
  final ValueChanged<int>? onTap;
  final ValueChanged<int>? onLongPress;
  final ValueChanged<int>? onDragStart;
  final ValueChanged<int>? onDragUpdate;
  final VoidCallback? onDragEnd;

  @override
  State<_GridGestures> createState() => _GridGesturesState();
}

class _GridGesturesState extends State<_GridGestures> {
  int? _lastDragIndex;

  @override
  Widget build(BuildContext context) {
    final dragging = widget.onDragStart != null || widget.onDragUpdate != null;
    // RawGestureDetector para poder fijar la duración de la pulsación larga.
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      gestures: {
        if (widget.onTap != null)
          TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            TapGestureRecognizer.new,
            (r) => r.onTapUp = (details) {
              final index = widget.indexAt(details.localPosition);
              if (index != null) widget.onTap!(index);
            },
          ),
        if (widget.onLongPress != null)
          LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            () => LongPressGestureRecognizer(duration: widget.longPressDuration),
            (r) => r.onLongPressStart = (details) {
              final index = widget.indexAt(details.localPosition);
              if (index != null) widget.onLongPress!(index);
            },
          ),
        // Pan en lugar de drag vertical/horizontal: la selección de la Sopa va en 8 direcciones.
        if (dragging)
          PanGestureRecognizer: GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
            () => PanGestureRecognizer()..dragStartBehavior = DragStartBehavior.down,
            (r) => r
              ..onStart = _panStart
              ..onUpdate = _panUpdate
              ..onEnd = ((_) => _panEnd())
              ..onCancel = _panEnd,
          ),
      },
      child: widget.child,
    );
  }

  void _panStart(DragStartDetails details) {
    final index = widget.indexAt(details.localPosition);
    _lastDragIndex = index;
    if (index != null) widget.onDragStart?.call(index);
  }

  void _panUpdate(DragUpdateDetails details) {
    final index = widget.indexAt(details.localPosition);
    if (index == null || index == _lastDragIndex) return;
    _lastDragIndex = index;
    widget.onDragUpdate?.call(index);
  }

  void _panEnd() {
    if (_lastDragIndex == null) return;
    _lastDragIndex = null;
    widget.onDragEnd?.call();
  }
}
