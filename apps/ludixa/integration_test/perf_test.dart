import 'dart:async';
import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_sudoku/game_sudoku.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ludixa/app/environment.dart';
import 'package:ludixa/bootstrap.dart';
import 'package:ludixa/features/play/game_session_page.dart';
import 'package:ludixa/features/play/play_providers.dart';
import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

/// Perfilado en el dispositivo (H7-03), en modo profile:
///
/// ```bash
/// flutter drive --profile --flavor dev -t integration_test/perf_test.dart \
///   --driver test_driver/perf_driver.dart -d <dispositivo>
/// ```
///
/// Deja en `build/perf.json` los fotogramas de cada grilla mientras se juega
/// y los tiempos de generación de los tres motores, compilados como en la app.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generación en el dispositivo', (tester) async {
    final report = <String, Object>{};

    for (final (name, spec) in [
      ('buscaminas_principiante', BoardSpec.beginner),
      ('buscaminas_intermedio', BoardSpec.intermediate),
      ('buscaminas_experto', BoardSpec.expert),
    ]) {
      report[name] = _measure(200, (i) {
        final rng = PuzzleSeed.fromKey('perf|$name|$i').createRandom();
        const NoGuessGenerator().generate(spec, rng, rng.nextInt(spec.cellCount));
      });
    }

    // Partida libre de Sudoku, como la juega la app: genera con 2 s de
    // presupuesto y, si no llega, usa el banco.
    for (final level in SudokuDifficulty.values) {
      var fromBank = 0;
      final times = _measure(20, (i) {
        final result = freePlaySudoku(
          level,
          PuzzleSeed.fromKey('perf|${level.name}|$i').createRandom(),
          budget: const Duration(seconds: 2),
        );
        if (result.fromBank) fromBank++;
      });
      report['sudoku_${level.name}'] = {...times, 'del_banco': fromBank};
    }

    final language = WordLanguage.all.first;
    final themes = WordBanks.themes(language.code);
    report['sopa_experto'] = _measure(200, (i) {
      const WordSearchGenerator().generate(
        themeWords: themes[i % themes.length].words,
        blocklist: WordBanks.blocklist(language.code),
        language: language,
        difficulty: WordSearchDifficulty.expert,
        random: PuzzleSeed.fromKey('perf|sopa|$i').createRandom(),
      );
    });

    binding.reportData = {...?binding.reportData, 'generacion': report};
  });

  testWidgets('fotogramas de las grillas', (tester) async {
    await bootstrap(AppEnvironment.dev);
    await tester.pumpAndSettle();
    final random = Random(7);

    Future<Rect> open(GameId game, String level) async {
      final context = tester.element(find.byType(Scaffold).first);
      final module = ProviderScope.containerOf(context).read(gameModulesProvider)[game]!;
      unawaited(GameFlow.play(context, module, GameFlow.freeRequest(Difficulty(level))));
      await tester.pumpAndSettle();
      return tester.getRect(find.byType(PuzzleGrid));
    }

    Offset cell(Rect board, GridDimensions dims, int row, int column) => Offset(
      board.left + (column + .5) * board.width / dims.columns,
      board.top + (row + .5) * board.height / dims.rows,
    );

    Future<void> close() async {
      final context = tester.element(find.byType(Scaffold).last);
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      await tester.pumpAndSettle();
    }

    // Buscaminas Experto (16×30): revelar celdas y desplazar el tablero.
    var board = await open(GameId.minesweeper, 'expert');
    final mines = tester.widget<PuzzleGrid>(find.byType(PuzzleGrid)).dimensions;
    await binding.watchPerformance(() async {
      for (var i = 0; i < 25; i++) {
        await tester.tapAt(cell(board, mines, random.nextInt(mines.rows), random.nextInt(mines.columns)));
        await tester.pumpAndSettle();
        if (find.byType(PuzzleGrid).evaluate().isEmpty) break; // perdió: queda la pantalla de derrota
        await tester.timedDragFrom(board.center, const Offset(0, -240), const Duration(milliseconds: 400));
        await tester.timedDragFrom(board.center, const Offset(0, 240), const Duration(milliseconds: 400));
        board = tester.getRect(find.byType(PuzzleGrid));
      }
    }, reportKey: 'fotogramas_buscaminas_experto');
    await close();

    // Sudoku: elegir celdas y escribir números.
    board = await open(GameId.sudoku, 'medium');
    const sudoku = GridDimensions(columns: 9, rows: 9);
    final keys = find.descendant(of: find.byType(SudokuKeypad), matching: find.byType(InkWell));
    expect(keys, findsNWidgets(9));
    await binding.watchPerformance(() async {
      for (var i = 0; i < 40; i++) {
        await tester.tapAt(cell(board, sudoku, random.nextInt(9), random.nextInt(9)));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(keys.at(random.nextInt(9)), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
    }, reportKey: 'fotogramas_sudoku');
    await close();

    // Sopa de letras Experto: selecciones por arrastre.
    board = await open(GameId.wordSearch, 'expert');
    final words = tester.widget<PuzzleGrid>(find.byType(PuzzleGrid)).dimensions;
    await binding.watchPerformance(() async {
      for (var i = 0; i < 20; i++) {
        final row = random.nextInt(words.rows);
        final from = cell(board, words, row, 0);
        final to = cell(board, words, row, words.columns - 1);
        await tester.timedDragFrom(from, to - from, const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
      }
    }, reportKey: 'fotogramas_sopa_experto');
    await close();
  });
}

/// Repite [run] [count] veces y devuelve p50, p95 y máximo en milisegundos.
Map<String, Object> _measure(int count, void Function(int i) run) {
  final micros = <int>[];
  for (var i = 0; i < count; i++) {
    final watch = Stopwatch()..start();
    run(i);
    micros.add(watch.elapsedMicroseconds);
  }
  micros.sort();
  double ms(double q) => micros[((micros.length - 1) * q).round()] / 1000;
  return {'n': count, 'p50_ms': ms(.5), 'p95_ms': ms(.95), 'max_ms': ms(1)};
}
