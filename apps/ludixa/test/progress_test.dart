import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ludixa/features/daily/daily_page.dart';
import 'package:ludixa/features/play/play_providers.dart';
import 'package:ludixa/features/progress/progress_page.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'support/test_app.dart';

final class _FakeClock implements Clock {
  _FakeClock(this.current);

  LocalNow current;

  @override
  LocalNow now() => current;
}

LocalNow _at(int day, {int hour = 10}) => LocalNow(utc: DateTime.utc(2026, 11, day, hour + 3), offsetMinutes: -180);

var _ids = 0;

SessionRecord _finished(
  GameId game,
  String level,
  LocalNow when, {
  SessionStatus status = SessionStatus.won,
  Duration elapsed = const Duration(minutes: 4, seconds: 12),
  PuzzleMode mode = PuzzleMode.free,
}) => SessionRecord(
  id: 'p${_ids++}',
  game: game,
  difficulty: Difficulty(level),
  mode: mode,
  startedAt: when,
  challengeDay: mode == PuzzleMode.free ? null : when.day,
).finish(status: status, elapsed: elapsed, completedAt: when.utc);

/// Sudoku Fácil: 2 ganadas (una del reto). Sudoku Medio: 1 ganada.
/// Buscaminas Principiante: 3 ganadas y 2 perdidas.
Future<void> _seed(ProgressService service) async {
  await service.recordResult(_finished(GameId.sudoku, 'easy', _at(2), mode: PuzzleMode.daily));
  await service.recordResult(_finished(GameId.sudoku, 'easy', _at(3), elapsed: const Duration(minutes: 6)));
  await service.recordResult(_finished(GameId.sudoku, 'medium', _at(3, hour: 11)));
  for (final (i, status) in [
    SessionStatus.won,
    SessionStatus.lost,
    SessionStatus.won,
    SessionStatus.lost,
    SessionStatus.won,
  ].indexed) {
    await service.recordResult(
      _finished(
        GameId.minesweeper,
        'beginner',
        _at(3, hour: 12 + i),
        status: status,
        elapsed: const Duration(minutes: 1),
      ),
    );
  }
}

Future<InMemoryProgressRepository> _pumpProgress(
  WidgetTester tester, {
  Future<void> Function(ProgressService service)? seed,
}) async {
  tester.view.physicalSize = const Size(390, 1100) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final clock = _FakeClock(_at(3, hour: 20));
  final repository = InMemoryProgressRepository();
  await seed?.call(ProgressService(repository, clock: clock));
  await pumpLudixa(
    tester,
    overrides: [clockProvider.overrideWithValue(clock), progressRepositoryProvider.overrideWithValue(repository)],
  );
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/progress');
  await tester.pumpAndSettle();
  return repository;
}

