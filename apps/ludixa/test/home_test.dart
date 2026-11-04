import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:ludixa/features/home/home_page.dart';
import 'package:ludixa/features/play/play_providers.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

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

SessionRecord _won(GameId game, String level, {PuzzleMode mode = PuzzleMode.free, int minutes = 4}) =>
    SessionRecord(
      id: 'w${_ids++}',
      game: game,
      difficulty: Difficulty(level),
      mode: mode,
      startedAt: _now,
      challengeDay: mode == PuzzleMode.daily ? _today : null,
    ).finish(
      status: SessionStatus.won,
      elapsed: Duration(minutes: minutes),
      completedAt: _now.utc,
    );

Future<InMemoryProgressRepository> _pumpHome(
  WidgetTester tester, {
  Future<void> Function(ProgressService service)? seed,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final repository = InMemoryProgressRepository();
  await seed?.call(ProgressService(repository, clock: _FakeClock(_now)));
  await pumpLudixa(tester, progress: repository, overrides: [clockProvider.overrideWithValue(_FakeClock(_now))]);
  return repository;
}

/// Partida de Sudoku a medias, con su instantánea real.
Future<void> _seedInProgress(ProgressService service) async {
  final controller = SudokuController(game: SudokuGame(SudokuBank.at(SudokuDifficulty.easy, 0)), host: const _NoHost());
  final cell = List.generate(81, (i) => i).firstWhere((i) => !controller.game.isGiven(i));
  controller.game.place(cell, 7);
  final snap = controller.snapshot();
  await service.saveInProgress(
    SessionRecord(
      id: 'running',
      game: GameId.sudoku,
      difficulty: const Difficulty('easy'),
      mode: PuzzleMode.free,
      startedAt: _now,
      seedKey: 'free|abc',
    ).withState(snap.state, const Duration(seconds: 42)),
  );
}

void main() {
  testWidgets('primera vez: sin racha, sin Continuar, invitación al reto', (tester) async {
    await _pumpHome(tester);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Empieza con el reto de hoy'), findsOneWidget);
    expect(find.text('Jugar Sudoku'), findsOneWidget);
    expect(find.text('Continuar'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('^Racha')), findsNothing);
    expect(find.text('Sin medallas todavía'), findsNWidgets(3));
    expect(find.text('Tiempo jugado 0:00'), findsOneWidget);
  });

  testWidgets('partida en curso: Continuar retoma el estado exacto', (tester) async {
    await _pumpHome(tester, seed: _seedInProgress);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Sudoku · Fácil · 0:42'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    final page = tester.widget<SudokuGamePage>(find.byType(SudokuGamePage));
    final cell = List.generate(81, (i) => i).firstWhere((i) => !page.controller.game.isGiven(i));
    expect(page.controller.game.valueAt(cell), 7);
    expect(page.controller.elapsed, const Duration(seconds: 42));
  });

  testWidgets('reto completo: "Hoy: hecho ✓", tiempo total, racha y semana', (tester) async {
    await _pumpHome(
      tester,
      seed: (service) async {
        await service.recordResult(_won(GameId.sudoku, 'easy', mode: PuzzleMode.daily, minutes: 5));
        await service.recordResult(_won(GameId.minesweeper, 'beginner', mode: PuzzleMode.daily, minutes: 2));
        await service.recordResult(_won(GameId.wordSearch, 'easy', mode: PuzzleMode.daily, minutes: 3));
      },
    );
    expect(find.text('Hoy: hecho'), findsOneWidget);
    expect(find.text('Tiempo total 10:00'), findsOneWidget);
    expect(find.text('Días anteriores'), findsOneWidget);
    expect(find.bySemanticsLabel('Racha de 1 día'), findsOneWidget);
    expect(find.text('Tiempo jugado 10:00'), findsOneWidget);
    expect(find.text('1 partida · mejor 5:00'), findsOneWidget);
  });

  testWidgets('el catálogo muestra la maestría del mejor nivel', (tester) async {
    await _pumpHome(
      tester,
      seed: (service) async {
        for (var i = 0; i < 10; i++) {
          await service.recordResult(_won(GameId.sudoku, 'medium'));
        }
      },
    );
    expect(find.text('Maestría bronce en medio'), findsOneWidget);
    expect(find.bySemanticsLabel('Sudoku, Maestría bronce en medio'), findsOneWidget);
  });

  testWidgets('un juego abre su hoja; la primera partida pasa por el tutorial', (tester) async {
    await _pumpHome(tester);
    await tester.scrollUntilVisible(find.bySemanticsLabel(RegExp('^Buscaminas,')), 100);
    await tester.tap(find.bySemanticsLabel(RegExp('^Buscaminas,')));
    await tester.pumpAndSettle();
    expect(find.text('Buscaminas: elige la dificultad'), findsOneWidget);
    await tester.tap(find.text('Empezar · Principiante'));
    await tester.pumpAndSettle();
    expect(find.text('Saltar tutorial'), findsOneWidget);
    await tester.tap(find.text('Saltar tutorial'));
    await tester.pumpAndSettle();
    expect(find.text('Toca cualquier celda para empezar'), findsOneWidget);
  });

  testWidgets('bajo 360 dp el catálogo pasa a filas, sin desbordes', (tester) async {
    await _pumpHome(tester, size: const Size(320, 640));
    expect(tester.takeException(), isNull);
    final sudoku = tester.getRect(find.bySemanticsLabel(RegExp('^Sudoku,')));
    final mines = tester.getRect(find.bySemanticsLabel(RegExp('^Buscaminas,')));
    expect(mines.top, greaterThan(sudoku.bottom - 1));
  });

  group('goldens', skip: Platform.isMacOS ? null : 'goldens solo en macOS', () {
    testWidgets('primera vez', (tester) async {
      await _pumpHome(tester);
      await expectLater(find.byType(HomePage), matchesGoldenFile('goldens/home_first_time.png'));
    });

    testWidgets('partida en curso', (tester) async {
      await _pumpHome(
        tester,
        seed: (service) async {
          await service.recordResult(_won(GameId.sudoku, 'easy', mode: PuzzleMode.daily));
          await _seedInProgress(service);
        },
      );
      await expectLater(find.byType(HomePage), matchesGoldenFile('goldens/home_in_progress.png'));
    });

    testWidgets('reto completo', (tester) async {
      await _pumpHome(
        tester,
        seed: (service) async {
          await service.recordResult(_won(GameId.sudoku, 'easy', mode: PuzzleMode.daily, minutes: 5));
          await service.recordResult(_won(GameId.minesweeper, 'beginner', mode: PuzzleMode.daily, minutes: 2));
          await service.recordResult(_won(GameId.wordSearch, 'easy', mode: PuzzleMode.daily, minutes: 3));
        },
      );
      await expectLater(find.byType(HomePage), matchesGoldenFile('goldens/home_daily_done.png'));
    });
  });
}

class _NoHost implements GameHost {
  @override
  bool get rewardedAvailable => false;

  const _NoHost();

  @override
  int get freeHintsLeft => 0;

  @override
  Future<HintGrant> requestHint() async => const HintDenied(HintDenial.unavailable);

  @override
  Future<RescueOutcome> requestRescue() async => RescueOutcome.unavailable;

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async {}

  @override
  Future<void> reportResult(GameResult result) async {}

  @override
  Future<PauseChoice> showPause() async => PauseChoice.resume;

  @override
  void playAgain() {}
}
