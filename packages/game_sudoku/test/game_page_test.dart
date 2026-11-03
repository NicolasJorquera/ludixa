import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

import 'support.dart';

void main() {
  testWidgets('celda primero: tocar celda y número coloca; tocar el mismo número lo quita', (tester) async {
    final host = FakeHost();
    final c = await pumpGame(tester, host: host);
    final target = emptyCell(c.game);
    await tester.tap(cell(target));
    await tester.tap(key(7));
    await tester.pump();
    expect(c.game.valueAt(target), 7);
    expect(host.snapshots, hasLength(1));
    expect(find.textContaining('Fácil · 2 %'), findsOneWidget);
    await tester.tap(key(7));
    await tester.pump();
    expect(c.game.valueAt(target), 0);
    expect(host.snapshots, hasLength(2));
  });

  testWidgets('número primero: elegir número y tocar celdas', (tester) async {
    final c = await pumpGame(tester, settings: const SudokuSettings(inputMode: SudokuInputMode.numberFirst));
    final a = emptyCell(c.game), b = emptyCell(c.game, 1);
    await tester.tap(key(3));
    await tester.pump();
    await tester.tap(cell(a));
    await tester.tap(cell(b));
    await tester.pump();
    expect((c.game.valueAt(a), c.game.valueAt(b)), (3, 3));
  });

  testWidgets('notas: se anotan y el lector las anuncia', (tester) async {
    final c = await pumpGame(tester);
    final target = emptyCell(c.game);
    await tester.tap(cell(target));
    await tester.tap(find.bySemanticsLabel('Notas'));
    await tester.pump();
    for (final d in [1, 5, 9]) {
      await tester.tap(key(d));
    }
    await tester.pump();
    expect(c.game.notesAt(target), [1, 5, 9]);
    expect(find.bySemanticsLabel(RegExp(r'^Fila \d, columna \d, vacía, notas 1, 5, 9, seleccionada$')), findsOneWidget);
  });

  testWidgets('conflicto: se marca y se anuncia; sin indicación no', (tester) async {
    final c = await pumpGame(tester);
    final target = emptyCell(c.game);
    final repeated = c.game.valueAt(SudokuGrid.peers[target].firstWhere(c.game.isGiven));
    await tester.tap(cell(target));
    await tester.tap(key(repeated));
    await tester.pump();
    expect(find.bySemanticsLabel(RegExp('$repeated, en conflicto, seleccionada')), findsOneWidget);
    c.settings = const SudokuSettings(errorMode: SudokuErrorMode.none);
    c.tapCell(target);
    await tester.pump();
    expect(find.bySemanticsLabel(RegExp('en conflicto')), findsNothing);
  });

  testWidgets('teclado: conteo restante y ✓ al completar un número', (tester) async {
    final c = await pumpGame(tester);
    final digit = 4;
    for (var i = 0; i < 81; i++) {
      if (!c.game.isGiven(i) && c.game.puzzle.solution[i] == digit) c.game.place(i, digit);
    }
    c.tapCell(0);
    await tester.pump();
    expect(find.bySemanticsLabel('4, completo'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^5, quedan? \d')), findsOneWidget);
  });

  testWidgets('deshacer y borrar', (tester) async {
    final c = await pumpGame(tester);
    final target = emptyCell(c.game);
    await tester.tap(cell(target));
    await tester.tap(key(2));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Borrar'));
    await tester.pump();
    expect(c.game.valueAt(target), 0);
    await tester.tap(find.bySemanticsLabel('Deshacer'));
    await tester.pump();
    expect(c.game.valueAt(target), 2);
  });

  testWidgets('pista: coloca un número correcto y descuenta; agotadas, se desactiva', (tester) async {
    final host = FakeHost(free: 1);
    final c = await pumpGame(tester, host: host);
    await tester.tap(find.bySemanticsLabel('Pista'));
    await tester.pumpAndSettle();
    expect(c.freeHints, 1);
    final s = c.selected!;
    expect(c.game.valueAt(s), c.game.puzzle.solution[s]);
    await tester.tap(find.bySemanticsLabel('Pista'));
    await tester.pumpAndSettle();
    expect(c.hintsExhausted, isTrue);
    expect(tester.getSemantics(find.bySemanticsLabel('Pista')).value, 'Sin más pistas en este puzzle');
  });

  testWidgets('pista: si hay un número equivocado, primero lo señala', (tester) async {
    final c = await pumpGame(tester);
    final target = emptyCell(c.game);
    c.game.place(target, c.game.puzzle.solution[target] % 9 + 1);
    await tester.tap(find.bySemanticsLabel('Pista'));
    await tester.pumpAndSettle();
    expect(c.selected, target);
  });

  testWidgets('temporizador: cuenta, se detiene en pausa y oculta el tablero', (tester) async {
    final c = await pumpGame(tester);
    await tester.pump(const Duration(seconds: 3));
    expect(c.elapsed, const Duration(seconds: 3));
    expect(find.bySemanticsLabel('Tiempo 0:03'), findsOneWidget);
    await tester.tap(find.byTooltip('Pausar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(c.elapsed, const Duration(seconds: 3));
    expect(find.text('Tablero oculto en pausa'), findsOneWidget);
    expect(cell(0), findsNothing);
    await tester.tap(find.text('Reanudar'));
    await tester.pump(const Duration(seconds: 1));
    expect(c.elapsed, const Duration(seconds: 4));
  });

  testWidgets('con la app en segundo plano el tiempo no corre', (tester) async {
    final c = await pumpGame(tester);
    await tester.pump(const Duration(seconds: 2));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 6));
    expect(c.elapsed, const Duration(seconds: 2));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 1));
    expect(c.elapsed, const Duration(seconds: 3));
  });

  testWidgets('pausar no mueve los controles', (tester) async {
    final c = await pumpGame(tester);
    final before = tester.getTopLeft(key(1));
    c.pause();
    await tester.pump();
    expect(tester.getTopLeft(key(1)), before);
  });

  for (final reduced in [false, true]) {
    testWidgets('al resolver celebra${reduced ? ' (sin animación)' : ''} e informa el resultado una vez', (
      tester,
    ) async {
      final host = FakeHost();
      var solvedCalls = 0;
      final c = await pumpGame(tester, host: host, disableAnimations: reduced, onSolved: () => solvedCalls++);
      final last = emptyCell(c.game);
      for (var i = 0; i < 81; i++) {
        if (i != last && !c.game.isGiven(i)) c.game.place(i, c.game.puzzle.solution[i]);
      }
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(cell(last));
      await tester.tap(key(c.game.puzzle.solution[last]));
      await tester.pumpAndSettle();
      expect(c.solved, isTrue);
      expect(solvedCalls, 1);
      expect(host.results.single.outcome, GameOutcome.won);
      expect(host.results.single.elapsed, const Duration(seconds: 2));
      await tester.tap(key(1));
      await tester.pump(const Duration(seconds: 3));
      expect(c.elapsed, const Duration(seconds: 2));
    });
  }

  testWidgets('la instantánea retoma la partida exacta', (tester) async {
    final host = FakeHost();
    final c = await pumpGame(tester, host: host);
    final target = emptyCell(c.game);
    await tester.tap(cell(target));
    await tester.tap(find.bySemanticsLabel('Notas'));
    await tester.tap(key(6));
    await tester.pump(const Duration(seconds: 1));
    final resumed = SudokuController.resume(c.snapshot(), host: host);
    expect(resumed.game.notesAt(target), [6]);
    expect(resumed.elapsed, c.elapsed);
    expect(resumed.game.toJson(), c.game.toJson());
  });

  testWidgets('pantalla de menos de 360 dp: teclas de 56 y sin desbordes', (tester) async {
    await pumpGame(tester, size: const Size(320, 640));
    expect(tester.getSize(key(1)).height, 56);
    expect(tester.takeException(), isNull);
  });

  testWidgets('en inglés', (tester) async {
    await pumpGame(tester, locale: const Locale('en'));
    expect(find.bySemanticsLabel('Undo'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Row 1, column 1, ')), findsOneWidget);
  });

  // El dibujo del texto cambia entre sistemas: los goldens se generan y se
  // comparan en macOS. En Linux (CI) los cubren las pruebas de comportamiento.
  group('goldens', skip: Platform.isMacOS ? null : 'goldens solo en macOS', () {
    for (final brightness in Brightness.values) {
      testWidgets(brightness.name, (tester) async {
        final c = await pumpGame(tester, brightness: brightness);
        final a = emptyCell(c.game), b = emptyCell(c.game, 1), n = emptyCell(c.game, 5);
        c.game.place(a, c.game.puzzle.solution[a]);
        c.game.place(b, c.game.valueAt(SudokuGrid.peers[b].firstWhere(c.game.isGiven)));
        for (final d in [1, 5, 9]) {
          c.game.toggleNote(n, d);
        }
        c.tapCell(a);
        await tester.pumpAndSettle();
        await expectLater(find.byType(SudokuGamePage), matchesGoldenFile('goldens/sudoku_${brightness.name}.png'));
      });
    }
  });
}
