import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:minesweeper_engine/minesweeper_engine.dart';

import '../../l10n/generated/mines_localizations.dart';
import '../controller.dart';

/// Separación entre celdas del Buscaminas.
const double minesweeperGap = 2;

/// Tablero: celdas en relieve, números con color (y puntos para el 1 a 3 en
/// la paleta para daltonismo), banderas, minas tras perder, la celda de inicio
/// del reto y la celda de la pista.
class MinesweeperBoard extends StatelessWidget {
  const MinesweeperBoard({
    super.key,
    required this.controller,
    required this.cellExtent,
    required this.onTap,
    required this.onLongPress,
  });

  final MinesweeperController controller;
  final double cellExtent;
  final ValueChanged<int> onTap;
  final ValueChanged<int> onLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = MinesLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.extension<MinesweeperColors>()!;
    final ludixa = theme.extension<LudixaColors>()!;
    final game = controller.game;
    final spec = game.spec;
    final hint = controller.hint;
    final hintSources = hint?.sources.toSet() ?? const <int>{};
    final untouched =
        !game.needsBoard &&
        [for (var i = 0; i < spec.cellCount; i++) game.viewAt(i)].every((v) => v == CellView.hidden);
    final start = untouched && game.status == GameStatus.playing ? game.suggestedStart : null;

    String label(int i) {
      final view = game.viewAt(i);
      final parts = <String>[
        switch (view) {
          CellView.hidden => controller.won ? l10n.cellFlagged : l10n.cellHidden,
          CellView.flagged => l10n.cellFlagged,
          CellView.revealed => game.numberAt(i) == 0 ? l10n.cellEmpty : l10n.cellNumber(game.numberAt(i)),
          CellView.mine => l10n.cellMine,
          CellView.fatal => l10n.cellFatal,
          CellView.wrongFlag => l10n.cellWrongFlag,
        },
        if (i == start) l10n.cellStart,
        if (hint?.cell == i) l10n.cellHint,
      ];
      return l10n.cellLabel(i ~/ spec.width + 1, i % spec.width + 1, parts.join(', '));
    }

    return PuzzleGrid(
      dimensions: GridDimensions(columns: spec.width, rows: spec.height),
      fixedCellExtent: cellExtent,
      gap: minesweeperGap,
      longPressDuration: controller.settings.longPress.duration,
      semanticLabel: l10n.boardLabel(spec.width, spec.height),
      semanticLabelFor: label,
      onCellTap: onTap,
      onCellLongPress: onLongPress,
      cellBuilder: (context, i, extent) => _Cell(
        view: game.viewAt(i),
        number: game.needsBoard || game.viewAt(i) != CellView.revealed ? 0 : game.numberAt(i),
        won: controller.won,
        extent: extent,
        colors: colors,
        palette: ludixa.palette,
        colorblind: ludixa.variant == PaletteVariant.colorblind,
        isStart: i == start,
        isHint: hint?.cell == i,
        isHintSource: hintSources.contains(i),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.view,
    required this.number,
    required this.won,
    required this.extent,
    required this.colors,
    required this.palette,
    required this.colorblind,
    required this.isStart,
    required this.isHint,
    required this.isHintSource,
  });

  final CellView view;
  final int number;
  final bool won;
  final double extent;
  final MinesweeperColors colors;
  final LudixaPalette palette;
  final bool colorblind;
  final bool isStart;
  final bool isHint;
  final bool isHintSource;

  @override
  Widget build(BuildContext context) {
    final closed = view == CellView.hidden || view == CellView.flagged || view == CellView.wrongFlag;
    final icon = extent * 0.62;
    Widget? content;
    switch (view) {
      case CellView.flagged:
        content = LudixaIcon(LudixaIcons.flagFilled, size: icon, color: colors.flag);
      case CellView.hidden when won:
        // Al ganar, las minas que quedan se marcan solas.
        content = LudixaIcon(LudixaIcons.flagFilled, size: icon, color: colors.flag);
      case CellView.wrongFlag:
        content = Stack(
          alignment: Alignment.center,
          children: [
            LudixaIcon(LudixaIcons.flag, size: icon, color: palette.inkMuted),
            LudixaIcon(LudixaIcons.close, size: icon, color: colors.fatal),
          ],
        );
      case CellView.mine:
        content = LudixaIcon(LudixaIcons.mineFilled, size: icon, color: palette.ink);
      case CellView.fatal:
        content = LudixaIcon(LudixaIcons.mineFilled, size: icon, color: colors.onFatal);
      case CellView.revealed when number > 0:
        final style = LudixaTypography.gridLetter().copyWith(
          color: colors.number(number),
          fontSize: (extent * 0.55).clamp(10.0, 22.0),
        );
        content = colorblind && number <= 3
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$number', style: style),
                  // Puntos además del color, para distinguir 1, 2 y 3.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var k = 0; k < number; k++)
                        Container(
                          width: extent * 0.09,
                          height: extent * 0.09,
                          margin: EdgeInsets.symmetric(horizontal: extent * 0.03),
                          decoration: BoxDecoration(color: colors.number(number), shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ],
              )
            : Text('$number', style: style);
      case _:
        content = null;
    }

    final background = view == CellView.fatal
        ? colors.fatal
        : isHintSource
        ? palette.hintSoft
        : closed
        ? colors.closed
        : colors.open;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(extent * 0.12),
          border: isHint || isStart
              ? Border.all(color: palette.minesweeper, width: 3)
              : closed
              ? Border(bottom: BorderSide(color: colors.closedEdge, width: 2))
              : null,
        ),
        child: Center(child: content),
      ),
    );
  }
}
