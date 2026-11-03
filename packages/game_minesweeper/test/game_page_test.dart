import 'dart:io';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:game_minesweeper/game_minesweeper.dart';
import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'support.dart';

/// Primer toque en el centro: genera y abre una zona.
Future<void> firstTap(WidgetTester tester, MinesweeperController c, [int cell = 40]) async {
  await tester.tap(cellAt(c, cell));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('antes del primer toque: tablero cerrado y mensaje; el toque genera y abre una zona', (tester) async {
    final c = await pumpGame(tester);
    expect(find.text('Toca cualquier celda para empezar'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(c.elapsed, Duration.zero);
    await firstTap(tester, c);
    expect(c.game.status, GameStatus.playing);
    expect(c.game.viewAt(40), CellView.revealed);
    expect(c.game.numberAt(40), 0);
    await tester.pump(const Duration(seconds: 2));
    expect(c.elapsed, const Duration(seconds: 2));
  });

  testWidgets('pulsación larga pone bandera, descuenta minas y apaga la ayuda', (tester) async {
    final store = InMemoryMinesweeperSettingsStore();
    final c = await pumpGame(tester, controller: freeController(store: store));
    await firstTap(tester, c);
    expect(find.text('Mantén pulsada una celda para poner bandera'), findsOneWidget);
    final target = [for (var i = 0; i < 81; i++) i].firstWhere((i) => c.game.viewAt(i) == CellView.hidden);
    await tester.longPress(cellAt(c, target));
    await tester.pump();
    expect(c.game.viewAt(target), CellView.flagged);
    expect(find.bySemanticsLabel('Quedan 9 minas'), findsOneWidget);
    expect(store.load().longPressTipDone, isTrue);
    expect(find.textContaining('Mantén pulsada'), findsNothing);
  });

  testWidgets('modo Bandera: el toque pone bandera y la pulsación larga revela', (tester) async {
    final c = await pumpGame(tester);
    await firstTap(tester, c);
    await tester.tap(find.text('Bandera'));
    await tester.pump();
    final mines = minesOf(c);
    final mine = mines.first;
    await tester.tap(cellAt(c, mine));
    await tester.pump();
    expect(c.game.viewAt(mine), CellView.flagged);
    final safe = [
      for (var i = 0; i < 81; i++) i,
    ].firstWhere((i) => c.game.viewAt(i) == CellView.hidden && !mines.contains(i));
    await tester.longPress(cellAt(c, safe));
    await tester.pump();
    expect(c.game.viewAt(safe), CellView.revealed);
  });

  testWidgets('tocar un número con todas sus banderas abre sus vecinas; se puede desactivar', (tester) async {
    for (final chord in [true, false]) {
      final c = await pumpGame(
        tester,
        controller: freeController(store: InMemoryMinesweeperSettingsStore(MinesweeperSettings(chord: chord))),
      );
      await firstTap(tester, c);
      final mines = minesOf(c);
      final geometry = c.game.geometry;
      final number = [for (var i = 0; i < 81; i++) i].firstWhere(
        (i) =>
            c.game.viewAt(i) == CellView.revealed &&
            c.game.numberAt(i) > 0 &&
            geometry.neighbors[i].any((n) => c.game.viewAt(n) == CellView.hidden && !mines.contains(n)),
      );
      for (final n in geometry.neighbors[number].where(mines.contains)) {
        c.game.toggleFlag(n);
      }
      final closedSafe = geometry.neighbors[number].where((n) => c.game.viewAt(n) == CellView.hidden).toList();
      await tester.tap(cellAt(c, number));
      await tester.pump();
      final opened = closedSafe.every((n) => c.game.viewAt(n) == CellView.revealed);
      expect(opened, chord, reason: 'chord $chord');
    }
  });

  testWidgets('deshacer quita la última bandera', (tester) async {
    final c = await pumpGame(tester);
    await firstTap(tester, c);
    final target = [for (var i = 0; i < 81; i++) i].firstWhere((i) => c.game.viewAt(i) == CellView.hidden);
    await tester.longPress(cellAt(c, target));
    await tester.pump();
    await tester.tap(find.byTooltip('Deshacer'));
    await tester.pump();
    expect(c.game.viewAt(target), CellView.hidden);
  });

  group('derrota', () {
    Future<(MinesweeperController, FakeHost)> lose(
      WidgetTester tester, {
      RescueOutcome rescue = RescueOutcome.granted,
      VoidCallback? onNewBoard,
    }) async {
      final host = FakeHost(rescueAnswer: rescue);
      final c = await pumpGame(
        tester,
        controller: freeController(host: host),
        onNewBoard: onNewBoard,
      );
      await firstTap(tester, c);
      await tester.tap(cellAt(c, minesOf(c).first));
      await tester.pump();
      return (c, host);
    }

    testWidgets('mensaje neutro, tablero visible, mina fatal anunciada y sin resultado aún', (tester) async {
      final (c, host) = await lose(tester);
      final fatal = c.game.fatal!;
      expect(find.text('Esta vez explotó una mina'), findsOneWidget);
      expect(find.text('La mina estaba en la fila ${fatal ~/ 9 + 1}, columna ${fatal % 9 + 1}.'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('mina que terminó la partida')), findsOneWidget);
      expect(host.results, isEmpty);
      await tester.tap(find.text('Ver el tablero'));
      await tester.pump();
      expect(find.text('Reintentar este tablero'), findsNothing);
      await tester.tap(find.text('Ver opciones'));
      await tester.pump();
      expect(find.text('Reintentar este tablero'), findsOneWidget);
    });

    testWidgets('rescate con video: vuelve al estado previo, una sola vez', (tester) async {
      final (c, _) = await lose(tester);
      await tester.tap(find.text('Deshacer el último toque con un video'));
      await tester.pumpAndSettle();
      expect(c.game.status, GameStatus.playing);
      await tester.tap(cellAt(c, minesOf(c).first));
      await tester.pump();
      expect(c.lost, isTrue);
      expect(find.text('Deshacer el último toque con un video'), findsNothing);
    });

    testWidgets('sin videos disponibles quedan solo las opciones gratuitas', (tester) async {
      final (c, _) = await lose(tester, rescue: RescueOutcome.unavailable);
      await tester.tap(find.text('Deshacer el último toque con un video'));
      await tester.pumpAndSettle();
      expect(c.lost, isTrue);
      expect(find.text('Ahora no hay videos disponibles.'), findsOneWidget);
      expect(find.text('Deshacer el último toque con un video'), findsNothing);
    });

    testWidgets('reintentar: mismas minas desde cero e informa la derrota una vez', (tester) async {
      final (c, host) = await lose(tester);
      final mines = minesOf(c);
      await tester.tap(find.text('Reintentar este tablero'));
      await tester.pumpAndSettle();
      expect(c.game.status, GameStatus.playing);
      expect(minesOf(c), mines);
      expect(host.results.single.outcome, GameOutcome.lost);
      expect(find.bySemanticsLabel(RegExp('inicio sugerido')), findsOneWidget);
    });

    testWidgets('tablero nuevo: informa la derrota y avisa a la app', (tester) async {
      var asked = 0;
      final (_, host) = await lose(tester, onNewBoard: () => asked++);
      await tester.tap(find.text('Tablero nuevo'));
      await tester.pumpAndSettle();
      expect((asked, host.results.single.outcome), (1, GameOutcome.lost));
    });
  });

  testWidgets('al ganar: minas con bandera solas, resultado una vez y aviso a la app', (tester) async {
    final host = FakeHost();
    var won = 0;
    final c = await pumpGame(
      tester,
      controller: freeController(host: host),
      onWon: () => won++,
    );
    await firstTap(tester, c);
    final mines = minesOf(c);
    final safe = [
      for (var i = 0; i < 81; i++) i,
    ].where((i) => !mines.contains(i) && c.game.viewAt(i) == CellView.hidden);
    for (final i in safe.toList()) {
      if (c.game.viewAt(i) == CellView.hidden) c.game.reveal(i);
    }
    c.toggleMode();
    c.toggleMode();
    await tester.pumpAndSettle();
    expect(c.won, isTrue);
    expect(won, 1);
    expect(host.results.single.outcome, GameOutcome.won);
    expect(find.bySemanticsLabel(RegExp(r'^Fila \d, columna \d, con bandera$')), findsNWidgets(10));
  });

  testWidgets('pista: señala, explica, pausa el tiempo y se puede aplicar', (tester) async {
    final host = FakeHost(free: 1);
    final c = await pumpGame(tester, controller: freeController(host: host));
    await firstTap(tester, c);
    await tester.tap(find.byTooltip('Pista'));
    await tester.pumpAndSettle();
    final hint = c.hint!;
    expect(find.bySemanticsLabel(RegExp('señalada por la pista')), findsOneWidget);
    final before = c.elapsed;
    await tester.pump(const Duration(seconds: 3));
    expect(c.elapsed, before);
    await tester.tap(find.text(hint.isMine ? 'Ponerle bandera' : 'Revelarla'));
    await tester.pump();
    expect(c.game.viewAt(hint.cell), hint.isMine ? CellView.flagged : CellView.revealed);
    expect(host.free, 0);
  });

  testWidgets('reto diario: celda de inicio señalada', (tester) async {
    final day = LocalDay(2026, 11, 2);
    final c = MinesweeperController(
      game: MinesweeperGame.daily(spec: BoardSpec.beginner, seed: PuzzleSeed.fromKey('daily|${day.toIso8601()}')),
      host: FakeHost(),
      store: InMemoryMinesweeperSettingsStore(),
    );
    await pumpGame(tester, controller: c);
    expect(find.textContaining('Empieza aquí'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('inicio sugerido')), findsOneWidget);
    await tester.tap(cellAt(c, c.game.suggestedStart!));
    await tester.pump();
    expect(c.game.viewAt(c.game.suggestedStart!), CellView.revealed);
  });

  testWidgets('Experto: tablero con zoom por botón y sin desbordes', (tester) async {
    final c = await pumpGame(tester, controller: freeController(spec: BoardSpec.expert));
    expect(find.byType(ZoomableBoard), findsOneWidget);
    await tester.tap(find.byTooltip('Acercar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ajustar al ancho'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(c.game.spec.cellCount, 480);
  });

  testWidgets('la instantánea retoma la partida exacta', (tester) async {
    final host = FakeHost();
    final c = await pumpGame(tester, controller: freeController(host: host));
    await firstTap(tester, c);
    final resumed = MinesweeperController.resume(
      host.snapshots.last,
      host: host,
      store: InMemoryMinesweeperSettingsStore(),
    );
    expect(resumed.game.toJson(), c.game.toJson());
  });

  group('goldens', skip: Platform.isMacOS ? null : 'goldens solo en macOS', () {
    for (final brightness in Brightness.values) {
      testWidgets('en juego ${brightness.name}', (tester) async {
        final c = await pumpGame(tester, brightness: brightness);
        await firstTap(tester, c);
        await c.longPressCell(minesOf(c).first);
        await tester.pumpAndSettle();
        await expectLater(find.byType(MinesweeperPage), matchesGoldenFile('goldens/mines_${brightness.name}.png'));
      });
    }

    testWidgets('derrota', (tester) async {
      final c = await pumpGame(tester);
      await firstTap(tester, c);
      await tester.tap(cellAt(c, minesOf(c).first));
      await tester.pumpAndSettle();
      await expectLater(find.byType(MinesweeperPage), matchesGoldenFile('goldens/mines_defeat.png'));
    });

    testWidgets('experto', (tester) async {
      final c = await pumpGame(tester, controller: freeController(spec: BoardSpec.expert));
      await firstTap(tester, c, 240);
      await expectLater(find.byType(MinesweeperPage), matchesGoldenFile('goldens/mines_expert.png'));
    });
  });
}
