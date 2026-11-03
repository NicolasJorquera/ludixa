import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tablero más grande que la pantalla (Buscaminas Experto).
///
/// Empieza ajustado al ancho y admite pellizcar y arrastrar. [toggleZoom]
/// alterna entre "ajustar al ancho" y un zoom en el que las celdas miden al
/// menos [comfortableCellExtent]; la pantalla de juego lo conecta a un botón.
///
/// El doble toque viene desactivado: si estuviera activo, cada toque simple
/// en el tablero tendría que esperar ~300 ms para descartar que fuera doble, y
/// revelar celdas se sentiría lento.
class ZoomableBoard extends StatefulWidget {
  const ZoomableBoard({
    super.key,
    required this.boardSize,
    required this.cellExtent,
    required this.child,
    this.comfortableCellExtent = 36,
    this.maxScale = 3,
    this.enableDoubleTapZoom = false,
    this.panEnabled = true,
  });

  /// Tamaño del tablero a escala 1.
  final Size boardSize;

  /// Tamaño de celda a escala 1.
  final double cellExtent;
  final Widget child;
  final double comfortableCellExtent;
  final double maxScale;
  final bool enableDoubleTapZoom;

  /// Desactívalo cuando el arrastre sirve para jugar (selección de la Sopa).
  final bool panEnabled;

  /// Escala del zoom: al menos 1,6× y celdas cómodas.
  double get zoomedScale => math.min(maxScale, math.max(1.6, comfortableCellExtent / cellExtent));

  @override
  State<ZoomableBoard> createState() => ZoomableBoardState();
}

class ZoomableBoardState extends State<ZoomableBoard> with SingleTickerProviderStateMixin {
  final _transform = TransformationController();
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<Matrix4>? _tween;
  Offset? _lastTapDown;

  /// Escala actual (1 = ajustado al ancho).
  double get scale => _transform.value.getMaxScaleOnAxis();

  bool get isZoomed => scale > 1.01;

  @override
  void initState() {
    super.initState();
    _animation.addListener(() {
      final tween = _tween;
      if (tween != null) _transform.value = tween.value;
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    _transform.dispose();
    super.dispose();
  }

  /// Alterna el zoom. [focalPoint] (en coordenadas del visor) queda fijo; por
  /// defecto, el centro visible.
  void toggleZoom({Offset? focalPoint}) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final Matrix4 target;
    if (isZoomed) {
      target = Matrix4.identity();
    } else {
      final s = widget.zoomedScale;
      final viewport = context.size ?? widget.boardSize;
      final anchor = focalPoint ?? Offset(viewport.width / 2, math.min(viewport.height, widget.boardSize.height) / 2);
      final scene = _transform.toScene(anchor);
      target = Matrix4.identity()
        ..translateByDouble(anchor.dx - scene.dx * s, anchor.dy - scene.dy * s, 0, 1)
        ..scaleByDouble(s, s, 1, 1);
    }
    if (reduceMotion) {
      _transform.value = target;
      return;
    }
    _tween = Matrix4Tween(
      begin: _transform.value,
      end: target,
    ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic));
    _animation.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final viewer = InteractiveViewer(
      transformationController: _transform,
      constrained: false,
      minScale: 1,
      maxScale: widget.maxScale,
      boundaryMargin: EdgeInsets.zero,
      panEnabled: widget.panEnabled,
      child: SizedBox.fromSize(size: widget.boardSize, child: widget.child),
    );
    if (!widget.enableDoubleTapZoom) return viewer;
    return GestureDetector(
      onDoubleTapDown: (details) => _lastTapDown = details.localPosition,
      onDoubleTap: () => toggleZoom(focalPoint: _lastTapDown),
      child: viewer,
    );
  }
}
