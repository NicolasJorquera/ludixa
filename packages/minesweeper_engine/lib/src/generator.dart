import 'dart:typed_data';

import 'package:puzzle_core/puzzle_core.dart';

import 'layout.dart';
import 'solver/rule_solver.dart';

/// No se encontró un tablero resoluble dentro del límite de intentos.
final class GenerationFailed implements Exception {
  GenerationFailed(this.spec, this.attempts);

  final BoardSpec spec;
  final int attempts;

  @override
  String toString() => 'GenerationFailed: $spec tras $attempts intentos';
}

/// Tablero generado y cuántos intentos costó.
final class GeneratedBoard {
  GeneratedBoard(this.layout, this.start, {required this.attempts});

  final MineLayout layout;

  /// Celda de inicio: ella y sus vecinas no tienen minas, así que abre una zona.
  final int start;
  final int attempts;
}

/// Genera tableros que se resuelven sin adivinar desde [start].
///
/// Coloca las minas al azar fuera de la zona de 3×3 de la celda de inicio y
/// acepta el tablero solo si el [RuleSolver] lo despeja por completo. Si no,
/// vuelve a colocar. Es determinista: la misma secuencia de [Pcg32] y la misma
/// celda de inicio dan el mismo tablero.
final class NoGuessGenerator {
  const NoGuessGenerator({this.solver = const RuleSolver(), this.maxAttempts = 20000});

  /// Versión del algoritmo. Si un cambio altera los tableros que salen de una
  /// semilla, hay que subirla (forma parte de la semilla del reto diario).
  static const int version = 1;

  final RuleSolver solver;
  final int maxAttempts;

  GeneratedBoard generate(BoardSpec spec, Pcg32 random, int start) {
    final geometry = Geometry.of(spec.width, spec.height);
    RangeError.checkValueInInterval(start, 0, spec.cellCount - 1, 'start');
    final excluded = <int>{start, ...geometry.neighbors[start]};
    final candidates = Int32List.fromList([
      for (var i = 0; i < spec.cellCount; i++)
        if (!excluded.contains(i)) i,
    ]);
    if (candidates.length < spec.mines) {
      throw ArgumentError('No caben ${spec.mines} minas fuera de la zona de inicio en $spec');
    }
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      // Fisher-Yates parcial: las primeras `mines` posiciones son las minas.
      for (var i = 0; i < spec.mines; i++) {
        final j = i + random.nextInt(candidates.length - i);
        final tmp = candidates[i];
        candidates[i] = candidates[j];
        candidates[j] = tmp;
      }
      final mines = Uint8List(spec.cellCount);
      for (var i = 0; i < spec.mines; i++) {
        mines[candidates[i]] = 1;
      }
      final layout = MineLayout(spec, mines);
      if (solver.solve(layout, start)) return GeneratedBoard(layout, start, attempts: attempt);
    }
    throw GenerationFailed(spec, maxAttempts);
  }

  /// Tablero del reto diario: la celda de inicio también sale de la semilla,
  /// así que todos los jugadores reciben el mismo tablero y el mismo punto de
  /// partida, que la interfaz señala.
  GeneratedBoard generateDaily(BoardSpec spec, PuzzleSeed seed) {
    final random = seed.createRandom();
    final start = random.nextInt(spec.cellCount);
    return generate(spec, random, start);
  }
}
