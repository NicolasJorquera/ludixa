import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:go_router/go_router.dart';
import 'package:ludixa/features/daily/daily_page.dart';
import 'package:ludixa/features/play/play_providers.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'support/test_app.dart';

final class _FakeClock implements Clock {
  _FakeClock(this.current);

  LocalNow current;

  @override
  LocalNow now() => current;
}

LocalNow _at(int day, {int hour = 10, int minute = 0, int second = 0}) =>
    LocalNow(utc: DateTime.utc(2026, 11, day, hour + 3, minute, second), offsetMinutes: -180);

var _ids = 0;

SessionRecord _won(GameId game, String level, LocalNow when, {PuzzleMode mode = PuzzleMode.daily, LocalDay? day}) =>
    SessionRecord(
      id: 'd${_ids++}',
      game: game,
      difficulty: Difficulty(level),
      mode: mode,
      startedAt: when,
      challengeDay: day ?? when.day,
    ).finish(status: SessionStatus.won, elapsed: const Duration(minutes: 4, seconds: 12), completedAt: when.utc);

Future<(_FakeClock, InMemoryProgressRepository)> _pumpDaily(
  WidgetTester tester, {
  LocalNow? now,
  Future<void> Function(ProgressService service)? seed,
  List<Locale> locales = const [Locale('es', 'CL')],
}) async {
  tester.view.physicalSize = const Size(390, 1400) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final clock = _FakeClock(now ?? _at(3));
  final repository = InMemoryProgressRepository();
  await seed?.call(ProgressService(repository, clock: clock));
  await pumpLudixa(
    tester,
    deviceLocales: locales,
    progress: repository,
    overrides: [clockProvider.overrideWithValue(clock)],
  );
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/daily');
  await tester.pumpAndSettle();
  return (clock, repository);
}

void main() {
  testWidgets('hoy: fecha, sin racha, los 3 retos con nivel y tema, y el primero como principal', (tester) async {
    await _pumpDaily(tester);
    expect(find.byType(DailyPage), findsOneWidget);
    expect(find.text('Martes, 3 de noviembre'), findsOneWidget);
    expect(find.text('Sin racha todavía'), findsOneWidget);
    expect(find.text('Sudoku · Fácil'), findsOneWidget);
    expect(find.text('Buscaminas · Principiante'), findsOneWidget);
    expect(find.textContaining('Sopa de letras · Fácil · '), findsOneWidget);
    expect(find.text('Jugar'), findsNWidgets(3));
  });

  testWidgets('día completo: "Hoy: hecho", tiempos y racha', (tester) async {
    await _pumpDaily(
      tester,
      seed: (service) async {
        for (final (game, level) in [
          (GameId.sudoku, 'easy'),
          (GameId.minesweeper, 'beginner'),
          (GameId.wordSearch, 'easy'),
        ]) {
          await service.recordResult(_won(game, level, _at(3)));
        }
      },
    );
    expect(find.text('Hoy: hecho'), findsOneWidget);
    expect(find.textContaining('Próximo reto a las'), findsOneWidget);
    expect(find.text('Completado en 4:12'), findsNWidgets(3));
    expect(find.text('1 día seguido'), findsOneWidget);
    expect(find.bySemanticsLabel('3 de noviembre, 3 de 3 retos, hoy, día perfecto'), findsOneWidget);
  });

  testWidgets('racha rota: texto neutro con la racha anterior', (tester) async {
    await _pumpDaily(
      tester,
      now: _at(9),
      seed: (service) async {
        for (final d in [2, 3, 4]) {
          await service.recordResult(_won(GameId.sudoku, 'easy', _at(d)));
        }
      },
    );
    expect(find.text('Racha anterior: 3 días. ¡A por otra!'), findsOneWidget);
  });

  testWidgets('el calendario empieza el lunes en es y el domingo en en-US', (tester) async {
    await _pumpDaily(tester);
    final es = tester.widgetList<Text>(find.descendant(of: find.byType(Row), matching: find.text('L'))).length;
    expect(es, greaterThan(0));
    expect(find.bySemanticsLabel('3 de noviembre, 0 de 3 retos, hoy'), findsOneWidget);
  });

  testWidgets('en inglés de EE. UU. la semana empieza el domingo', (tester) async {
    await _pumpDaily(tester, locales: const [Locale('en', 'US')]);
    expect(find.bySemanticsLabel('November 3, 0 of 3 challenges, today'), findsOneWidget);
    // El 1 de noviembre de 2026 es domingo: con la semana en domingo no hay
    // columnas vacías antes del día 1, y "1" queda bajo la primera inicial "S".
    final one = tester.getCenter(find.bySemanticsLabel(RegExp(r'^November 1,')));
    final firstHeader = tester.getCenter(find.text('S').first);
    expect((one.dx - firstHeader.dx).abs(), lessThan(2));
  });

  testWidgets('archivo: un reto pasado se juega sin sumar a la racha y deja marca hueca', (tester) async {
    final (_, repository) = await _pumpDaily(tester);
    await tester.tap(find.text('Días anteriores'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No suman a la racha'), findsOneWidget);
    await tester.tap(find.text('Lunes, 2 de noviembre'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jugar').first);
    await tester.pumpAndSettle();
    final c = tester.widget<SudokuGamePage>(find.byType(SudokuGamePage)).controller;
    for (var i = 0; i < 81; i++) {
      if (!c.game.isGiven(i) && c.game.valueAt(i) == 0) {
        c.tapCell(i);
        c.tapDigit(c.game.puzzle.solution[i]);
      }
    }
    await tester.pumpAndSettle();
    final day = await repository.day(LocalDay(2026, 11, 2));
    expect(day!.archiveCompleted, {GameId.sudoku});
    expect(day.completed, isEmpty);
    expect((await repository.streak()).current, 0);
  });

  testWidgets('al pasar la medianoche con la pantalla abierta, se refresca sola', (tester) async {
    final (clock, _) = await _pumpDaily(tester, now: _at(3, hour: 23, minute: 59, second: 50));
    expect(find.text('Martes, 3 de noviembre'), findsOneWidget);
    clock.current = _at(4, hour: 0, minute: 0, second: 5);
    await tester.pump(const Duration(seconds: 12));
    await tester.pumpAndSettle();
    expect(find.text('Miércoles, 4 de noviembre'), findsOneWidget);
  });

  group('goldens', skip: goldensSkip, () {
    testWidgets('reto con progreso', (tester) async {
      await _pumpDaily(
        tester,
        seed: (service) async {
          await service.recordResult(_won(GameId.sudoku, 'easy', _at(1)));
          await service.recordResult(_won(GameId.sudoku, 'easy', _at(2)));
          await service.recordResult(_won(GameId.minesweeper, 'beginner', _at(2)));
          await service.recordResult(_won(GameId.wordSearch, 'easy', _at(2)));
          await service.recordResult(_won(GameId.sudoku, 'easy', _at(3)));
          await service.recordResult(
            _won(GameId.minesweeper, 'beginner', _at(3), mode: PuzzleMode.archive, day: LocalDay(2026, 11, 1)),
          );
        },
      );
      await expectLater(find.byType(DailyPage), matchesGoldenFile('goldens/daily.png'));
    });
  });
}
