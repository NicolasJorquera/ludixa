import '../grid.dart';
import 'candidate_grid.dart';

/// Niveles de dificultad del PRD.
enum SudokuDifficulty { easy, medium, hard, expert }

/// Técnicas que usa el solver humano, de la más simple a la más avanzada.
/// El orden importa: el solver aplica siempre la primera que sirve.
enum SudokuTechnique {
  /// La celda solo admite un número.
  nakedSingle(SudokuDifficulty.easy),

  /// En una fila, columna o caja, un número solo cabe en una celda.
  hiddenSingle(SudokuDifficulty.easy),

  /// En una caja, un número solo cabe en una fila o columna: se descarta en el
  /// resto de esa línea.
  pointing(SudokuDifficulty.medium),

  /// En una fila o columna, un número solo cabe dentro de una caja: se
  /// descarta en el resto de la caja.
  claiming(SudokuDifficulty.medium),
  nakedPair(SudokuDifficulty.hard),
  hiddenPair(SudokuDifficulty.hard),
  nakedTriple(SudokuDifficulty.hard),
  hiddenTriple(SudokuDifficulty.hard),
  xWing(SudokuDifficulty.expert),
  xyWing(SudokuDifficulty.expert),
  swordfish(SudokuDifficulty.expert);

  const SudokuTechnique(this.difficulty);

  final SudokuDifficulty difficulty;
}

/// Un paso de razonamiento: colocar un número o descartar candidatos.
final class SudokuStep {
  const SudokuStep.place(
    this.technique,
    int this.cell,
    int this.digit, {
    this.pattern = const [],
    this.units = const [],
  }) : eliminations = const [];

  const SudokuStep.eliminate(this.technique, this.eliminations, {this.pattern = const [], this.units = const []})
    : cell = null,
      digit = null;

  final SudokuTechnique technique;
  final int? cell;
  final int? digit;

  /// Pares (celda, dígito) que dejan de ser candidatos.
  final List<(int, int)> eliminations;

  /// Celdas que forman el patrón (para resaltarlas).
  final List<int> pattern;

  /// Unidades implicadas (índices de [SudokuGrid.units]).
  final List<int> units;

  bool get isPlacement => cell != null;

  void applyTo(CandidateGrid grid) {
    if (isPlacement) {
      grid.place(cell!, digit!);
    } else {
      for (final (c, d) in eliminations) {
        grid.eliminate(c, d);
      }
    }
  }
}

/// Busca un paso con la técnica indicada.
SudokuStep? findStep(SudokuTechnique technique, CandidateGrid g) => switch (technique) {
  SudokuTechnique.nakedSingle => _nakedSingle(g),
  SudokuTechnique.hiddenSingle => _hiddenSingle(g),
  SudokuTechnique.pointing => _pointing(g),
  SudokuTechnique.claiming => _claiming(g),
  SudokuTechnique.nakedPair => _nakedSubset(g, 2, SudokuTechnique.nakedPair),
  SudokuTechnique.hiddenPair => _hiddenSubset(g, 2, SudokuTechnique.hiddenPair),
  SudokuTechnique.nakedTriple => _nakedSubset(g, 3, SudokuTechnique.nakedTriple),
  SudokuTechnique.hiddenTriple => _hiddenSubset(g, 3, SudokuTechnique.hiddenTriple),
  SudokuTechnique.xWing => _fish(g, 2, SudokuTechnique.xWing),
  SudokuTechnique.xyWing => _xyWing(g),
  SudokuTechnique.swordfish => _fish(g, 3, SudokuTechnique.swordfish),
};

SudokuStep? _nakedSingle(CandidateGrid g) {
  for (var i = 0; i < SudokuGrid.cellCount; i++) {
    final c = g.candidates[i];
    if (g.values[i] == 0 && c != 0 && c & (c - 1) == 0) {
      return SudokuStep.place(SudokuTechnique.nakedSingle, i, digitsOf(c).single, pattern: [i]);
    }
  }
  return null;
}

