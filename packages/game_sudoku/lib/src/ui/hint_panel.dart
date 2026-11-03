import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

import '../../l10n/generated/sudoku_localizations.dart';
import '../controller.dart';

/// Hoja de pista: ocupa el lugar de las herramientas y el teclado mientras la
/// pista está abierta, así la grilla con sus resaltados sigue a la vista.
class SudokuHintPanel extends StatelessWidget {
  const SudokuHintPanel({super.key, required this.controller});

  final SudokuController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = SudokuLocalizations.of(context);
    final session = controller.hintSession!;
    final hint = session.hint;
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;

    final (int? step, String title, String detail) = switch (session.step) {
      HintStep.error => (
        null,
        l10n.hintErrorTitle,
        l10n.hintErrorDetail(SudokuGrid.rowOf(hint.errorCell!) + 1, SudokuGrid.columnOf(hint.errorCell!) + 1),
      ),
      HintStep.zone => (1, l10n.hintZone(zoneText(l10n, hint)), l10n.hintZoneDetail),
      HintStep.technique => (
        2,
        l10n.techniqueName(hint.technique!.name),
        l10n.techniqueExplanation(hint.technique!.name),
      ),
      HintStep.number => (
        3,
        l10n.hintNumber(hint.digit!, SudokuGrid.rowOf(hint.cell!) + 1, SudokuGrid.columnOf(hint.cell!) + 1),
        hint.technique == null ? l10n.hintNumberRevealed : l10n.techniqueName(hint.technique!.name),
      ),
    };

    final actions = switch (session.step) {
      HintStep.error => [
        LudixaButton(
          label: l10n.hintEraseError,
          onPressed: controller.hintEraseError,
          variant: LudixaButtonVariant.secondary,
        ),
        LudixaButton(label: l10n.hintTryMyself, onPressed: controller.hintClose),
      ],
      HintStep.zone || HintStep.technique => [
        LudixaButton(
          label: session.step == HintStep.zone ? l10n.hintNextStep : l10n.hintShowNumber,
          onPressed: controller.hintNext,
          variant: LudixaButtonVariant.secondary,
        ),
        LudixaButton(label: l10n.hintTryMyself, onPressed: controller.hintClose),
      ],
      HintStep.number => [LudixaButton(label: l10n.hintDone, onPressed: controller.hintClose)],
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      // Se anuncia al abrirse y en cada paso.
      child: Semantics(
        liveRegion: true,
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                LudixaIcon(LudixaIcons.hint, color: p.sudoku, size: 20),
                const SizedBox(width: 8),
                Text(step == null ? l10n.hint : l10n.hintStep(step), style: text.labelLarge),
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: text.titleMedium),
            const SizedBox(height: 4),
            Text(detail, style: text.bodyMedium?.copyWith(color: p.inkMuted)),
            const SizedBox(height: 16),
            for (final (i, action) in actions.indexed) ...[if (i > 0) const SizedBox(height: 8), action],
          ],
        ),
      ),
    );
  }

  /// "la fila 5, la columna 5 y la caja central".
  static String zoneText(SudokuLocalizations l10n, SudokuHint hint) {
    final units = hint.units.isEmpty ? SudokuGrid.unitsOfCell[hint.cell!] : hint.units;
    final names = [
      for (final u in units.take(3))
        u < 9
            ? l10n.zoneRow(u + 1)
            : u < 18
            ? l10n.zoneColumn(u - 8)
            : l10n.zoneBox('${u - 18}'),
    ];
    return switch (names.length) {
      1 => names[0],
      2 => l10n.zoneTwo(names[0], names[1]),
      _ => l10n.zoneThree(names[0], names[1], names[2]),
    };
  }
}
