import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/words_localizations.dart';
import '../settings.dart';

/// Ajustes propios de la Sopa. Cada cambio se aplica y se guarda al instante.
class WordSearchSettingsView extends StatefulWidget {
  const WordSearchSettingsView({super.key, required this.store, this.onOpenTutorial});

  final WordSearchSettingsStore store;
  final VoidCallback? onOpenTutorial;

  @override
  State<WordSearchSettingsView> createState() => _WordSearchSettingsViewState();
}

class _WordSearchSettingsViewState extends State<WordSearchSettingsView> {
  late WordSearchSettings _settings = widget.store.load();

  void _update(WordSearchSettings next) {
    setState(() => _settings = next);
    widget.store.save(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = WordsLocalizations.of(context);
    final s = _settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LudixaSectionLabel(l10n.settingsSelection),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LudixaSegmentedControl<SelectionMode>(
            segments: [
              LudixaSegment(value: SelectionMode.drag, label: l10n.settingsSelectionDrag),
              LudixaSegment(value: SelectionMode.tap, label: l10n.settingsSelectionTap),
            ],
            selected: s.selection,
            onChanged: (v) => _update(s.copyWith(selection: v)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(l10n.settingsSelectionHelp, style: Theme.of(context).textTheme.bodySmall),
        ),
        LudixaSectionLabel(l10n.settingsLanguage),
        RadioGroup<String>(
          groupValue: s.wordsLanguage ?? 'app',
          onChanged: (v) => _update(s.copyWith(wordsLanguage: () => v == 'app' ? null : v)),
          child: Column(
            children: [
              RadioListTile(value: 'app', title: Text(l10n.settingsLanguageApp)),
              RadioListTile(value: 'es', title: Text(l10n.settingsLanguageSpanish)),
              RadioListTile(value: 'en', title: Text(l10n.settingsLanguageEnglish)),
            ],
          ),
        ),
        if (widget.onOpenTutorial != null) LudixaListRow(title: l10n.settingsTutorial, onTap: widget.onOpenTutorial),
      ],
    );
  }
}