SudokuStep? _hiddenSingle(CandidateGrid g) {
  for (var u = 0; u < SudokuGrid.units.length; u++) {
    for (var d = 1; d <= 9; d++) {
      final positions = g.positions(u, d);
      if (positions.length == 1) {
        return SudokuStep.place(SudokuTechnique.hiddenSingle, positions.single, d, pattern: positions, units: [u]);
      }
    }
  }
  return null;
}

SudokuStep? _pointing(CandidateGrid g) {
  for (var b = 0; b < 9; b++) {
    final box = 18 + b;
    for (var d = 1; d <= 9; d++) {
      final positions = g.positions(box, d);
      if (positions.length < 2) continue;
      for (final line in [SudokuGrid.rowOf, SudokuGrid.columnOf]) {
        final first = line(positions.first);
        if (!positions.every((c) => line(c) == first)) continue;
        final lineUnit = line == SudokuGrid.rowOf ? first : 9 + first;
        final elims = [
          for (final c in SudokuGrid.units[lineUnit])
            if (SudokuGrid.boxOf(c) != b && g.hasCandidate(c, d)) (c, d),
        ];
        if (elims.isNotEmpty) {
          return SudokuStep.eliminate(SudokuTechnique.pointing, elims, pattern: positions, units: [box, lineUnit]);
        }
      }
    }
  }
  return null;
}

SudokuStep? _claiming(CandidateGrid g) {
  for (var u = 0; u < 18; u++) {
    for (var d = 1; d <= 9; d++) {
      final positions = g.positions(u, d);
      if (positions.length < 2) continue;
      final box = SudokuGrid.boxOf(positions.first);
      if (!positions.every((c) => SudokuGrid.boxOf(c) == box)) continue;
      final elims = [
        for (final c in SudokuGrid.units[18 + box])
          if (!positions.contains(c) && !SudokuGrid.units[u].contains(c) && g.hasCandidate(c, d)) (c, d),
      ];
      if (elims.isNotEmpty) {
        return SudokuStep.eliminate(SudokuTechnique.claiming, elims, pattern: positions, units: [u, 18 + box]);
      }
    }
  }
  return null;
}

SudokuStep? _nakedSubset(CandidateGrid g, int size, SudokuTechnique technique) {
  for (var u = 0; u < SudokuGrid.units.length; u++) {
    final cells = [
      for (final c in SudokuGrid.units[u])
        if (g.values[c] == 0 && popCount(g.candidates[c]) <= size) c,
    ];
    for (final combo in _combinations(cells, size)) {
      var union = 0;
      for (final c in combo) {
        union |= g.candidates[c];
      }
      if (popCount(union) != size) continue;
      final elims = [
        for (final c in SudokuGrid.units[u])
          if (!combo.contains(c) && g.values[c] == 0)
            for (final d in digitsOf(g.candidates[c] & union)) (c, d),
      ];
      if (elims.isNotEmpty) return SudokuStep.eliminate(technique, elims, pattern: combo, units: [u]);
    }
  }
  return null;
}

SudokuStep? _hiddenSubset(CandidateGrid g, int size, SudokuTechnique technique) {
  for (var u = 0; u < SudokuGrid.units.length; u++) {
    final digits = <int>[];
    final positionsOf = <int, List<int>>{};
    for (var d = 1; d <= 9; d++) {
      final p = g.positions(u, d);
      if (p.length >= 2 && p.length <= size) {
        digits.add(d);
        positionsOf[d] = p;
      }
    }
    for (final combo in _combinations(digits, size)) {
      final cells = {for (final d in combo) ...positionsOf[d]!};
      if (cells.length != size) continue;
      var keep = 0;
      for (final d in combo) {
        keep |= 1 << d;
      }
      final elims = [
        for (final c in cells)
          for (final d in digitsOf(g.candidates[c] & ~keep)) (c, d),
      ];
      if (elims.isNotEmpty) {
        return SudokuStep.eliminate(technique, elims, pattern: cells.toList()..sort(), units: [u]);
      }
    }
  }
  return null;
}

