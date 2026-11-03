import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:game_wordsearch/game_wordsearch.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

import 'support.dart';

void main() {
  test('el ajuste a 8 direcciones: casi en diagonal es diagonal, y no sale de la grilla', () {
    // 8×8: de (0,0) a (3,2) se ajusta a la diagonal (3,3); de (0,0) a (1,4), a la fila.
    expect(WordSearchController.snap(0, 3 * 8 + 2, 8), 3 * 8 + 3);
    expect(WordSearchController.snap(0, 1 * 8 + 4, 8), 4);
    expect(WordSearchController.snap(7, 7 * 8 + 1, 8), 7 * 8);
    expect(WordSearchController.snap(5, 5, 8), 5);
  });

  testWidgets('arrastrar sobre una palabra la encuentra, la marca y la tacha en la lista', (tester) async {
    final host = FakeHost();
    final c = await pumpGame(tester, controller: controllerFor(host: host));
    final word = c.puzzle.placements.first;
    await dragWord(tester, c, word.start, word.end);
    expect(c.game.isFound(0), isTrue);
    expect(find.bySemanticsLabel('${word.display}, encontrada'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('en una palabra encontrada')), findsNWidgets(word.length));
    expect(find.text('1 de 6'), findsOneWidget);
    expect(host.snapshots, hasLength(1));
  });

  testWidgets('una selección que no es palabra se desvanece sin penalización', (tester) async {
    final host = FakeHost();
    final c = await pumpGame(tester, controller: controllerFor(host: host));
    await dragWord(tester, c, 0, 1);
    expect(c.game.foundOrder, isEmpty);
    expect(c.selection, isEmpty);
    expect(host.snapshots, isEmpty);
  });

  testWidgets('la lista muestra la ortografía real y la grilla, la normalizada', (tester) async {
    final c = await pumpGame(tester);
    expect(find.text('LIMÓN'), findsOneWidget);
    final limon = c.puzzle.placements.firstWhere((p) => p.display == 'LIMÓN');
    expect([for (final cell in limon.cells) c.puzzle.letters[cell]].join(), 'LIMON');
  });

  testWidgets('modo de toque: letra inicial y luego final', (tester) async {
    final c = await pumpGame(
      tester,
      controller: controllerFor(settings: const WordSearchSettings(selection: SelectionMode.tap)),
    );
    expect(find.text('Toca la letra inicial'), findsOneWidget);
    final word = c.puzzle.placements[1];
    await tester.tap(cellFinder(c, word.start));
    await tester.pump();
    expect(find.text('Ahora toca la letra final'), findsOneWidget);
    await tester.tap(cellFinder(c, word.end));
    await tester.pump();
    expect(c.game.isFound(1), isTrue);
  });

  testWidgets('con TalkBack se usa el modo de toque aunque el ajuste sea arrastrar', (tester) async {
    final c = await pumpGame(tester, accessibleNavigation: true);
    expect(find.text('Toca la letra inicial'), findsOneWidget);
    final word = c.puzzle.placements.first;
    await tester.tap(cellFinder(c, word.end));
    await tester.tap(cellFinder(c, word.start));
    await tester.pump();
    expect(c.game.isFound(0), isTrue);
  });

  testWidgets('pista: hace parpadear la primera letra de una palabra pendiente', (tester) async {
    final host = FakeHost(free: 1);
    final c = await pumpGame(tester, controller: controllerFor(host: host));
    await tester.tap(find.byTooltip('Pista'));
    await tester.pump();
    final cell = c.hintCell!;
    expect(c.puzzle.placements.any((p) => p.start == cell), isTrue);
    expect(find.bySemanticsLabel(RegExp('inicio de una palabra')), findsOneWidget);
    expect(host.free, 0);
    final word = c.puzzle.placements.indexWhere((p) => p.start == cell);
    final p = c.puzzle.placements[word];
    await dragWord(tester, c, p.start, p.end);
    expect(c.hintCell, isNull);
  });

  testWidgets('al encontrar todas: resultado una vez y aviso a la app', (tester) async {
    final host = FakeHost();
    var won = 0;
    final c = await pumpGame(
      tester,
      controller: controllerFor(host: host),
      onWon: () => won++,
    );
    for (final p in c.puzzle.placements) {
      await dragWord(tester, c, p.start, p.end);
    }
    await tester.pumpAndSettle();
    expect(c.complete, isTrue);
    expect(won, 1);
    expect(host.results.single.outcome, GameOutcome.won);
  });

  testWidgets('pausa: oculta la grilla y detiene el tiempo', (tester) async {
    final c = await pumpGame(tester);
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byTooltip('Pausar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(c.elapsed, const Duration(seconds: 2));
    expect(find.text('Tablero oculto en pausa'), findsOneWidget);
    expect(cellFinder(c, 0), findsNothing);
  });

  testWidgets('pantallas de menos de 700 dp de alto: la lista se pliega', (tester) async {
    await pumpGame(tester, size: const Size(390, 640));
    expect(find.text('LIMÓN'), findsNothing);
    await tester.tap(find.text('Ver palabras'));
    await tester.pump();
    expect(find.text('LIMÓN'), findsOneWidget);
  });

  testWidgets('Experto: celdas bajo 28 dp ofrecen zoom, sin desbordes', (tester) async {
    await pumpGame(tester, controller: controllerFor(level: WordSearchDifficulty.expert));
    expect(find.byType(ZoomableBoard), findsOneWidget);
    await tester.tap(find.byTooltip('Acercar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ajustar al ancho'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la instantánea retoma la partida exacta con su tema', (tester) async {
    final host = FakeHost();
    final c = await pumpGame(tester, controller: controllerFor(host: host));
    final p = c.puzzle.placements.first;
    await dragWord(tester, c, p.start, p.end);
    final resumed = WordSearchController.resume(host.snapshots.last, host: host);
    expect(resumed.game.toJson(), c.game.toJson());
    expect(resumed.themeNames, ['Frutas']);
  });

  group('goldens', skip: Platform.isMacOS ? null : 'goldens solo en macOS', () {
    for (final brightness in Brightness.values) {
      testWidgets('en juego ${brightness.name}', (tester) async {
        final c = await pumpGame(tester, brightness: brightness);
        for (final p in c.puzzle.placements.take(2)) {
          await dragWord(tester, c, p.start, p.end);
        }
        final third = c.puzzle.placements[2];
        c.dragStart(third.start);
        c.dragUpdate(third.cellAt(third.length - 2));
        await tester.pump();
        await expectLater(find.byType(WordSearchPage), matchesGoldenFile('goldens/words_${brightness.name}.png'));
      });
    }

    testWidgets('experto', (tester) async {
      await pumpGame(tester, controller: controllerFor(level: WordSearchDifficulty.expert));
      await expectLater(find.byType(WordSearchPage), matchesGoldenFile('goldens/words_expert.png'));
    });
  });
}
