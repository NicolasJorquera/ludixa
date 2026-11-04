import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:game_minesweeper/game_minesweeper.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:game_wordsearch/game_wordsearch.dart';
import 'package:ludixa/features/play/game_session_page.dart';
import 'package:ludixa/features/play/play_providers.dart';
import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'support/test_app.dart';

final class _FakeClock implements Clock {
  @override
  LocalNow now() => LocalNow(utc: DateTime.utc(2026, 11, 3, 13), offsetMinutes: -180);
}

/// La instantánea de la partida que está en pantalla.
SessionSnapshot _onScreen(WidgetTester tester, GameId game) => switch (game) {
  GameId.sudoku => tester.widget<SudokuGamePage>(find.byType(SudokuGamePage)).controller.snapshot(),
  GameId.minesweeper => tester.widget<MinesweeperPage>(find.byType(MinesweeperPage)).controller.snapshot(),
  _ => tester.widget<WordSearchPage>(find.byType(WordSearchPage)).controller.snapshot(),
};

/// Unas jugadas de cada juego, con errores, notas y banderas incluidas.
Future<void> _play(WidgetTester tester, GameId game) async {
  switch (game) {
    case GameId.sudoku:
      final c = tester.widget<SudokuGamePage>(find.byType(SudokuGamePage)).controller;
      final empty = [
        for (var i = 0; i < 81; i++)
          if (!c.game.isGiven(i)) i,
      ];
      c.tapCell(empty[0]);
      c.tapDigit(c.game.puzzle.solution[empty[0]]);
      c.tapCell(empty[1]);
      c.tapDigit(c.game.puzzle.solution[empty[1]] % 9 + 1); // un error
      c.toggleNotes();
      c.tapCell(empty[2]);
      c.tapDigit(3);
      c.tapDigit(7);
    case GameId.minesweeper:
      final c = tester.widget<MinesweeperPage>(find.byType(MinesweeperPage)).controller;
      // El primer toque genera el tablero en otro isolate.
      await tester.runAsync(() => c.tapCell(40));
      await tester.pump();
      final hidden = [
        for (var i = 0; i < c.game.spec.cellCount; i++)
          if (c.game.viewAt(i) == CellView.hidden) i,
      ];
      await c.longPressCell(hidden.first);
    default:
      final c = tester.widget<WordSearchPage>(find.byType(WordSearchPage)).controller;
      final cells = c.puzzle.placements.first.cells;
      c.dragStart(cells.first);
      c.dragUpdate(cells.last);
      c.dragEnd();
      final second = c.puzzle.placements[1].cells;
      c.dragStart(second.first);
      c.dragUpdate(second[1]); // a medias: se suelta sin palabra
      c.dragEnd();
  }
  await tester.pump();
}

void main() {
  for (final game in dailyGames) {
    testWidgets('${game.value}: matar la app en segundo plano y retomar deja la partida idéntica', (tester) async {
      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final repository = InMemoryProgressRepository();
      final overrides = [clockProvider.overrideWithValue(_FakeClock())];

      await pumpLudixa(tester, progress: repository, overrides: overrides);
      final context = tester.element(find.byType(Scaffold).first);
      final module = ProviderScope.containerOf(context).read(gameModulesProvider)[game]!;
      unawaited(GameFlow.play(context, module, GameFlow.dailyRequest(module, LocalDay(2026, 11, 3))));
      await tester.pumpAndSettle();
      await _play(tester, game);
      await tester.pump(const Duration(seconds: 3));
      final before = _onScreen(tester, game);

      // La app pasa a segundo plano. Desde aquí el sistema puede matarla sin
      // avisar: lo que esté en el progreso es lo que se retoma.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      final saved = (await repository.sessions()).single;
      expect(saved.status, SessionStatus.inProgress);
      expect(saved.state, before.state);
      expect(saved.elapsed, before.elapsed);

      // Se reinicia la app con el mismo progreso y se toca "Continuar". (Con la
      // app oculta Flutter no dibuja: se vuelve a primer plano para desmontar.)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpLudixa(tester, progress: repository, overrides: overrides);
      await tester.tap(find.textContaining('Continuar'));
      await tester.pumpAndSettle();
      final after = _onScreen(tester, game);
      expect(after.state, saved.state);
      expect(after.elapsed - saved.elapsed, lessThan(const Duration(seconds: 1)));
      expect(after.freeHintsUsed, before.freeHintsUsed);
    });
  }
}
