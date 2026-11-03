import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:game_api/game_api.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../../l10n/generated/app_localizations.dart';
import 'last_difficulty.dart';

/// Hoja de dificultad: niveles con tiempo y técnica, marcando el último que
/// se jugó. Devuelve el nivel elegido (y lo recuerda) o null.
Future<Difficulty?> showDifficultySheet(BuildContext context, GameModule module, LastDifficultyStore store) async {
  final options = module.difficulties(context);
  final last = store.load(module.id);
  final chosen = await showModalBottomSheet<Difficulty>(
    context: context,
    // Sobre las pestañas: la barra inferior no debe tapar ningún nivel.
    useRootNavigator: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return SafeArea(
        child: LudixaSheet(
          title: l10n.difficultyTitle(module.displayName(context)),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final o in options)
                ListTile(
                  title: Text(o.label),
                  subtitle: Text(o.description),
                  selected: o.id == last,
                  trailing: o.id == last ? LudixaBadge(label: l10n.difficultyLast) : null,
                  onTap: () => Navigator.pop(context, o.id),
                ),
            ],
          ),
        ),
      );
    },
  );
  if (chosen != null) await store.save(module.id, chosen);
  return chosen;
}
