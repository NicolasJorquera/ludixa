import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/mines_localizations.dart';
import '../settings.dart';

/// Ajustes propios del Buscaminas. Cada cambio se aplica y se guarda al instante.
class MinesweeperSettingsView extends StatefulWidget {
  const MinesweeperSettingsView({super.key, required this.store, this.onOpenTutorial});

  final MinesweeperSettingsStore store;
  final VoidCallback? onOpenTutorial;

  @override
  State<MinesweeperSettingsView> createState() => _MinesweeperSettingsViewState();
}

class _MinesweeperSettingsViewState extends State<MinesweeperSettingsView> {
  late MinesweeperSettings _settings = widget.store.load();

  void _update(MinesweeperSettings next) {
    setState(() => _settings = next);
    widget.store.save(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = MinesLocalizations.of(context);
    final s = _settings;
    final help = Theme.of(context).textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LudixaSectionLabel(l10n.settingsTapMode),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LudixaSegmentedControl<TapAction>(
            segments: [
              LudixaSegment(value: TapAction.reveal, label: l10n.modeReveal),
              LudixaSegment(value: TapAction.flag, label: l10n.modeFlag),
            ],
            selected: s.tapAction,
            onChanged: (v) => _update(s.copyWith(tapAction: v)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(l10n.settingsTapModeHelp, style: help),
        ),
        LudixaSectionLabel(l10n.settingsLongPress),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LudixaSegmentedControl<LongPressSpeed>(
            segments: [
              LudixaSegment(value: LongPressSpeed.short, label: l10n.settingsLongPressShort),
              LudixaSegment(value: LongPressSpeed.normal, label: l10n.settingsLongPressNormal),
              LudixaSegment(value: LongPressSpeed.long, label: l10n.settingsLongPressLong),
            ],
            selected: s.longPress,
            onChanged: (v) => _update(s.copyWith(longPress: v)),
          ),
        ),
        const SizedBox(height: 8),
        LudixaSwitchRow(
          title: l10n.settingsChord,
          subtitle: l10n.settingsChordHelp,
          value: s.chord,
          onChanged: (v) => _update(s.copyWith(chord: v)),
        ),
        if (widget.onOpenTutorial != null) LudixaListRow(title: l10n.settingsTutorial, onTap: widget.onOpenTutorial),
      ],
    );
  }
}
