import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ludixa/features/daily/challenge_rows.dart';
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
  Locale locale = const Locale('es', 'CL'),
  double height = 1100,
}) async {
  tester.view.physicalSize = Size(390, height) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final clock = _FakeClock(_at(3, hour: 20));
  final repository = InMemoryProgressRepository();
  await seed?.call(ProgressService(repository, clock: clock));
  await pumpLudixa(
    tester,
    progress: repository,
    deviceLocales: [locale],
    overrides: [clockProvider.overrideWithValue(clock)],
  );
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/progress');
  await tester.pumpAndSettle();
  return repository;
}

/// 150 partidas libres al azar (con semilla fija) en los 3 juegos y sus
/// niveles, con derrotas del Buscaminas.
Future<List<SessionRecord>> _seedRandom(ProgressService service) async {
  final random = Random(11);
  const levels = {
    GameId.sudoku: ['easy', 'medium', 'hard', 'expert'],
    GameId.minesweeper: ['beginner', 'intermediate', 'expert'],
    GameId.wordSearch: ['easy', 'medium', 'hard', 'expert'],
  };
  final all = <SessionRecord>[];
  for (var i = 0; i < 150; i++) {
    final game = [GameId.sudoku, GameId.minesweeper, GameId.wordSearch][random.nextInt(3)];
    final s = _finished(
      game,
      levels[game]![random.nextInt(levels[game]!.length)],
      _at(1 + i ~/ 6, hour: 8 + i % 6),
      status: game == GameId.minesweeper && random.nextBool() ? SessionStatus.lost : SessionStatus.won,
      elapsed: Duration(seconds: 30 + random.nextInt(1200)),
    );
    await service.recordResult(s);
    all.add(s);
  }
  return all;
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

  testWidgets('con 150 partidas sembradas, Progreso muestra las cifras que dan las partidas', (tester) async {
    late List<SessionRecord> all;
    // Alto de sobra: el Buscaminas no cabe en tabla y se muestra como lista.
    await _pumpProgress(tester, seed: (service) async => all = await _seedRandom(service), height: 2400);
    final won = all.where((s) => s.won);
    expect(find.bySemanticsLabel('Puzzles completados. ${won.length}'), findsOneWidget);
    final time = all.fold(Duration.zero, (sum, s) => sum + s.elapsed);
    expect(find.bySemanticsLabel('Tiempo total. ${formatDuration(time)}'), findsOneWidget);
    for (final (game, name) in [
      (GameId.sudoku, 'Sudoku'),
      (GameId.minesweeper, 'Buscaminas'),
      (GameId.wordSearch, 'Sopa de letras'),
    ]) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      for (final level in {for (final s in all.where((s) => s.game == game)) s.difficulty}) {
        final mine = all.where((s) => s.game == game && s.difficulty == level).toList();
        final wins = [
          for (final s in mine)
            if (s.won) s.elapsed,
        ];
        final best = wins.reduce((a, b) => a < b ? a : b);
        // En la tabla cada dato es un nodo; en la lista, una línea del nodo del nivel.
        Finder line(String label) => find.bySemanticsLabel(RegExp('(^|\n)${RegExp.escape(label)}(\$|\n)'));
        expect(line('Partidas: ${mine.length}'), findsWidgets, reason: '$game $level');
        expect(line('Mejor: ${formatDuration(best)}'), findsWidgets, reason: '$game $level');
      }
    }
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

  testWidgets('la tabla nunca se corta: si no cabe con el idioma, se muestra la lista', (tester) async {
    var tables = 0;
    for (final locale in const [Locale('es', 'CL'), Locale('en', 'US')]) {
      await _pumpProgress(tester, seed: _seed, locale: locale);
      final segments = find.descendant(of: find.byType(LudixaSegmentedControl<GameId>), matching: find.byType(Text));
      for (var i = 0; i < 3; i++) {
        await tester.tap(segments.at(i));
        await tester.pumpAndSettle();
        final table = find.byType(Table);
        if (table.evaluate().isEmpty) continue;
        tables++;
        final right = tester.getRect(table).right;
        for (final cell in find.descendant(of: table, matching: find.byType(Text)).evaluate()) {
          final rect = tester.getRect(find.byWidget(cell.widget));
          expect(
            rect.right,
            lessThanOrEqualTo(right + 0.5),
            reason: '${locale.languageCode} ${(cell.widget as Text).data}',
          );
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
    expect(tables, greaterThan(0), reason: 'en español, a 390 dp, la tabla cabe');
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

  group('goldens', skip: goldensSkip, () {
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
