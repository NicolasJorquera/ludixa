import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

import '../../l10n/generated/sudoku_localizations.dart';
import '../controller.dart';

/// Grilla 9×9 con resaltados, notas, errores y la ola de celebración.
class SudokuBoard extends StatelessWidget {
  const SudokuBoard({super.key, required this.controller, required this.maxCellExtent, this.celebration});

  final SudokuController controller;
  final double maxCellExtent;

  /// Avance de la celebración (0 a 1), o null si no hay.
  final Animation<double>? celebration;

  @override
  Widget build(BuildContext context) {
    final l10n = SudokuLocalizations.of(context);
    final colors = Theme.of(context).extension<SudokuColors>()!;
    final palette = Theme.of(context).extension<LudixaColors>()!.palette;
    final hint = controller.hintSession;
    final hintZone = hint?.zoneCells ?? const <int>{};
    final hintPattern = hint?.patternCells ?? const <int>{};
    final hintTarget = hint?.target;
    final game = controller.game;
    final errors = controller.errorCells;
    final digit = controller.highlightedDigit;

    String label(int i) {
      final value = game.valueAt(i);
      final notes = game.notesAt(i);
      final parts = <String>[
        if (value == 0) l10n.cellEmpty else if (game.isGiven(i)) l10n.cellGiven(value) else '$value',
        if (value == 0 && notes.isNotEmpty) l10n.cellNotes(notes.join(', ')),
        if (errors.contains(i)) l10n.cellConflict,
        if (controller.selected == i) l10n.cellSelected,
      ];
      return l10n.cellLabel(SudokuGrid.rowOf(i) + 1, SudokuGrid.columnOf(i) + 1, parts.join(', '));
    }

    return Stack(
      children: [
        PuzzleGrid(
          dimensions: const GridDimensions(columns: 9, rows: 9),
          maxCellExtent: maxCellExtent,
          semanticLabel: l10n.boardLabel,
          semanticLabelFor: label,
          onCellTap: controller.tapCell,
          cellBuilder: (context, i, extent) {
            final value = game.valueAt(i);
            final error = errors.contains(i);
            final background = hintPattern.contains(i)
                ? colors.hintTarget
                : hintZone.contains(i)
                ? palette.hintSoft
                : controller.selected == i
                ? colors.selected
                : error
                ? colors.conflict
                : digit != null && value == digit
                ? colors.sameNumber
                : controller.inSelectedZone(i)
                ? colors.zone
                : colors.cell;
            final Widget cell = _Cell(
              value: value,
              given: game.isGiven(i),
              notes: game.notesAt(i),
              error: error,
              background: background,
              colors: colors,
              highlightedNote: digit,
              outline: hintTarget == i ? palette.sudoku : null,
            );
            final wave = celebration;
            if (wave == null) return cell;
            // La ola avanza en diagonal desde la esquina superior izquierda.
            final delay = (SudokuGrid.rowOf(i) + SudokuGrid.columnOf(i)) / 16 * 0.6;
            return AnimatedBuilder(
              animation: wave,
              builder: (context, child) {
                final t = ((wave.value - delay) / 0.4).clamp(0.0, 1.0);
                final pulse = t < 0.5 ? t * 2 : (1 - t) * 2;
                return ColoredBox(
                  color: Color.lerp(background, colors.sameNumber, pulse)!,
                  child: Transform.scale(scale: 1 + 0.12 * pulse, child: child),
                );
              },
              child: cell,
            );
          },
        ),
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _GridLines(colors))),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.value,
    required this.given,
    required this.notes,
    required this.error,
    required this.background,
    required this.colors,
    required this.highlightedNote,
    this.outline,
  });

  /// Borde de la celda objetivo de una pista.
  final Color? outline;

  final int value;
  final bool given;
  final List<int> notes;
  final bool error;
  final Color background;
  final SudokuColors colors;
  final int? highlightedNote;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (value != 0) {
      content = Text(
        '$value',
        style: LudixaTypography.gridDigit(entered: !given).copyWith(
          color: error ? colors.conflictInk : (given ? colors.given : colors.entered),
          // El error también se marca sin color, para la paleta de daltonismo.
          decoration: error ? TextDecoration.underline : null,
          decorationColor: colors.conflictInk,
          decorationThickness: 2,
        ),
      );
    } else if (notes.isNotEmpty) {
      content = Padding(
        padding: const EdgeInsets.all(2),
        child: GridView.count(
          crossAxisCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            for (var d = 1; d <= 9; d++)
              Center(
                child: Text(
                  notes.contains(d) ? '$d' : '',
                  style: LudixaTypography.gridNote().copyWith(
                    color: d == highlightedNote ? colors.entered : colors.note,
                    fontWeight: d == highlightedNote ? FontWeight.w700 : null,
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      content = const SizedBox.shrink();
    }
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: outline == null ? null : Border.all(color: outline!, width: 3),
        ),
        child: Center(child: content),
      ),
    );
  }
}

/// Líneas finas entre celdas y gruesas entre cajas.
class _GridLines extends CustomPainter {
  _GridLines(this.colors);

  final SudokuColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final thin = Paint()
      ..color = colors.thinLine
      ..strokeWidth = 1;
    final thick = Paint()
      ..color = colors.thickLine
      ..strokeWidth = 2;
    final step = size.width / 9;
    // Primero las finas y después las gruesas, para que un cruce no corte la
    // línea de una caja.
    for (final paint in [thin, thick]) {
      for (var k = 1; k < 9; k++) {
        if ((k % 3 == 0) != (paint == thick)) continue;
        canvas
          ..drawLine(Offset(k * step, 0), Offset(k * step, size.height), paint)
          ..drawLine(Offset(0, k * step), Offset(size.width, k * step), paint);
      }
    }
    canvas.drawRect(
      (Offset.zero & size).deflate(1),
      Paint()
        ..color = colors.thickLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_GridLines old) => old.colors != colors;
}
