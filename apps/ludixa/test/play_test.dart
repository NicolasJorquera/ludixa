import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:game_sudoku/game_sudoku.dart';
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
LocalNow _tuesday() => LocalNow(utc: DateTime.utc(2026, 11, 3, 13), offsetMinutes: -180);

SessionRecord _session({PuzzleMode mode = PuzzleMode.free, LocalDay? day}) => SessionRecord(
  id: 'x',
  game: GameId.sudoku,
  difficulty: const Difficulty('easy'),
  mode: mode,
  startedAt: _tuesday(),
  challengeDay: day,
);

/// Monta la app con un reloj fijo y abre una pantalla con su contexto.
Future<BuildContext> _pumpApp(WidgetTester tester) async {
  await pumpLudixa(tester, overrides: [clockProvider.overrideWithValue(_FakeClock(_tuesday()))]);
  return tester.element(find.byType(Scaffold).first);
}

void main() {
  group('host de la app', () {
    late ProgressService service;
    setUp(() => service = ProgressService(InMemoryProgressRepository(), clock: _FakeClock(_tuesday())));

    test('3 pistas gratis por puzzle; luego no hay (los videos llegan en H5)', () async {
      final host = AppGameHost(
        service: service,
        session: _session(),
        onShowPause: () async => PauseChoice.resume,
        onWon: (_) {},
        onPlayAgain: () {},
      );
      final grants = [for (var i = 0; i < 4; i++) await host.requestHint()];
      expect(grants.take(3).every((g) => g is HintGranted), isTrue);
      expect(grants.last, isA<HintDenied>());
      expect(host.freeHintsLeft, 0);
      expect(await host.requestRescue(), RescueOutcome.unavailable);
    });

    test('las instantáneas quedan en el progreso como partida en curso', () async {
      final host = AppGameHost(
        service: service,
        session: _session(),
        onShowPause: () async => PauseChoice.resume,
        onWon: (_) {},
        onPlayAgain: () {},
      );
      await host.saveSnapshot(const SessionSnapshot(state: {'v': 1}, elapsed: Duration(seconds: 12)));
      final saved = (await service.repository.session('x'))!;
      expect(saved.status, SessionStatus.inProgress);
      expect(saved.elapsed, const Duration(seconds: 12));
    });

    test('ganar registra y avisa con récord, maestría y racha; perder solo registra', () async {
      FinishedGame? finished;
      final host = AppGameHost(
        service: service,
        session: _session(mode: PuzzleMode.daily, day: LocalDay(2026, 11, 3)),
        onShowPause: () async => PauseChoice.resume,
        onWon: (f) => finished = f,
        onPlayAgain: () {},
      );
      await host.reportResult(const GameResult(outcome: GameOutcome.won, elapsed: Duration(minutes: 4)));
      expect(finished!.winsAtLevel, 1);
      expect((finished!.streakBefore, finished!.streakAfter, finished!.dailyDone), (0, 1, 1));
      expect(finished!.bestAfter, const Duration(minutes: 4));
      expect(finished!.isNewRecord, isFalse);
      expect(finished!.outcome.newAchievements, contains(AchievementId.firstPuzzle));

      FinishedGame? second;
      final lost = AppGameHost(
        service: service,
        session: SessionRecord(
          id: 'y',
          game: GameId.minesweeper,
          difficulty: const Difficulty('beginner'),
          mode: PuzzleMode.free,
          startedAt: _tuesday(),
        ),
        onShowPause: () async => PauseChoice.resume,
        onWon: (f) => second = f,
        onPlayAgain: () {},
      );
      await lost.reportResult(const GameResult(outcome: GameOutcome.lost, elapsed: Duration(minutes: 1)));
      expect(second, isNull);
      expect((await service.repository.session('y'))!.status, SessionStatus.lost);
    });
  });

  testWidgets('la hoja de dificultad marca el último nivel y lo recuerda', (tester) async {
    final context = await _pumpApp(tester);
    final store = InMemoryLastDifficultyStore();
    final module = SudokuModule();
    Difficulty? chosen;
    Future<void> open() async {
      final future = showDifficultySheet(context, module, store);
      await tester.pumpAndSettle();
      final result = future;
      await tester.tap(find.text('Medio'));
      await tester.pump();
      expect(find.text('Empezar · Medio'), findsOneWidget);
      await tester.tap(find.text('Empezar · Medio'));
      await tester.pumpAndSettle();
      chosen = await result;
    }

    await open();
    expect(chosen, const Difficulty('medium'));
    expect(store.load(GameId.sudoku), const Difficulty('medium'));
    unawaited(showDifficultySheet(context, module, store));
    await tester.pumpAndSettle();
    expect(find.text('Sudoku: elige la dificultad'), findsOneWidget);
    expect(find.text('Empezar · Medio'), findsOneWidget);
    expect(find.textContaining('Sin partidas'), findsNWidgets(4));
  });

  group('pausa', () {
    Future<PauseChoice?> pause(WidgetTester tester, Future<void> Function() act) async {
      final context = await _pumpApp(tester);
      PauseChoice? choice;
      unawaited(PauseScreen.show(context, SudokuModule(), const _Host()).then((c) => choice = c));
      await tester.pumpAndSettle();
      expect(find.text('Tablero oculto en pausa'), findsOneWidget);
      await act();
      await tester.pumpAndSettle();
      return choice;
    }

    testWidgets('reanudar', (tester) async {
      expect(await pause(tester, () => tester.tap(find.text('Reanudar'))), PauseChoice.resume);
    });

    testWidgets('el gesto atrás equivale a reanudar', (tester) async {
      expect(await pause(tester, () => tester.binding.handlePopRoute()), PauseChoice.resume);
    });

    testWidgets('reiniciar pide confirmación dentro de la pantalla', (tester) async {
      final choice = await pause(tester, () async {
        await tester.tap(find.text('Reiniciar'));
        await tester.pump();
        expect(find.text('Se perderá el avance de este puzzle.'), findsOneWidget);
        await tester.tap(find.text('Cancelar'));
        await tester.pump();
        expect(find.text('Se perderá el avance de este puzzle.'), findsNothing);
        await tester.tap(find.text('Reiniciar'));
        await tester.pump();
        await tester.tap(find.text('Sí, reiniciar'));
      });
      expect(choice, PauseChoice.restart);
    });

    testWidgets('guardar y salir', (tester) async {
      final choice = await pause(tester, () async {
        await tester.scrollUntilVisible(find.text('Guardar y salir'), 100);
        await tester.tap(find.text('Guardar y salir'));
      });
      expect(choice, PauseChoice.exit);
    });

    testWidgets('abre los ajustes del juego y el tutorial', (tester) async {
      await pause(tester, () async {
        await tester.tap(find.text('Ajustes del juego'));
        await tester.pumpAndSettle();
        expect(find.text('Celda primero'), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cómo se juega'));
        await tester.pumpAndSettle();
        expect(find.text('Saltar tutorial'), findsOneWidget);
      });
    });
  });

  group('resultado', () {
    FinishedGame finished({
      required PuzzleMode mode,
      Duration? bestBefore,
      List<AchievementId> achievements = const [],
    }) {
      final s = _session(mode: mode, day: mode == PuzzleMode.daily ? LocalDay(2026, 11, 3) : null).finish(
        status: SessionStatus.won,
        elapsed: const Duration(minutes: 3, seconds: 5),
        completedAt: DateTime.utc(2026, 11, 3, 13, 4),
      );
      return FinishedGame(
        session: s,
        outcome: RecordOutcome(newAchievements: achievements),
        bestBefore: bestBefore,
        bestAfter: const Duration(minutes: 3, seconds: 5),
        winsAtLevel: 12,
        streakBefore: 11,
        streakAfter: 12,
        dailyDone: 2,
      );
    }

    Future<void> show(
      WidgetTester tester,
      FinishedGame f, {
      VoidCallback? onPlayAgain,
      VoidCallback? onNextDaily,
    }) async {
      final context = await _pumpApp(tester);
      unawaited(
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ResultPage(
              module: SudokuModule(),
              finished: f,
              levelLabel: 'Fácil',
              onHome: () {},
              onPlayAgain: onPlayAgain,
              onNextDaily: onNextDaily,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('partida libre: récord nuevo, sin ayuda, maestría y otra partida', (tester) async {
      var again = 0;
      await show(
        tester,
        finished(mode: PuzzleMode.free, bestBefore: const Duration(minutes: 4)),
        onPlayAgain: () => again++,
      );
      expect(find.text('¡Resuelto!'), findsOneWidget);
      expect(find.text('Nuevo récord'), findsOneWidget);
      expect(find.text('Sin ayuda'), findsOneWidget);
      expect(find.bySemanticsLabel('Tiempo 3:05'), findsOneWidget);
      expect(find.text('Bronce'), findsOneWidget);
      expect(find.text('13 partidas más para Plata'), findsOneWidget);
      await tester.tap(find.text('Otra partida en Fácil'));
      expect(again, 1);
    });

    testWidgets('reto diario: avance del día, racha y siguiente reto; logro desbloqueado', (tester) async {
      var next = 0;
      await show(
        tester,
        finished(mode: PuzzleMode.daily, achievements: [AchievementId.streak7]),
        onNextDaily: () => next++,
      );
      expect(find.text('Reto: 2 de 3 · racha 11 → 12'), findsOneWidget);
      expect(find.text('Racha de 7 días'), findsOneWidget);
      expect(find.text('Nuevo récord'), findsNothing);
      expect(find.text('Otra partida en Fácil'), findsNothing);
      await tester.tap(find.text('Siguiente reto'));
      expect(next, 1);
    });
  });

  testWidgets('flujo completo: reto de Sudoku de hoy → resultado → siguiente reto', (tester) async {
    final context = await _pumpApp(tester);
    final container = ProviderScope.containerOf(context);
    final module = container.read(gameModulesProvider)[GameId.sudoku]!;
    unawaited(GameFlow.play(context, module, GameFlow.dailyRequest(module, LocalDay(2026, 11, 3))));
    await tester.pumpAndSettle();
    final page = tester.widget<SudokuGamePage>(find.byType(SudokuGamePage));
    final c = page.controller;
    for (var i = 0; i < 81; i++) {
      if (!c.game.isGiven(i) && c.game.valueAt(i) == 0) {
        c.tapCell(i);
        c.tapDigit(c.game.puzzle.solution[i]);
      }
    }
    await tester.pumpAndSettle();
    expect(find.text('¡Resuelto!'), findsOneWidget);
    expect(find.text('Reto: 1 de 3 · racha 0 → 1'), findsOneWidget);
    expect(find.text('Primer puzzle'), findsOneWidget);
    final saved = await container.read(progressServiceProvider).repository.sessions();
    expect(saved.single.status, SessionStatus.won);
    await tester.tap(find.text('Siguiente reto'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Empieza aquí'), findsOneWidget);
  });
}

class _Host implements GameHost {
  const _Host();

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
