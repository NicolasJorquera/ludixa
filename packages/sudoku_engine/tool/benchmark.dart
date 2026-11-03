// Benchmark del generador de Sudoku por nivel.
//
// Uso (desde packages/sudoku_engine):
//   dart compile exe tool/benchmark.dart -o build/bench && build/bench --count 300
//
// Para cada nivel genera `count` puzzles con semillas distintas e informa
// percentiles de tiempo, intentos, pistas y fallos (sin puzzle tras el máximo
// de intentos: en la app se usa el banco pregenerado).
// ignore_for_file: avoid_print
import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

void main(List<String> args) {
  var count = 200;
  final countIndex = args.indexOf('--count');
  if (countIndex >= 0) count = int.parse(args[countIndex + 1]);
  const generator = SudokuGenerator();

  for (final level in SudokuDifficulty.values) {
    final micros = <int>[];
    final givens = <int>[];
    var failures = 0;
    final total = Stopwatch()..start();
    for (var i = 0; i < count; i++) {
      final random = PuzzleSeed.fromKey('bench|${level.name}|$i').createRandom();
      final watch = Stopwatch()..start();
      try {
        final puzzle = generator.generate(level, random);
        watch.stop();
        micros.add(watch.elapsedMicroseconds);
        givens.add(puzzle.givenCount);
      } on SudokuGenerationFailed {
        failures++;
      }
    }
    total.stop();
    micros.sort();
    givens.sort();
    String ms(int us) => (us / 1000).toStringAsFixed(1);
    int pct(List<int> sorted, double p) => sorted.isEmpty ? 0 : sorted[((sorted.length - 1) * p).round()];
    print('${level.name} · $count puzzles · ${total.elapsed.inSeconds} s');
    if (micros.isNotEmpty) {
      print(
        '  tiempo ms  p50 ${ms(pct(micros, .5))}  p95 ${ms(pct(micros, .95))}  '
        'p99 ${ms(pct(micros, .99))}  máx ${ms(micros.last)}',
      );
      print('  pistas     mín ${givens.first}  p50 ${pct(givens, .5)}  máx ${givens.last}');
    }
    print('  fallos     $failures (${(100 * failures / count).toStringAsFixed(1)}%)');
  }
}
