import 'dart:async';
import 'dart:io';

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
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'support/test_app.dart';

final class _FakeClock implements Clock {
  _FakeClock(this.current);

  LocalNow current;

  @override
  LocalNow now() => current;
}

/// Martes 3 de noviembre de 2026, 10:00 en Chile.
final _now = LocalNow(utc: DateTime.utc(2026, 11, 3, 13), offsetMinutes: -180);
final _today = LocalDay(2026, 11, 3);

var _ids = 0;

SessionRecord _finished(GameId game, String level, {PuzzleMode mode = PuzzleMode.free, bool won = true}) =>
    SessionRecord(
      id: 'l${_ids++}',
      game: game,
      difficulty: Difficulty(level),
      mode: mode,
      startedAt: _now,
      challengeDay: mode == PuzzleMode.free ? null : _today,
    ).finish(
      status: won ? SessionStatus.won : SessionStatus.lost,
      elapsed: const Duration(minutes: 12, seconds: 34),
      completedAt: _now.utc,
    );

Future<void> _seed(ProgressService service) async {
  await service.recordResult(_finished(GameId.sudoku, 'easy', mode: PuzzleMode.daily));
  await service.recordResult(_finished(GameId.sudoku, 'medium'));
  await service.recordResult(_finished(GameId.minesweeper, 'beginner'));
  await service.recordResult(_finished(GameId.minesweeper, 'expert', won: false));
  await service.recordResult(_finished(GameId.wordSearch, 'hard'));
}

/// Una pantalla del barrido: llega a ella desde la app ya montada.
typedef _Open = Future<void> Function(WidgetTester tester, BuildContext context);

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

final _screens = <String, _Open>{
  'inicio': (t, c) => _go(t, c, '/'),
  'reto': (t, c) => _go(t, c, '/daily'),
  'archivo': (t, c) => _go(t, c, '/daily/archive'),
  'día del archivo': (t, c) => _go(t, c, '/daily/day/2026-11-01'),
  'progreso': (t, c) => _go(t, c, '/progress'),
  'progreso: buscaminas': (t, c) async {
    await _go(t, c, '/progress');
    final list = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;
    await t.scrollUntilVisible(find.text('Buscaminas'), 200, scrollable: list);
    await t.tap(find.text('Buscaminas'));
    await t.pumpAndSettle();
  },
  'logros': (t, c) async {
    await _go(t, c, '/progress');
    await t.tap(find.text('Logros'));
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
      unawaited(GameFlow.play(c, module, GameFlow.dailyRequest(module, _today)));
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

/// Anchos del criterio de aceptación (dp) con un alto de teléfono o tablet.
const _sizes = [Size(320, 568), Size(390, 844), Size(600, 960), Size(840, 1180)];
const _scales = [1.0, 2.0];

/// Desplaza todo lo desplazable hasta el final para que se construya y se
/// mida también lo que empieza fuera de la pantalla.
Future<void> _scrollThrough(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    final scrollables = find.byType(Scrollable).hitTestable();
    if (scrollables.evaluate().isEmpty) return;
    final before = tester.state<ScrollableState>(scrollables.first).position.pixels;
    await tester.drag(scrollables.first, const Offset(0, -500), warnIfMissed: false);
    await tester.pumpAndSettle();
    if (tester.state<ScrollableState>(scrollables.first).position.pixels == before) return;
  }
}

/// Con LAYOUT_SHOTS=carpeta y --update-goldens guarda capturas de cada
/// pantalla (arriba y al final) para revisarlas a ojo. No son goldens.
Future<void> _shot(WidgetTester tester, Size size, double scale, String name, String part) async {
  final dir = Platform.environment['LAYOUT_SHOTS'];
  if (dir == null) return;
  final index = _screens.keys.toList().indexOf(name).toString().padLeft(2, '0');
  final file = Uri.file('$dir/${size.width.toInt()}_${(scale * 100).toInt()}/$index$part.png');
  await expectLater(find.byType(MaterialApp), matchesGoldenFile(file));
}

void main() {
  for (final size in _sizes) {
    for (final scale in _scales) {
      testWidgets('sin cortes a ${size.width.toInt()} dp con texto al ${(scale * 100).toInt()} %', (tester) async {
        final failures = <String>[];
        for (final MapEntry(key: name, value: open) in _screens.entries) {
          tester.view.physicalSize = size * 3;
          tester.view.devicePixelRatio = 3;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          final repository = InMemoryProgressRepository();
          await _seed(ProgressService(repository, clock: _FakeClock(_now)));
          final previous = FlutterError.onError;
          final errors = <String>[];
          FlutterError.onError = (details) {
            errors.add(details.exceptionAsString().split('\n').first);
            if (Platform.environment['LAYOUT_DEBUG'] != null) {
              debugPrint('DETAIL $name ${size.width} $scale\n${details.toString().split('\n').take(40).join('\n')}');
            }
          };
          try {
            await pumpLudixa(
              tester,
              progress: repository,
              overrides: [clockProvider.overrideWithValue(_FakeClock(_now))],
            );
            await open(tester, tester.element(find.byType(Scaffold).first));
            await _shot(tester, size, scale, name, 'a');
            await _scrollThrough(tester);
            await _shot(tester, size, scale, name, 'b');
          } on Object catch (e) {
            errors.add('no se pudo abrir: ${e.toString().split('\n').first}');
          } finally {
            FlutterError.onError = previous;
          }
          if (errors.isNotEmpty) failures.add('$name: ${errors.toSet().join(' | ')}');
          await tester.pumpWidget(const SizedBox.shrink());
        }
        tester.view.reset();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        expect(failures, isEmpty, reason: failures.join('\n'));
      });
    }
  }

  group('goldens', skip: Platform.isMacOS ? null : 'goldens solo en macOS', () {
    Future<void> golden(WidgetTester tester, String screen, Size size, double scale, String file) async {
      tester.view.physicalSize = size * 3;
      tester.view.devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final repository = InMemoryProgressRepository();
      await _seed(ProgressService(repository, clock: _FakeClock(_now)));
      await pumpLudixa(tester, progress: repository, overrides: [clockProvider.overrideWithValue(_FakeClock(_now))]);
      await _screens[screen]!(tester, tester.element(find.byType(Scaffold).first));
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/layout/$file.png'));
    }

    for (final size in _sizes) {
      final w = size.width.toInt();
      testWidgets('inicio a $w dp', (tester) => golden(tester, 'inicio', size, 1, 'home_$w'));
      testWidgets('sudoku a $w dp', (tester) => golden(tester, 'partida de sudoku', size, 1, 'sudoku_$w'));
    }
    testWidgets(
      'inicio a 390 dp con texto al 200 %',
      (tester) => golden(tester, 'inicio', _sizes[1], 2, 'home_390_200'),
    );
    testWidgets(
      'progreso a 390 dp con texto al 200 %',
      (tester) => golden(tester, 'progreso', _sizes[1], 2, 'progress_390_200'),
    );
  });
}
