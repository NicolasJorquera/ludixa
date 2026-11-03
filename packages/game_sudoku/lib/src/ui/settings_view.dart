import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/sudoku_localizations.dart';
import '../settings.dart';

/// Ajustes propios del Sudoku. Cada cambio se aplica y se guarda al instante.
class SudokuSettingsView extends StatefulWidget {
  const SudokuSettingsView({super.key, required this.store, this.onOpenTutorial});

  final SudokuSettingsStore store;
  final VoidCallback? onOpenTutorial;

  @override
  State<SudokuSettingsView> createState() => _SudokuSettingsViewState();
}

class _SudokuSettingsViewState extends State<SudokuSettingsView> {
  late SudokuSettings _settings = widget.store.load();

  void _update(SudokuSettings next) {
    setState(() => _settings = next);
    widget.store.save(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SudokuLocalizations.of(context);
    final s = _settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LudixaSectionLabel(l10n.settingsInput),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LudixaSegmentedControl<SudokuInputMode>(
            segments: [
              LudixaSegment(value: SudokuInputMode.cellFirst, label: l10n.settingsInputCellFirst),
              LudixaSegment(value: SudokuInputMode.numberFirst, label: l10n.settingsInputNumberFirst),
            ],
            selected: s.inputMode,
            onChanged: (v) => _update(s.copyWith(inputMode: v)),
          ),
        ),
        LudixaSectionLabel(l10n.settingsErrors),
        RadioGroup<SudokuErrorMode>(
          groupValue: s.errorMode,
          onChanged: (v) => _update(s.copyWith(errorMode: v)),
          child: Column(
            children: [
              RadioListTile(value: SudokuErrorMode.conflicts, title: Text(l10n.settingsErrorsConflicts)),
              RadioListTile(value: SudokuErrorMode.solution, title: Text(l10n.settingsErrorsSolution)),
              RadioListTile(value: SudokuErrorMode.none, title: Text(l10n.settingsErrorsNone)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(l10n.settingsErrorsHelp, style: Theme.of(context).textTheme.bodySmall),
        ),
        LudixaSwitchRow(
          title: l10n.settingsRemoveNotes,
          value: s.removeNotesOnPlace,
          onChanged: (v) => _update(s.copyWith(removeNotesOnPlace: v)),
        ),
        LudixaSwitchRow(
          title: l10n.settingsHighlightSame,
          value: s.highlightSameNumber,
          onChanged: (v) => _update(s.copyWith(highlightSameNumber: v)),
        ),
        if (widget.onOpenTutorial != null) LudixaListRow(title: l10n.settingsTutorial, onTap: widget.onOpenTutorial),
      ],
    );
  }
}
