// Benchmark y propiedades del generador de Sudoku por nivel.
//
// Uso (desde packages/sudoku_engine):
//   dart compile exe tool/benchmark.dart -o build/bench && build/bench --count 1000 --verify
//
// Por nivel genera `count` puzzles con semillas distintas e imprime una tabla
// Markdown con percentiles de tiempo (de los puzzles aceptados), pistas y
// fallos. Un fallo no es un error: la app usa el banco pregenerado (ADR 0004).
// Con --verify comprueba cada puzzle: solución única, coherente con las
// pistas y calificación exacta del nivel. --salt cambia las semillas.
// Sale con código 1 si hay violaciones.
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

void main(List<String> args) {
  final count = _intArg(args, '--count') ?? 1000;
  final salt = _stringArg(args, '--salt') ?? 'bench';
  final verify = args.contains('--verify');
  const generator = SudokuGenerator();
  var broken = false;

  print('### Sudoku · $count puzzles por nivel · semilla `$salt`${verify ? ' · verificados' : ''}\n');
  print('| Nivel | p50 ms | p95 ms | p99 ms | máx ms | pistas p50 | sin puzzle | violaciones |');
  print('|---|---:|---:|---:|---:|---:|---:|---:|');
  for (final level in SudokuDifficulty.values) {
    final micros = <int>[];
    final givens = <int>[];
    var failures = 0;
    final violations = <String>[];
    for (var i = 0; i < count; i++) {
      final random = PuzzleSeed.fromKey('$salt|${level.name}|$i').createRandom();
      final watch = Stopwatch()..start();
      try {
        final puzzle = generator.generate(level, random);
        micros.add(watch.elapsedMicroseconds);
        givens.add(puzzle.givenCount);
        if (verify) {
          final problem = _check(puzzle, level);
          if (problem != null) violations.add('$i: $problem');
        }
      } on SudokuGenerationFailed {
        failures++;
      }
    }
    final failRate = count == 0 ? '0' : (100 * failures / count).toStringAsFixed(1);
    print(
      '| ${level.name} | ${_pct(micros, .5)} | ${_pct(micros, .95)} | ${_pct(micros, .99)} | ${_pct(micros, 1)} '
      '| ${_raw(givens, .5)} | $failures ($failRate%) | ${violations.length} |',
    );
    for (final v in violations.take(10)) {
      stderr.writeln('VIOLACIÓN ${level.name} semilla $salt índice $v');
    }
    broken |= violations.isNotEmpty;
  }
  exitCode = broken ? 1 : 0;
}

String? _check(SudokuPuzzle puzzle, SudokuDifficulty level) {
  if (BitSolver.countSolutions(puzzle.givens) != 1) return 'solución no única';
  for (var c = 0; c < SudokuGrid.cellCount; c++) {
    if (puzzle.givens[c] != 0 && puzzle.givens[c] != puzzle.solution[c]) return 'pista $c no coincide';
  }
  if (BitSolver.solve(puzzle.givens).toString() != puzzle.solution.toString()) return 'solución distinta';
  final grade = HumanSolver.grade(puzzle.givens);
  if (grade != level) return 'calificado $grade';
  return null;
}

int? _intArg(List<String> args, String name) {
  final i = args.indexOf(name);
  return i >= 0 ? int.parse(args[i + 1]) : null;
}

String? _stringArg(List<String> args, String name) {
  final i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : null;
}

int _raw(List<int> values, double p) {
  if (values.isEmpty) return 0;
  final sorted = [...values]..sort();
  return sorted[((sorted.length - 1) * p).round()];
}

String _pct(List<int> micros, double p) => (_raw(micros, p) / 1000).toStringAsFixed(1);
