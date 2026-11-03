import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/sudoku_localizations.dart';
import '../controller.dart';
import '../settings.dart';

/// Deshacer, Borrar, Notas y Pista (con contador de pistas gratis).
class SudokuTools extends StatelessWidget {
  const SudokuTools({super.key, required this.controller, required this.freeHintsLeft});

  final SudokuController controller;
  final int freeHintsLeft;

  @override
  Widget build(BuildContext context) {
    final l10n = SudokuLocalizations.of(context);
    final c = controller;
    final active = !c.paused && !c.solved;
    return Row(
      children: [
        _Tool(icon: LudixaIcons.undo, label: l10n.undo, onTap: active && c.game.canUndo ? c.undo : null),
        _Tool(icon: LudixaIcons.erase, label: l10n.erase, onTap: active && c.selected != null ? c.erase : null),
        _Tool(
          icon: LudixaIcons.notes,
          label: l10n.notes,
          toggled: c.notesMode,
          semanticValue: l10n.notesState('${c.notesMode}'),
          onTap: active ? c.toggleNotes : null,
        ),
        _Tool(
          icon: LudixaIcons.hint,
          label: l10n.hint,
          badge: c.hintsExhausted ? null : '$freeHintsLeft',
          semanticValue: c.hintsExhausted ? l10n.noMoreHints : l10n.hintsLeft(freeHintsLeft),
          tooltip: c.hintsExhausted ? l10n.noMoreHints : null,
          onTap: active && !c.hintsExhausted ? c.hint : null,
        ),
      ],
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({
    required this.icon,
    required this.label,
    required this.onTap,
    this.toggled = false,
    this.badge,
    this.semanticValue,
    this.tooltip,
  });

  final LudixaIcons icon;
  final String label;
  final VoidCallback? onTap;
  final bool toggled;
  final String? badge;
  final String? semanticValue;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final enabled = onTap != null;
    final color = !enabled ? p.inkMuted.withValues(alpha: 0.5) : (toggled ? p.sudoku : p.ink);
    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Badge(
          isLabelVisible: badge != null,
          label: Text(badge ?? ''),
          backgroundColor: p.sudoku,
          textColor: p.onPrimary,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: toggled ? p.sudokuSoft : null, borderRadius: BorderRadius.circular(12)),
            child: LudixaIcon(icon, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
      ],
    );
    if (tooltip != null) body = Tooltip(message: tooltip, child: body);
    return Expanded(
      child: Semantics(
        button: true,
        enabled: enabled,
        toggled: label == SudokuLocalizations.of(context).notes ? toggled : null,
        label: label,
        value: semanticValue,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: body),
        ),
      ),
    );
  }
}

/// Teclado de 9 teclas con el conteo de cada número; se atenúa y muestra ✓
/// cuando el número está completo.
class SudokuKeypad extends StatelessWidget {
  const SudokuKeypad({super.key, required this.controller, required this.keyHeight});

  final SudokuController controller;
  final double keyHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = SudokuLocalizations.of(context);
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final c = controller;
    final active = !c.paused && !c.solved;
    return Row(
      children: [
        for (var d = 1; d <= 9; d++)
          Expanded(
            child: Builder(
              builder: (context) {
                final remaining = (9 - c.game.countOf(d)).clamp(0, 9);
                final complete = remaining == 0;
                final chosen = c.settings.inputMode == SudokuInputMode.numberFirst && c.activeDigit == d;
                final ink = complete || !active ? p.inkMuted : p.sudoku;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Semantics(
                    button: true,
                    selected: chosen,
                    label: l10n.keyRemaining(d, remaining),
                    excludeSemantics: true,
                    child: Material(
                      color: chosen ? p.sudokuSoft : p.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: chosen ? p.sudoku : p.line),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: active ? () => c.tapDigit(d) : null,
                        child: SizedBox(
                          height: keyHeight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$d',
                                style: LudixaTypography.gridDigit(entered: true).copyWith(fontSize: 24, color: ink),
                              ),
                              const SizedBox(height: 2),
                              complete
                                  ? LudixaIcon(LudixaIcons.check, size: 14, color: p.inkMuted)
                                  : Text(
                                      '$remaining',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: p.inkMuted),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
