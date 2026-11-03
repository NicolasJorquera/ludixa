import 'package:daily_challenge/daily_challenge.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:game_api/game_api.dart';
import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../l10n/generated/mines_localizations.dart';
import 'controller.dart';
import 'settings.dart';
import 'ui/minesweeper_page.dart';
import 'ui/settings_view.dart';
import 'ui/tutorial.dart';

/// Niveles del Buscaminas. `reduced` es el 12×12 de mitad de semana del reto.
abstract final class MinesweeperLevels {
  static const beginner = Difficulty('beginner');
  static const reduced = Difficulty('reduced');
  static const intermediate = Difficulty('intermediate');
  static const expert = Difficulty('expert');

  static BoardSpec specOf(Difficulty level) => switch (level.value) {
    'beginner' => BoardSpec.beginner,
    'reduced' => DailyLineup.reducedIntermediate,
    'intermediate' => BoardSpec.intermediate,
    'expert' => BoardSpec.expert,
    _ => throw ArgumentError('Nivel de Buscaminas desconocido: ${level.value}'),
  };

  static Difficulty of(BoardSpec spec) =>
      [beginner, reduced, intermediate, expert].firstWhere((d) => specOf(d).toString() == spec.toString());

  static String label(MinesLocalizations l10n, Difficulty level) => switch (level.value) {
    'beginner' => l10n.levelBeginner,
    'reduced' => l10n.levelDaily,
    'intermediate' => l10n.levelIntermediate,
    _ => l10n.levelExpert,
  };
}

/// Buscaminas como módulo de la colección.
class MinesweeperModule implements GameModule {
  MinesweeperModule({MinesweeperSettingsStore? store}) : store = store ?? InMemoryMinesweeperSettingsStore();

  final MinesweeperSettingsStore store;

  @override
  GameId get id => GameId.minesweeper;

  @override
  int get generatorVersion => NoGuessGenerator.version;

  @override
  List<LocalizationsDelegate<Object?>> get localizationsDelegates => MinesLocalizations.localizationsDelegates;

  @override
  String displayName(BuildContext context) => MinesLocalizations.of(context).gameName;

  @override
  Widget buildIcon(BuildContext context, {double size = 24}) => LudixaIcon(LudixaIcons.mine, size: size);

  @override
  List<DifficultyOption> difficulties(BuildContext context) {
    final l10n = MinesLocalizations.of(context);
    return [
      DifficultyOption(
        id: MinesweeperLevels.beginner,
        label: l10n.levelBeginner,
        description: l10n.levelBeginnerDescription,
      ),
      DifficultyOption(
        id: MinesweeperLevels.intermediate,
        label: l10n.levelIntermediate,
        description: l10n.levelIntermediateDescription,
      ),
      DifficultyOption(id: MinesweeperLevels.expert, label: l10n.levelExpert, description: l10n.levelExpertDescription),
    ];
  }

  @override
  DailySpec dailySpec(LocalDay day) => DailySpec(difficulty: MinesweeperLevels.of(DailyLineup.of(day).minesweeper));

  @override
  Widget buildGame(BuildContext context, PuzzleRequest request, GameHost host) {
    final resume = request.resumeFrom;
    final MinesweeperController controller;
    if (resume != null) {
      controller = MinesweeperController.resume(resume, host: host, store: store);
    } else {
      final spec = MinesweeperLevels.specOf(request.difficulty);
      final game = request.mode == PuzzleMode.free
          ? MinesweeperGame.free(spec: spec, seed: request.seed)
          : MinesweeperGame.daily(spec: spec, seed: DailyChallenge.seed(GameId.minesweeper, request.day!));
      controller = MinesweeperController(game: game, host: host, store: store);
    }
    return MinesweeperPage(
      controller: controller,
      onResume: controller.reloadSettings,
      levelLabel: MinesweeperLevels.label(MinesLocalizations.of(context), MinesweeperLevels.of(controller.game.spec)),
    );
  }

  @override
  Widget buildTutorial(BuildContext context, GameHost host) =>
      MinesweeperTutorial(onDone: () => Navigator.maybePop(context));

  @override
  Widget? buildSettings(BuildContext context) => MinesweeperSettingsView(store: store);
}
