import '../layout.dart';
import 'solve_state.dart';

/// Solver rápido por reglas, usado al generar tableros.
///
/// Aplica, en orden, hasta que no hay progreso:
/// 1. Regla de un número: si ya tiene todas sus minas, el resto es libre; si le
///    faltan tantas como celdas desconocidas, todas son minas.
/// 2. Regla de dos números: acota las minas de la intersección de dos
///    restricciones y deduce sobre las celdas que no comparten.
/// 3. Conteo global de minas restantes.
///
/// Es correcto pero incompleto: si dice que resuelve un tablero, ese tablero
/// se resuelve sin adivinar. Puede no resolver tableros que sí lo son.
final class RuleSolver {
  const RuleSolver();

  bool solve(MineLayout layout, int start) {
    final state = SolveState(layout)..reveal(start);
    while (!state.isSolved) {
      if (_singles(state)) continue;
      if (_pairs(state)) continue;
      if (_global(state)) continue;
      return false;
    }
    return true;
  }

  bool _singles(SolveState s) {
    var changed = false;
    final status = s.status;
    final neighbors = s.geometry.neighbors;
    for (var i = 0; i < status.length; i++) {
      final v = status[i];
      if (v <= 0) continue;
      var unknown = 0;
      var flagged = 0;
      for (final j in neighbors[i]) {
        final sj = status[j];
        if (sj == CellStatus.unknown) {
          unknown++;
        } else if (sj == CellStatus.flagged) {
          flagged++;
        }
      }
      if (unknown == 0) continue;
      final k = v - flagged;
      if (k == 0) {
        for (final j in neighbors[i]) {
          if (status[j] == CellStatus.unknown) s.reveal(j);
        }
        changed = true;
      } else if (k == unknown) {
        for (final j in neighbors[i]) {
          if (status[j] == CellStatus.unknown) s.flag(j);
        }
        changed = true;
      }
    }
    return changed;
  }

  bool _pairs(SolveState s) {
    final constraints = _constraints(s);
    if (constraints.length < 2) return false;
    final byCell = <int, List<int>>{};
    for (var c = 0; c < constraints.length; c++) {
      for (final cell in constraints[c].cells) {
        (byCell[cell] ??= <int>[]).add(c);
      }
    }
    for (var a = 0; a < constraints.length; a++) {
      final ca = constraints[a];
      final seen = <int>{};
      for (final cell in ca.cells) {
        for (final b in byCell[cell]!) {
          if (b <= a || !seen.add(b)) continue;
          if (_applyPair(s, ca, constraints[b])) return true;
        }
      }
    }
    return false;
  }

  bool _applyPair(SolveState s, _Constraint a, _Constraint b) {
    var inter = 0;
    for (final cell in a.cells) {
      if (b.cells.contains(cell)) inter++;
    }
    final aOnly = a.cells.length - inter;
    final bOnly = b.cells.length - inter;
    final maxInter = _min3(inter, a.mines, b.mines);
    final minInter = _max3(0, a.mines - aOnly, b.mines - bOnly);
    var changed = false;
    if (bOnly > 0) {
      if (b.mines - maxInter >= bOnly) {
        for (final cell in b.cells) {
          if (!a.cells.contains(cell)) s.flag(cell);
        }
        changed = true;
      } else if (b.mines - minInter <= 0) {
        for (final cell in b.cells) {
          if (!a.cells.contains(cell)) s.reveal(cell);
        }
        changed = true;
      }
    }
    if (!changed && aOnly > 0) {
      if (a.mines - maxInter >= aOnly) {
        for (final cell in a.cells) {
          if (!b.cells.contains(cell)) s.flag(cell);
        }
        changed = true;
      } else if (a.mines - minInter <= 0) {
        for (final cell in a.cells) {
          if (!b.cells.contains(cell)) s.reveal(cell);
        }
        changed = true;
      }
    }
    return changed;
  }

  bool _global(SolveState s) {
    final remaining = s.remainingMines;
    if (remaining != 0 && remaining != s.unknownCount) return false;
    for (var i = 0; i < s.status.length; i++) {
      if (s.status[i] != CellStatus.unknown) continue;
      if (remaining == 0) {
        s.reveal(i);
      } else {
        s.flag(i);
      }
    }
    return true;
  }

  List<_Constraint> _constraints(SolveState s) {
    final out = <_Constraint>[];
    final status = s.status;
    final neighbors = s.geometry.neighbors;
    for (var i = 0; i < status.length; i++) {
      final v = status[i];
      if (v <= 0) continue;
      final cells = <int>[];
      var flagged = 0;
      for (final j in neighbors[i]) {
        final sj = status[j];
        if (sj == CellStatus.unknown) {
          cells.add(j);
        } else if (sj == CellStatus.flagged) {
          flagged++;
        }
      }
      if (cells.isNotEmpty) out.add(_Constraint(cells, v - flagged));
    }
    return out;
  }
}

final class _Constraint {
  _Constraint(this.cells, this.mines);

  final List<int> cells;
  final int mines;
}

int _min3(int a, int b, int c) => a < b ? (a < c ? a : c) : (b < c ? b : c);

int _max3(int a, int b, int c) => a > b ? (a > c ? a : c) : (b > c ? b : c);
