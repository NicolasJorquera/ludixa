import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:design_system/design_system.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Si [node] es una celda de un tablero ([PuzzleGrid]).
bool _inBoard(SemanticsNode node) {
  for (SemanticsNode? n = node.parent; n != null; n = n.parent) {
    if (n.getSemanticsData().identifier == PuzzleGrid.semanticsIdentifier) return true;
  }
  return false;
}

/// 48 dp, como pide Android, en todo salvo las celdas de los tableros: 9
/// columnas no caben a 48 dp en un teléfono.
class _OutsideBoards extends MinimumTapTargetGuideline {
  const _OutsideBoards()
    : super(size: const Size(48, 48), link: 'https://support.google.com/accessibility/android/answer/7101858');

  @override
  bool shouldSkipNode(SemanticsNode node) => super.shouldSkipNode(node) || _inBoard(node);
}

/// Las celdas de los tableros miden al menos 36 dp (la celda cómoda del
/// sistema visual, a la que lleva el zoom): más que los 24 px de WCAG 2.2 AA.
class _BoardCells extends MinimumTapTargetGuideline {
  const _BoardCells()
    : super(size: const Size(36, 36), link: 'https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html');

  @override
  bool shouldSkipNode(SemanticsNode node) => super.shouldSkipNode(node) || !_inBoard(node);
}

/// Objetivos táctiles de Ludixa: 48 dp, y 36 dp en las celdas de un tablero.
const List<AccessibilityGuideline> ludixaTapTargetGuidelines = [_OutsideBoards(), _BoardCells()];

/// Todo nodo que se anuncia como botón habilitado se puede activar con el
/// lector de pantalla. Falla, por ejemplo, con `Semantics(button: true,
/// excludeSemantics: true)` sobre un InkWell: la acción del InkWell se pierde.
class _ButtonsCanBeActivated extends AccessibilityGuideline {
  const _ButtonsCanBeActivated();

  @override
  String get description => 'Los botones habilitados tienen la acción de tocar';

  @override
  FutureOr<Evaluation> evaluate(WidgetTester tester) {
    var result = const Evaluation.pass();
    void visit(SemanticsNode node) {
      final data = node.getSemanticsData();
      final flags = data.flagsCollection;
      final enabled = flags.isEnabled != Tristate.isFalse;
      if (!node.isMergedIntoParent &&
          flags.isButton &&
          enabled &&
          !data.hasAction(SemanticsAction.tap) &&
          !data.hasAction(SemanticsAction.longPress)) {
        result += Evaluation.fail('$node: botón sin acción de tocar');
      }
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    for (final view in tester.binding.renderViews) {
      visit(view.owner!.semanticsOwner!.rootSemanticsNode!);
    }
    return result;
  }
}

/// Ver [_ButtonsCanBeActivated].
const AccessibilityGuideline buttonsCanBeActivated = _ButtonsCanBeActivated();