/// X-Wing (size 2) y Swordfish (size 3), en filas y en columnas.
SudokuStep? _fish(CandidateGrid g, int size, SudokuTechnique technique) {
  for (var d = 1; d <= 9; d++) {
    for (final byRows in [true, false]) {
      // Líneas base (filas o columnas) donde el dígito cabe en 2..size posiciones.
      final bases = <int>[];
      final crossOf = <int, Set<int>>{};
      for (var line = 0; line < 9; line++) {
        final unit = byRows ? line : 9 + line;
        final positions = g.positions(unit, d);
        if (positions.length < 2 || positions.length > size) continue;
        bases.add(line);
        crossOf[line] = {for (final c in positions) byRows ? SudokuGrid.columnOf(c) : SudokuGrid.rowOf(c)};
      }
      for (final combo in _combinations(bases, size)) {
        final cross = {for (final line in combo) ...crossOf[line]!};
        if (cross.length != size) continue;
        final elims = <(int, int)>[];
        for (final x in cross) {
          final unit = byRows ? 9 + x : x;
          for (final c in SudokuGrid.units[unit]) {
            final base = byRows ? SudokuGrid.rowOf(c) : SudokuGrid.columnOf(c);
            if (!combo.contains(base) && g.hasCandidate(c, d)) elims.add((c, d));
          }
        }
        if (elims.isNotEmpty) {
          final pattern = [for (final line in combo) ...g.positions(byRows ? line : 9 + line, d)];
          return SudokuStep.eliminate(
            technique,
            elims,
            pattern: pattern,
            units: [for (final line in combo) byRows ? line : 9 + line],
          );
        }
      }
    }
  }
  return null;
}

SudokuStep? _xyWing(CandidateGrid g) {
  final bivalue = [
    for (var i = 0; i < SudokuGrid.cellCount; i++)
      if (g.values[i] == 0 && popCount(g.candidates[i]) == 2) i,
  ];
  for (final pivot in bivalue) {
    final pm = g.candidates[pivot];
    final wings = [
      for (final c in bivalue)
        if (SudokuGrid.arePeers(pivot, c) && popCount(g.candidates[c] & pm) == 1) c,
    ];
    for (var a = 0; a < wings.length; a++) {
      for (var b = a + 1; b < wings.length; b++) {
        final ma = g.candidates[wings[a]];
        final mb = g.candidates[wings[b]];
        // Cada ala comparte un dígito distinto del pivote, y las dos comparten z.
        if (ma & pm == mb & pm) continue;
        final z = ma & mb & ~pm;
        if (popCount(z) != 1 || (ma | mb) & ~pm != z) continue;
        final digit = digitsOf(z).single;
        final elims = [
          for (var c = 0; c < SudokuGrid.cellCount; c++)
            if (c != pivot &&
                c != wings[a] &&
                c != wings[b] &&
                g.hasCandidate(c, digit) &&
                SudokuGrid.arePeers(c, wings[a]) &&
                SudokuGrid.arePeers(c, wings[b]))
              (c, digit),
        ];
        if (elims.isNotEmpty) {
          return SudokuStep.eliminate(SudokuTechnique.xyWing, elims, pattern: [pivot, wings[a], wings[b]]);
        }
      }
    }
  }
  return null;
}

Iterable<List<T>> _combinations<T>(List<T> items, int k, [int start = 0, List<T> prefix = const []]) sync* {
  if (prefix.length == k) {
    yield prefix;
    return;
  }
  for (var i = start; i <= items.length - (k - prefix.length); i++) {
    yield* _combinations(items, k, i + 1, [...prefix, items[i]]);
  }
}
