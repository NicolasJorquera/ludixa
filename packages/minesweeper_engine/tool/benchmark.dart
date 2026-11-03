// Benchmark y propiedades del generador sin adivinar.
//
// Uso (desde packages/minesweeper_engine):
//   dart compile exe tool/benchmark.dart -o build/bench && build/bench --count 1000 --verify
//
// Por nivel genera `count` tableros con semillas y celdas de inicio distintas
// e imprime una tabla Markdown con percentiles de tiempo. Con --verify pasa
// cada tablero por el verificador exacto independiente: debe despejarse sin
// adivinar. --salt cambia las semillas (la CI nocturna usa una por noche).
// Sale con código 1 si hay violaciones o tableros sin generar.
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';

void main(List<String> args) {
  final count = _intArg(args, '--count') ?? 1000;
  final salt = _stringArg(args, '--salt') ?? 'bench';
  final verify = args.contains('--verify');
  const generator = NoGuessGenerator();
  const verifier = ExactSolver();
  var broken = false;

  print('### Buscaminas · $count tableros por nivel · semilla `$salt`${verify ? ' · verificados' : ''}\n');
  print('| Nivel | p50 ms | p95 ms | p99 ms | máx ms | intentos p95 | sin generar | violaciones |');
  print('|---|---:|---:|---:|---:|---:|---:|---:|');
  for (final (name, spec) in [
    ('Principiante', BoardSpec.beginner),
    ('Intermedio reducido', const BoardSpec(width: 12, height: 12, mines: 22)),
    ('Intermedio', BoardSpec.intermediate),
    ('Experto', BoardSpec.expert),
  ]) {
    final micros = <int>[];
    final attempts = <int>[];
    var failures = 0;
    final violations = <String>[];
    for (var i = 0; i < count; i++) {
      final rng = PuzzleSeed.fromKey('$salt|${spec.width}x${spec.height}|$i').createRandom();
      final start = rng.nextInt(spec.cellCount);
      final watch = Stopwatch()..start();
      try {
        final board = generator.generate(spec, rng, start);
        micros.add(watch.elapsedMicroseconds);
        attempts.add(board.attempts);
        if (verify) {
          final outcome = verifier.solve(board.layout, start);
          if (outcome != ExactOutcome.solved) violations.add('$i: $outcome');
        }
      } on GenerationFailed {
        failures++;
      }
    }
    print(
      '| $name $spec | ${_pct(micros, .5)} | ${_pct(micros, .95)} | ${_pct(micros, .99)} | ${_pct(micros, 1)} '
      '| ${_raw(attempts, .95)} | $failures | ${violations.length} |',
    );
    for (final v in violations.take(10)) {
      stderr.writeln('VIOLACIÓN $name semilla $salt índice $v');
    }
    broken |= violations.isNotEmpty || failures > 0;
  }
  exitCode = broken ? 1 : 0;
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
