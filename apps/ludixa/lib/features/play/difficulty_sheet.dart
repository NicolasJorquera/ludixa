import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:game_api/game_api.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../../l10n/generated/app_localizations.dart';
import 'last_difficulty.dart';

/// Hoja de dificultad: niveles como grupo de radio (tiempo, técnica y
/// récord), "Cómo se juega" y "Empezar · nivel". Recuerda el último nivel.
/// Devuelve el nivel elegido o null si se cierra.
Future<Difficulty?> showDifficultySheet(
  BuildContext context,
  GameModule module,
  LastDifficultyStore store, {
  Map<Difficulty, Duration> bestTimes = const {},
  VoidCallback? onHowToPlay,
}) async {
  final options = module.difficulties(context);
  final chosen = await showModalBottomSheet<Difficulty>(
    context: context,
    // Sobre las pestañas: la barra inferior no debe tapar ningún nivel.
    useRootNavigator: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _DifficultySheet(
      module: module,
      options: options,
      initial: store.load(module.id) ?? options.first.id,
      bestTimes: bestTimes,
      onHowToPlay: onHowToPlay,
    ),
  );
  if (chosen != null) await store.save(module.id, chosen);
  return chosen;
}

class _DifficultySheet extends StatefulWidget {
  const _DifficultySheet({
    required this.module,
    required this.options,
    required this.initial,
    required this.bestTimes,
    required this.onHowToPlay,
  });

  final GameModule module;
  final List<DifficultyOption> options;
  final Difficulty initial;
  final Map<Difficulty, Duration> bestTimes;
  final VoidCallback? onHowToPlay;

  @override
  State<_DifficultySheet> createState() => _DifficultySheetState();
}

class _DifficultySheetState extends State<_DifficultySheet> {
  late Difficulty _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = widget.options.firstWhere((o) => o.id == _selected, orElse: () => widget.options.first).label;
    return LudixaSheet(
      title: l10n.difficultyTitle(widget.module.displayName(context)),
      body: Semantics(
        label: l10n.difficultyLevels,
        container: true,
        child: RadioGroup<Difficulty>(
          groupValue: _selected,
          onChanged: (v) => setState(() => _selected = v!),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final o in widget.options)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: RadioListTile<Difficulty>(
                    value: o.id,
                    title: Text(o.label),
                    subtitle: Text(
                      '${o.description} · ${switch (widget.bestTimes[o.id]) {
                        final best? => l10n.difficultyBest(_format(best)),
                        null => l10n.difficultyNoGames,
                      }}',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.onHowToPlay != null)
          LudixaButton(
            label: l10n.pauseHowToPlay,
            onPressed: widget.onHowToPlay,
            variant: LudixaButtonVariant.tertiary,
          ),
        LudixaButton(label: l10n.difficultyStart(label), onPressed: () => Navigator.pop(context, _selected)),
      ],
    );
  }

  static String _format(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}
