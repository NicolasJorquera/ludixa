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
import 'package:monetization/monetization.dart';
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

    AppGameHost hostWith(RewardedHints? rewards, {SessionRecord? session}) => AppGameHost(
      service: service,
      session: session ?? _session(),
      onShowPause: () async => PauseChoice.resume,
      onWon: (_) {},
      onPlayAgain: () {},
      rewards: rewards,
    );

    test('2 pistas gratis, después hasta 3 con video y luego ninguna (PRD)', () async {
      final rewards = _FakeRewards();
      final host = hostWith(rewards);
      final sources = <Object>[];
      for (var i = 0; i < 6; i++) {
        sources.add(switch (await host.requestHint()) {
          HintGranted(:final source) => source,
          HintDenied(:final reason) => reason,
        });
      }
      expect(sources, [
        HintSource.free,
        HintSource.free,
        HintSource.rewarded,
        HintSource.rewarded,
        HintSource.rewarded,
        HintDenial.limitReached,
      ]);
      expect(rewards.offers.map((o) => o.videosLeft), [3, 2, 1]);
      expect(host.freeHintsLeft, 0);
    });

    test('un video cerrado antes no da pista ni gasta una de video', () async {
      final rewards = _FakeRewards(outcome: RewardedOutcome.dismissed);
      final host = hostWith(rewards);
      await host.requestHint();
      await host.requestHint();
      expect(await host.requestHint(), isA<HintDenied>().having((d) => d.reason, 'motivo', HintDenial.declined));
      rewards.outcome = RewardedOutcome.earned;
      await host.requestHint();
      expect(rewards.offers.last.videosLeft, 3);
    });

    test('elegir "Ahora no" no gasta nada', () async {
      final rewards = _FakeRewards(choice: HintOfferChoice.cancel);
      final host = hostWith(rewards);
      await host.requestHint();
      await host.requestHint();
      expect(await host.requestHint(), isA<HintDenied>());
      expect(rewards.videosShown, 0);
    });

    test('sin videos se ofrece la cortesía, 1 al día', () async {
      final rewards = _FakeRewards(videoReady: false, choice: HintOfferChoice.courtesy);
      final host = hostWith(rewards);
      await host.requestHint();
      await host.requestHint();
      expect(await host.requestHint(), isA<HintGranted>().having((g) => g.source, 'origen', HintSource.courtesy));
      expect(rewards.offers.single.courtesyAvailable, isTrue);
      final second = await host.requestHint();
      expect(rewards.offers.last.courtesyAvailable, isFalse);
      expect(second, isA<HintDenied>().having((d) => d.reason, 'motivo', HintDenial.unavailable));
      expect(rewards.videosShown, 0);
    });

    test('con video disponible no se ofrece la cortesía', () async {
      final rewards = _FakeRewards(choice: HintOfferChoice.courtesy);
      final host = hostWith(rewards);
      await host.requestHint();
      await host.requestHint();
      expect(rewards.offers, isEmpty);
      expect(await host.requestHint(), isA<HintDenied>());
      expect(rewards.offers.single.courtesyAvailable, isFalse);
      expect(rewards.courtesyLeft, isTrue);
    });

    test('al retomar, las pistas gratis y de video ya usadas no vuelven', () async {
      final saved = _session().withState(const {'v': 1}, Duration.zero, freeHints: 2, rewardedHints: 3);
      final host = hostWith(_FakeRewards(), session: saved);
      expect(host.freeHintsLeft, 0);
      expect(await host.requestHint(), isA<HintDenied>().having((d) => d.reason, 'motivo', HintDenial.limitReached));
    });

    test('sin videos de la app (tutorial, pruebas): después de las gratis no hay más', () async {
      final host = hostWith(null);
      await host.requestHint();
      await host.requestHint();
      expect(await host.requestHint(), isA<HintDenied>().having((d) => d.reason, 'motivo', HintDenial.unavailable));
      expect(host.rewardedAvailable, isFalse);
      expect(await host.requestRescue(), RescueOutcome.unavailable);
    });

    test('rescate del Buscaminas: va directo al video y solo si hay uno', () async {
      final rewards = _FakeRewards();
      final host = hostWith(rewards);
      expect(host.rewardedAvailable, isTrue);
      expect(await host.requestRescue(), RescueOutcome.granted);
      rewards.outcome = RewardedOutcome.dismissed;
      expect(await host.requestRescue(), RescueOutcome.declined);
      rewards.videoReady = false;
      expect(await host.requestRescue(), RescueOutcome.unavailable);
      expect(rewards.offers, isEmpty);
      expect(rewards.videosShown, 2);
    });

    SessionSnapshot snap(int v) => SessionSnapshot(
      state: {'v': v},
      elapsed: Duration(seconds: v),
    );

    test('las instantáneas quedan en el progreso como partida en curso', () async {
      final host = AppGameHost(
        service: service,
        session: _session(),
        onShowPause: () async => PauseChoice.resume,
        onWon: (_) {},
        onPlayAgain: () {},
      );
      await host.saveSnapshot(snap(12));
      await host.flush();
      final saved = (await service.repository.session('x'))!;
      expect(saved.status, SessionStatus.inProgress);
      expect(saved.elapsed, const Duration(seconds: 12));
    });

    test('jugadas seguidas se escriben una vez, con la última, a los 300 ms', () async {
      var writes = 0;
      final host = AppGameHost(
        service: service,
        session: _session(),
        onShowPause: () async => PauseChoice.resume,
        onWon: (_) {},
        onPlayAgain: () {},
        onChanged: () => writes++,
        saveDelay: const Duration(milliseconds: 60),
      );
      for (var v = 1; v <= 3; v++) {
        await host.saveSnapshot(snap(v));
      }
      expect(await service.repository.session('x'), isNull);
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(writes, 1);
      expect((await service.repository.session('x'))!.state, {'v': 3});
    });

    test('en segundo plano cada instantánea se escribe de inmediato', () async {
      final host = AppGameHost(
        service: service,
        session: _session(),
        onShowPause: () async => PauseChoice.resume,
        onWon: (_) {},
        onPlayAgain: () {},
        saveDelay: const Duration(hours: 1),
      );
      unawaited(host.saveSnapshot(snap(1)));
      await host.enterBackground();
      expect((await service.repository.session('x'))!.state, {'v': 1});
      await host.saveSnapshot(snap(2));
      expect((await service.repository.session('x'))!.state, {'v': 2});
      host.enterForeground();
      await host.saveSnapshot(snap(3));
      expect((await service.repository.session('x'))!.state, {'v': 2});
    });

    test('al retomar, las pistas gratis usadas no vuelven', () async {
      final first = AppGameHost(
        service: service,
        session: _session(),
        onShowPause: () async => PauseChoice.resume,
        onWon: (_) {},
        onPlayAgain: () {},
      );
      await first.requestHint();
      await first.saveSnapshot(const SessionSnapshot(state: {'v': 1}, elapsed: Duration(seconds: 5), freeHintsUsed: 1));
      await first.flush();
      final saved = (await service.repository.session('x'))!;
      expect(saved.freeHints, 1);
      final resumed = AppGameHost(
        service: service,
        session: saved,
        onShowPause: () async => PauseChoice.resume,
        onWon: (_) {},
        onPlayAgain: () {},
      );
      expect(resumed.freeHintsLeft, 1);
    });

    test('una instantánea pendiente nunca pisa una partida terminada', () async {
      final host = AppGameHost(
        service: service,
        session: _session(),
        onShowPause: () async => PauseChoice.resume,
        onWon: (_) {},
        onPlayAgain: () {},
        saveDelay: const Duration(milliseconds: 20),
      );
      await host.saveSnapshot(snap(1));
      await host.flush();
      await host.saveSnapshot(snap(2));
      await host.reportResult(const GameResult(outcome: GameOutcome.won, elapsed: Duration(minutes: 4)));
      await host.saveSnapshot(snap(3));
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await host.flush();
      expect((await service.repository.session('x'))!.status, SessionStatus.won);
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

  testWidgets('medianoche: el reto empezado ayer cuenta para ayer y "Siguiente reto" abre el de hoy', (tester) async {
    final clock = _FakeClock(LocalNow(utc: DateTime.utc(2026, 11, 4, 2, 59), offsetMinutes: -180)); // 3/11 23:59
    await pumpLudixa(tester, overrides: [clockProvider.overrideWithValue(clock)]);
    final context = tester.element(find.byType(Scaffold).first);
    final container = ProviderScope.containerOf(context);
    final module = container.read(gameModulesProvider)[GameId.sudoku]!;
    unawaited(GameFlow.play(context, module, GameFlow.dailyRequest(module, LocalDay(2026, 11, 3))));
    await tester.pumpAndSettle();
    clock.current = LocalNow(utc: DateTime.utc(2026, 11, 4, 3, 1), offsetMinutes: -180); // 4/11 00:01
    final c = tester.widget<SudokuGamePage>(find.byType(SudokuGamePage)).controller;
    for (var i = 0; i < 81; i++) {
      if (!c.game.isGiven(i) && c.game.valueAt(i) == 0) {
        c.tapCell(i);
        c.tapDigit(c.game.puzzle.solution[i]);
      }
    }
    await tester.pumpAndSettle();
    expect(find.text('Reto: 1 de 3 · racha 0 → 1'), findsOneWidget);
    final day = await container.read(progressServiceProvider).repository.day(LocalDay(2026, 11, 3));
    expect(day!.completed, {GameId.sudoku});
    await tester.tap(find.text('Siguiente reto'));
    await tester.pumpAndSettle();
    final next = tester.widget<GameSessionPage>(find.byType(GameSessionPage));
    expect(next.request.day, LocalDay(2026, 11, 4));
    expect(next.module.id, GameId.sudoku); // hoy no se jugó ninguno: empieza por el Sudoku
  });
}

class _Host implements GameHost {
  @override
  bool get rewardedAvailable => false;

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

final class _FakeRewards implements RewardedHints {
  _FakeRewards({this.videoReady = true, this.outcome = RewardedOutcome.earned, this.choice = HintOfferChoice.video});

  @override
  bool videoReady;
  RewardedOutcome outcome;
  HintOfferChoice choice;
  bool courtesyLeft = true;
  int videosShown = 0;
  final offers = <HintOffer>[];

  @override
  Future<RewardedOutcome> showVideo() async {
    videosShown++;
    return outcome;
  }

  @override
  bool get courtesyAvailable => courtesyLeft;

  @override
  void useCourtesy() => courtesyLeft = false;

  @override
  Future<HintOfferChoice> offerHint(HintOffer offer) async {
    offers.add(offer);
    return choice;
  }
}
