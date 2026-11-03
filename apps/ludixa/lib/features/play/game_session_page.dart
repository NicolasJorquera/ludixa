import 'dart:math';

import 'package:daily_challenge/daily_challenge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_api/game_api.dart';
import 'package:go_router/go_router.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../../app/router.dart';
import 'app_game_host.dart';
import 'difficulty_sheet.dart';
import 'pause_screen.dart';
import 'play_providers.dart';
import 'result_page.dart';

/// Cómo se abre una partida desde cualquier pantalla.
abstract final class GameFlow {
  /// Hoja de dificultad (recuerda el último nivel) y, si se elige, la partida.
  static Future<void> chooseAndPlay(BuildContext context, WidgetRef ref, GameModule module) async {
    final level = await showDifficultySheet(context, module, ref.read(lastDifficultyStoreProvider));
    if (level == null || !context.mounted) return;
    await play(context, module, freeRequest(level));
  }

  static PuzzleRequest freeRequest(Difficulty level) =>
      PuzzleRequest(mode: PuzzleMode.free, difficulty: level, seed: PuzzleSeed.random());

  static PuzzleRequest dailyRequest(GameModule module, LocalDay day) => PuzzleRequest(
    mode: PuzzleMode.daily,
    difficulty: module.dailySpec(day).difficulty,
    seed: PuzzleSeed.daily(day: day, game: module.id, generatorVersion: module.generatorVersion),
    day: day,
  );

  /// Abre la partida a pantalla completa, fuera de las pestañas.
  static Future<void> play(BuildContext context, GameModule module, PuzzleRequest request, {bool replace = false}) {
    final route = MaterialPageRoute<void>(
      builder: (context) => GameSessionPage(module: module, request: request),
    );
    final navigator = Navigator.of(context, rootNavigator: true);
    return replace ? navigator.pushReplacement(route) : navigator.push(route);
  }
}

/// Una partida en curso: crea el host de la app, muestra la pausa, guarda en
/// el progreso y lleva al Resultado al ganar.
class GameSessionPage extends ConsumerStatefulWidget {
  const GameSessionPage({super.key, required this.module, required this.request});

  final GameModule module;
  final PuzzleRequest request;

  @override
  ConsumerState<GameSessionPage> createState() => _GameSessionPageState();
}

class _GameSessionPageState extends ConsumerState<GameSessionPage> {
  late final AppGameHost _host;

  GameModule get _module => widget.module;

  @override
  void initState() {
    super.initState();
    final service = ref.read(progressServiceProvider);
    final request = widget.request;
    final day = request.day;
    _host = AppGameHost(
      service: service,
      session: SessionRecord(
        id: '${_module.id.value}-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}',
        game: _module.id,
        difficulty: request.difficulty,
        mode: request.mode,
        startedAt: service.clock.now(),
        challengeDay: day,
        seedKey: request.seed.key,
        generatorVersion: _module.generatorVersion,
        wordsLanguage: request.wordsLanguage,
        themeIds: day != null && _module.id == GameId.wordSearch ? DailyChallenge.themesFor(day) : const [],
      ),
      onShowPause: () => PauseScreen.show(context, _module, _host),
      onWon: _showResult,
      onPlayAgain: _playAgain,
    );
  }

  String _levelLabel(BuildContext context) =>
      _module.difficulties(context).where((o) => o.id == widget.request.difficulty).firstOrNull?.label ??
      _module.displayName(context);

  void _playAgain() {
    if (!mounted) return;
    GameFlow.play(context, _module, GameFlow.freeRequest(widget.request.difficulty), replace: true);
  }

  Future<void> _showResult(FinishedGame finished) async {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final modules = ref.read(gameModulesProvider);
    final service = ref.read(progressServiceProvider);
    GameModule? nextDaily;
    final day = widget.request.day;
    if (widget.request.mode == PuzzleMode.daily && day != null) {
      final done = (await service.repository.day(day))?.completed ?? const <GameId>{};
      nextDaily = [
        for (final g in dailyGames)
          if (!done.contains(g)) modules[g],
      ].nonNulls.firstOrNull;
    }
    if (!mounted) return;
    final level = _levelLabel(context);
    await navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => ResultPage(
          module: _module,
          finished: finished,
          levelLabel: level,
          onHome: () {
            Navigator.of(context).popUntil((r) => r.isFirst);
            GoRouter.of(context).go(AppRoutes.home);
          },
          onPlayAgain: () =>
              GameFlow.play(context, _module, GameFlow.freeRequest(widget.request.difficulty), replace: true),
          onNextDaily: nextDaily == null || day == null
              ? null
              : () => GameFlow.play(context, nextDaily!, GameFlow.dailyRequest(nextDaily, day), replace: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _module.buildGame(context, widget.request, _host);
}
