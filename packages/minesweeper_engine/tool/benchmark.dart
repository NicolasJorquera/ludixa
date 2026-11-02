// Benchmark del generador sin adivinar.
//
// Uso (desde packages/minesweeper_engine):
//   dart compile exe tool/benchmark.dart -o build/bench && build/bench --count 20000 --verify
//
// Para cada nivel genera `count` tableros con semillas y celdas de inicio
// distintas, mide el tiempo por tablero e informa percentiles. Con --verify,
// además pasa cada tablero por el verificador exacto independiente.
// ignore_for_file: avoid_print
import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';

void main(List<String> args) {
  var count = 2000;
  final countIndex = args.indexOf('--count');
  if (countIndex >= 0) count = int.parse(args[countIndex + 1]);
  final verify = args.contains('--verify');
  const generator = NoGuessGenerator();
  const verifier = ExactSolver();

  for (final (name, spec) in [
    ('Principiante', BoardSpec.beginner),
    ('Intermedio', BoardSpec.intermediate),
    ('Experto', BoardSpec.expert),
  ]) {
    final micros = <int>[];
    final attempts = <int>[];
    final outcomes = <ExactOutcome, int>{};
    var failures = 0;
    final total = Stopwatch()..start();
    for (var i = 0; i < count; i++) {
      final rng = PuzzleSeed.fromKey('bench|${spec.width}x${spec.height}|$i').createRandom();
      final start = rng.nextInt(spec.cellCount);
      final watch = Stopwatch()..start();
      try {
        final board = generator.generate(spec, rng, start);
        watch.stop();
        micros.add(watch.elapsedMicroseconds);
        attempts.add(board.attempts);
        if (verify) {
          final outcome = verifier.solve(board.layout, start);
          outcomes[outcome] = (outcomes[outcome] ?? 0) + 1;
        }
      } on GenerationFailed {
        failures++;
      }
    }
    total.stop();
    micros.sort();
    attempts.sort();
    String ms(int us) => (us / 1000).toStringAsFixed(1);
    int pct(List<int> sorted, double p) => sorted[((sorted.length - 1) * p).round()];
    final meanAttempts = attempts.isEmpty ? 0 : attempts.reduce((a, b) => a + b) / attempts.length;
    print('$name $spec · $count tableros · ${total.elapsed.inSeconds} s en total');
    print(
      '  tiempo ms  p50 ${ms(pct(micros, .5))}  p95 ${ms(pct(micros, .95))}  '
      'p99 ${ms(pct(micros, .99))}  máx ${ms(micros.last)}',
    );
    print(
      '  intentos   media ${meanAttempts.toStringAsFixed(1)}  p95 ${pct(attempts, .95)}  '
      'máx ${attempts.last}  fallos $failures',
    );
    if (verify) print('  verificador exacto: $outcomes');
  }
}