void main() {
  testWidgets('sin partidas: estado vacío que lleva al reto de hoy', (tester) async {
    await _pumpProgress(tester);
    expect(find.byType(ProgressPage), findsOneWidget);
    expect(find.text('Tus estadísticas aparecerán al completar tu primer puzzle.'), findsOneWidget);
    await tester.tap(find.text('Ir al reto de hoy'));
    await tester.pumpAndSettle();
    expect(find.byType(DailyPage), findsOneWidget);
  });

  testWidgets('una derrota ya muestra estadísticas', (tester) async {
    await _pumpProgress(
      tester,
      seed: (service) => service.recordResult(
        _finished(
          GameId.minesweeper,
          'beginner',
          _at(3),
          status: SessionStatus.lost,
          elapsed: const Duration(seconds: 40),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Puzzles completados. 0'), findsOneWidget);
    await tester.tap(find.text('Buscaminas'));
    await tester.pumpAndSettle();
    expect(find.text('0 (0\u00A0%)'), findsOneWidget);
  });

  testWidgets('totales y tabla por nivel, con "Aún sin jugar"', (tester) async {
    await _pumpProgress(tester, seed: _seed);
    expect(find.bySemanticsLabel('Puzzles completados. 6'), findsOneWidget);
    expect(find.bySemanticsLabel('Racha. 1. Mejor: 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Días perfectos. 0'), findsOneWidget);
    // Sudoku: 4:12 + 6:00 + 4:12 + Buscaminas 5 × 1:00 = 19:24.
    expect(find.bySemanticsLabel('Tiempo total. 19:24'), findsOneWidget);

    for (final header in ['Nivel', 'Partidas', 'Ganadas', 'Mejor', 'Media']) {
      expect(find.text(header), findsOneWidget);
    }
    expect(find.text('Fácil'), findsOneWidget);
    expect(find.text('4:12'), findsNWidgets(3)); // mejor de Fácil; mejor y media de Medio
    expect(find.text('5:06'), findsOneWidget); // media de Fácil
    expect(find.text('Aún sin jugar'), findsNWidgets(2)); // Difícil y Experto

    await tester.tap(find.text('Buscaminas'));
    await tester.pumpAndSettle();
    // intl separa el signo con un espacio duro.
    expect(find.text('3 (60\u00A0%)'), findsOneWidget);
  });

  testWidgets('la tabla se expone como tabla con encabezados de columna', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpProgress(tester, seed: _seed);
    final roles = <SemanticsRole>[];
    void visit(SemanticsNode node) {
      roles.add(node.getSemanticsData().role);
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    visit(tester.getSemantics(find.byType(Table)));
    expect(roles.where((r) => r == SemanticsRole.table), hasLength(1));
    expect(roles.where((r) => r == SemanticsRole.columnHeader), hasLength(5));
    expect(roles.where((r) => r == SemanticsRole.row), isNotEmpty);
    // Cada dato dice su columna: TalkBack no anuncia tablas de Flutter.
    expect(find.bySemanticsLabel('Partidas: 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Media: 5:06'), findsOneWidget);
    expect(find.bySemanticsLabel('Mejor: Sin tiempo'), findsNWidgets(2));
    semantics.dispose();
  });

  testWidgets('mantener pulsado un nivel lo reinicia tras confirmar, sin tocar los otros', (tester) async {
    final repository = await _pumpProgress(tester, seed: _seed);
    await tester.longPress(find.text('Fácil'));
    await tester.pumpAndSettle();
    expect(find.text('¿Reiniciar Sudoku · Fácil?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('5:06'), findsOneWidget);

    await tester.longPress(find.text('Fácil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reiniciar'));
    await tester.pumpAndSettle();
    expect(find.text('Estadísticas de Fácil reiniciadas'), findsOneWidget);
    expect(find.text('5:06'), findsNothing);
    expect(find.text('Aún sin jugar'), findsNWidgets(3));
    expect(find.text('4:12'), findsNWidgets(2)); // Medio sigue igual
    // Los totales son de todo el historial.
    expect(find.bySemanticsLabel('Puzzles completados. 6'), findsOneWidget);
    expect(await repository.sessions(), hasLength(8));
  });

  testWidgets('logros: avance, pendientes y hoja con la descripción', (tester) async {
    await _pumpProgress(tester, seed: _seed);
    await tester.tap(find.text('Logros'));
    await tester.pumpAndSettle();
    expect(find.text('2 de 18 logros'), findsOneWidget);
    expect(find.bySemanticsLabel('Sudoku Medio en menos de 6 minutos. Desbloqueado'), findsOneWidget);
    expect(find.bySemanticsLabel('Primer puzzle. Desbloqueado'), findsOneWidget);
    expect(find.bySemanticsLabel('Prueba los tres juegos. 2 de 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Día perfecto. Pendiente'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Prueba los tres juegos. 2 de 3'));
    await tester.pumpAndSettle();
    expect(find.text('Completa al menos un puzzle de cada juego.'), findsOneWidget);
  });

  testWidgets('en inglés', (tester) async {
    tester.view.physicalSize = const Size(390, 1100) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpLudixa(tester, deviceLocales: const [Locale('en', 'US')]);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/progress');
    await tester.pumpAndSettle();
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Your statistics will show up once you finish your first puzzle.'), findsOneWidget);
  });

  group('goldens', skip: Platform.isMacOS ? null : 'goldens solo en macOS', () {
    testWidgets('estadísticas', (tester) async {
      await _pumpProgress(tester, seed: _seed);
      await expectLater(find.byType(ProgressPage), matchesGoldenFile('goldens/progress_stats.png'));
    });

    testWidgets('logros', (tester) async {
      await _pumpProgress(tester, seed: _seed);
      await tester.tap(find.text('Logros'));
      await tester.pumpAndSettle();
      await expectLater(find.byType(ProgressPage), matchesGoldenFile('goldens/progress_achievements.png'));
    });
  });
}
