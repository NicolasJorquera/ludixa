import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:go_router/go_router.dart';
import 'package:ludixa/features/play/app_game_host.dart';
import 'package:ludixa/features/play/difficulty_sheet.dart';
import 'package:ludixa/features/play/game_session_page.dart';
import 'package:ludixa/features/play/last_difficulty.dart';
import 'package:ludixa/features/play/pause_screen.dart';
import 'package:ludixa/features/play/play_providers.dart';
import 'package:ludixa/features/play/result_page.dart';
import 'package:ludixa/features/settings/domain/app_settings.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'test_app.dart';

/// Pantallas del lienzo de diseño y cómo llegar a cada una con la app ya
/// montada. Las usan el barrido de diseño adaptable y la matriz de goldens.
final class FakeClock implements Clock {
  FakeClock(this.current);

  LocalNow current;

  @override
  LocalNow now() => current;
}

/// Martes 3 de noviembre de 2026, 10:00 en Chile.
final sweepNow = LocalNow(utc: DateTime.utc(2026, 11, 3, 13), offsetMinutes: -180);
final sweepToday = LocalDay(2026, 11, 3);

var _ids = 0;

SessionRecord _finished(GameId game, String level, {PuzzleMode mode = PuzzleMode.free, bool won = true}) =>
    SessionRecord(
      id: 'l${_ids++}',
      game: game,
      difficulty: Difficulty(level),
      mode: mode,
      startedAt: sweepNow,
      challengeDay: mode == PuzzleMode.free ? null : sweepToday,
    ).finish(
      status: won ? SessionStatus.won : SessionStatus.lost,
      elapsed: const Duration(minutes: 12, seconds: 34),
      completedAt: sweepNow.utc,
    );

Future<void> seedProgress(ProgressService service) async {
  await service.recordResult(_finished(GameId.sudoku, 'easy', mode: PuzzleMode.daily));
  await service.recordResult(_finished(GameId.sudoku, 'medium'));
  await service.recordResult(_finished(GameId.minesweeper, 'beginner'));
  await service.recordResult(_finished(GameId.minesweeper, 'expert', won: false));
  await service.recordResult(_finished(GameId.wordSearch, 'hard'));
}

/// Una pantalla del barrido: llega a ella desde la app ya montada.
typedef OpenScreen = Future<void> Function(WidgetTester tester, BuildContext context);

Future<void> _go(WidgetTester tester, BuildContext context, String location) async {
  GoRouter.of(context).go(location);
  await tester.pumpAndSettle();
}

Future<void> _push(WidgetTester tester, BuildContext context, Widget page) async {
  unawaited(Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(builder: (_) => page)));
  await tester.pumpAndSettle();
}

GameModule _module(BuildContext context, GameId game) =>
    ProviderScope.containerOf(context).read(gameModulesProvider)[game]!;

FinishedGame _result() => FinishedGame(
  session: _finished(GameId.sudoku, 'easy', mode: PuzzleMode.daily),
  outcome: const RecordOutcome(newAchievements: [AchievementId.firstPuzzle, AchievementId.sudokuFastMedium]),
  bestBefore: const Duration(minutes: 14),
  bestAfter: const Duration(minutes: 12, seconds: 34),
  winsAtLevel: 24,
  streakBefore: 11,
  streakAfter: 12,
  dailyDone: 2,
);

final screens = <String, OpenScreen>{
  'inicio': (t, c) => _go(t, c, '/'),
  'reto': (t, c) => _go(t, c, '/daily'),
  'archivo': (t, c) => _go(t, c, '/daily/archive'),
  'día del archivo': (t, c) => _go(t, c, '/daily/day/2026-11-01'),
  'progreso': (t, c) => _go(t, c, '/progress'),
  'progreso: buscaminas': (t, c) async {
    await _go(t, c, '/progress');
    final list = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;
    final name = find.text(_module(c, GameId.minesweeper).displayName(t.element(find.byType(TabBarView))));
    await t.scrollUntilVisible(name, 200, scrollable: list);
    await t.tap(name);
    await t.pumpAndSettle();
  },
  'logros': (t, c) async {
    await _go(t, c, '/progress');
    await t.tap(find.byType(Tab).last);
    await t.pumpAndSettle();
  },
  'ajustes': (t, c) => _go(t, c, '/settings'),
  'contrato de anuncios': (t, c) => _go(t, c, '/settings/ads'),
  for (final game in dailyGames) ...{
    'ajustes de ${game.value}': (t, c) => _go(t, c, '/settings/game/${game.value}'),
    'dificultad de ${game.value}': (t, c) async {
      unawaited(showDifficultySheet(c, _module(c, game), InMemoryLastDifficultyStore()));
      await t.pumpAndSettle();
    },
    'partida de ${game.value}': (t, c) async {
      final module = _module(c, game);
      unawaited(GameFlow.play(c, module, GameFlow.dailyRequest(module, sweepToday)));
      await t.pumpAndSettle();
    },
    'tutorial de ${game.value}': (t, c) async {
      unawaited(GameFlow.tutorial(c, _module(c, game), InMemoryLastDifficultyStore()));
      await t.pumpAndSettle();
    },
    'pausa de ${game.value}': (t, c) async {
      unawaited(PauseScreen.show(c, _module(c, game), const TutorialHost()));
      await t.pumpAndSettle();
    },
  },
  'resultado': (t, c) => _push(
    t,
    c,
    ResultPage(
      module: _module(c, GameId.sudoku),
      finished: _result(),
      levelLabel: 'Fácil',
      onHome: () {},
      onPlayAgain: () {},
      onNextDaily: () {},
    ),
  ),
};

/// Monta la app con el progreso de ejemplo y abre la pantalla [name].
Future<void> openScreen(
  WidgetTester tester,
  String name, {
  AppSettings settings = const AppSettings(),
  List<Locale> deviceLocales = const [Locale('es', 'CL')],
}) async {
  final repository = InMemoryProgressRepository();
  await seedProgress(ProgressService(repository, clock: FakeClock(sweepNow)));
  await pumpLudixa(
    tester,
    progress: repository,
    initial: settings,
    deviceLocales: deviceLocales,
    overrides: [clockProvider.overrideWithValue(FakeClock(sweepNow))],
  );
  await screens[name]!(tester, tester.element(find.byType(Scaffold).first));
}
