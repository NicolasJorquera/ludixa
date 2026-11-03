import 'dart:isolate';

import 'package:daily_challenge/daily_challenge.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:game_api/game_api.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

import '../l10n/generated/sudoku_localizations.dart';
import 'controller.dart';
import 'settings.dart';
import 'ui/settings_view.dart';
import 'ui/sudoku_game_page.dart';
import 'ui/tutorial.dart';

/// Sudoku como módulo de la colección.
class SudokuModule implements GameModule {
  SudokuModule({SudokuSettingsStore? store, this.generationBudget = const Duration(seconds: 2)})
    : store = store ?? InMemorySudokuSettingsStore();

  /// Ajustes del juego; la app pasa uno que los guarda.
  final SudokuSettingsStore store;

  /// Tiempo máximo para generar una partida libre; después se usa el banco.
  final Duration generationBudget;

  @override
  GameId get id => GameId.sudoku;

  @override
  int get generatorVersion => SudokuGenerator.version;

  @override
  List<LocalizationsDelegate<Object?>> get localizationsDelegates => SudokuLocalizations.localizationsDelegates;

  @override
  String displayName(BuildContext context) => SudokuLocalizations.of(context).gameName;

  @override
  Widget buildIcon(BuildContext context, {double size = 24}) => LudixaIcon(LudixaIcons.sudoku, size: size);

  @override
  List<DifficultyOption> difficulties(BuildContext context) {
    final l10n = SudokuLocalizations.of(context);
    return [
      for (final level in SudokuDifficulty.values)
        DifficultyOption(
          id: Difficulty(level.name),
          label: levelLabel(l10n, level),
          description: switch (level) {
            SudokuDifficulty.easy => l10n.levelEasyDescription,
            SudokuDifficulty.medium => l10n.levelMediumDescription,
            SudokuDifficulty.hard => l10n.levelHardDescription,
            SudokuDifficulty.expert => l10n.levelExpertDescription,
          },
        ),
    ];
  }

  static String levelLabel(SudokuLocalizations l10n, SudokuDifficulty level) => switch (level) {
    SudokuDifficulty.easy => l10n.levelEasy,
    SudokuDifficulty.medium => l10n.levelMedium,
    SudokuDifficulty.hard => l10n.levelHard,
    SudokuDifficulty.expert => l10n.levelExpert,
  };

  @override
  String difficultyLabel(BuildContext context, Difficulty difficulty) => levelLabel(
    SudokuLocalizations.of(context),
    SudokuDifficulty.values.firstWhere((l) => l.name == difficulty.value, orElse: () => SudokuDifficulty.easy),
  );

  @override
  String? dailyDetail(BuildContext context, LocalDay day) => null;

  @override
  DailySpec dailySpec(LocalDay day) => DailySpec(difficulty: Difficulty(DailyLineup.of(day).sudoku.name));

  @override
  Widget buildGame(BuildContext context, PuzzleRequest request, GameHost host) => SudokuGameLoader(
    request: request,
    host: host,
    settings: store.load(),
    loadSettings: store.load,
    generationBudget: generationBudget,
  );

  @override
  Widget buildTutorial(BuildContext context, GameHost host) =>
      SudokuTutorial(onDone: () => Navigator.maybePop(context));

  @override
  Widget? buildSettings(BuildContext context) => SudokuSettingsView(store: store);
}

/// Prepara el puzzle (retomado, del reto o generado en otro isolate) y abre
/// la partida.
class SudokuGameLoader extends StatefulWidget {
  const SudokuGameLoader({
    super.key,
    required this.request,
    required this.host,
    this.settings = const SudokuSettings(),
    this.generationBudget = const Duration(seconds: 2),
    this.onSolved,
    this.loadSettings,
  });

  /// Relee los ajustes al reanudar (pudieron cambiar desde la pausa).
  final SudokuSettings Function()? loadSettings;

  final PuzzleRequest request;
  final GameHost host;
  final SudokuSettings settings;
  final Duration generationBudget;
  final VoidCallback? onSolved;

  @override
  State<SudokuGameLoader> createState() => _SudokuGameLoaderState();
}

class _SudokuGameLoaderState extends State<SudokuGameLoader> {
  late final Future<SudokuController> _controller = _load();

  Future<SudokuController> _load() async {
    final request = widget.request;
    final resume = request.resumeFrom;
    if (resume != null) return SudokuController.resume(resume, host: widget.host, settings: widget.settings);
    final level = SudokuDifficulty.values.byName(request.difficulty.value);
    final SudokuPuzzle puzzle;
    if (request.mode == PuzzleMode.free) {
      final key = request.seed.key;
      final budget = widget.generationBudget;
      puzzle = await Isolate.run(
        () => freePlaySudoku(level, PuzzleSeed.fromKey(key).createRandom(), budget: budget).puzzle,
      );
    } else {
      final day = request.day!;
      puzzle = DailyChallenge.sudoku(day, today: day);
    }
    return SudokuController(game: SudokuGame(puzzle), host: widget.host, settings: widget.settings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SudokuLocalizations.of(context);
    return FutureBuilder(
      future: _controller,
      builder: (context, snapshot) {
        final controller = snapshot.data;
        if (controller == null) {
          if (snapshot.hasError) Error.throwWithStackTrace(snapshot.error!, snapshot.stackTrace!);
          return Scaffold(
            body: Center(
              child: Semantics(label: l10n.preparing, child: const CircularProgressIndicator()),
            ),
          );
        }
        return SudokuGamePage(
          controller: controller,
          levelLabel: SudokuModule.levelLabel(l10n, controller.game.puzzle.difficulty),
          onSolved: widget.onSolved,
          onResume: widget.loadSettings == null ? null : () => controller.applySettings(widget.loadSettings!()),
        );
      },
    );
  }
}
