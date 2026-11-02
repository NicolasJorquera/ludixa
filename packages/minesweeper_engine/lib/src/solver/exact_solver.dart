import 'dart:typed_data';

import '../layout.dart';
import 'solve_state.dart';

/// Resultado de [ExactSolver.solve].
enum ExactOutcome {
  /// Se despejó el tablero solo con deducciones.
  solved,

  /// En algún momento ninguna celda era deducible: había que adivinar.
  stuck,

  /// La enumeración superó el límite de nodos sin concluir.
  limitExceeded,
}

/// Verificador exacto e independiente del [RuleSolver].
///
/// En cada paso enumera todas las asignaciones de minas compatibles con lo
/// revelado (por componentes de la frontera) y las combina con el conteo
/// global. Una celda es segura si es libre en todas las asignaciones posibles,
/// y es mina si lo es en todas. Es la deducción más fuerte posible, así que si
/// este solver se atasca, el tablero exige adivinar.
///
/// Es caro: se usa en pruebas y herramientas, no al generar en el dispositivo.
final class ExactSolver {
  const ExactSolver({this.nodeLimit = 20000000});

  /// Máximo de nodos de búsqueda por resolución completa.
  final int nodeLimit;

  ExactOutcome solve(MineLayout layout, int start) {
    final state = SolveState(layout)..reveal(start);
    final budget = _Budget(nodeLimit);
    while (!state.isSolved) {
      final step = _deduce(state, budget);
      if (step == null) return ExactOutcome.limitExceeded;
      if (step.safe.isEmpty && step.mines.isEmpty) return ExactOutcome.stuck;
      for (final i in step.mines) {
        state.flag(i);
      }
      for (final i in step.safe) {
        state.reveal(i);
      }
    }
    return ExactOutcome.solved;
  }

  _Step? _deduce(SolveState s, _Budget budget) {
    final status = s.status;
    final neighbors = s.geometry.neighbors;
    final n = status.length;

    // Restricciones: números revelados con vecinas desconocidas.
    final consCells = <List<int>>[];
    final consMines = <int>[];
    final isFrontier = Uint8List(n);
    for (var i = 0; i < n; i++) {
      final v = status[i];
      if (v < 0) continue;
      final cells = <int>[];
      var flagged = 0;
      for (final j in neighbors[i]) {
        if (status[j] == CellStatus.unknown) {
          cells.add(j);
        } else if (status[j] == CellStatus.flagged) {
          flagged++;
        }
      }
      if (cells.isEmpty) continue;
      consCells.add(cells);
      consMines.add(v - flagged);
      for (final c in cells) {
        isFrontier[c] = 1;
      }
    }

    var interior = 0;
    for (var i = 0; i < n; i++) {
      if (status[i] == CellStatus.unknown && isFrontier[i] == 0) interior++;
    }
    final remaining = s.remainingMines;

    // Componentes de la frontera: celdas unidas por compartir una restricción.
    final parent = <int, int>{};
    int find(int x) {
      var r = x;
      while (parent[r] != r) {
        r = parent[r]!;
      }
      var y = x;
      while (parent[y] != r) {
        final next = parent[y]!;
        parent[y] = r;
        y = next;
      }
      return r;
    }

    for (final cells in consCells) {
      for (final c in cells) {
        parent.putIfAbsent(c, () => c);
      }
      for (var k = 1; k < cells.length; k++) {
        final a = find(cells[0]);
        final b = find(cells[k]);
        if (a != b) parent[a] = b;
      }
    }
    final groups = <int, List<int>>{};
    for (final c in parent.keys) {
      (groups[find(c)] ??= <int>[]).add(c);
    }
    final groupCons = <int, List<int>>{};
    for (var k = 0; k < consCells.length; k++) {
      (groupCons[find(consCells[k][0])] ??= <int>[]).add(k);
    }

    final components = <_Component>[];
    for (final entry in groups.entries) {
      final component = _enumerate(entry.value, groupCons[entry.key]!, consCells, consMines, remaining, budget);
      if (component == null) return null;
      components.add(component);
    }

    // Combinación global: qué cantidades de minas por componente son posibles
    // dado el total restante y las celdas interiores.
    final count = components.length;
    final prefix = List<Set<int>>.filled(count + 1, const <int>{});
    prefix[0] = {0};
    for (var c = 0; c < count; c++) {
      prefix[c + 1] = _sumSets(prefix[c], components[c].byMines.keys, remaining);
    }
    final suffix = List<Set<int>>.filled(count + 1, const <int>{});
    suffix[count] = {0};
    for (var c = count - 1; c >= 0; c--) {
      suffix[c] = _sumSets(suffix[c + 1], components[c].byMines.keys, remaining);
    }

    bool fits(int frontierMines) => remaining - frontierMines >= 0 && remaining - frontierMines <= interior;

    final safe = <int>[];
    final mines = <int>[];
    for (var c = 0; c < count; c++) {
      final comp = components[c];
      final others = _sumSets(prefix[c], suffix[c + 1], remaining);
      final canMine = Uint8List(comp.cells.length);
      final canSafe = Uint8List(comp.cells.length);
      for (final entry in comp.byMines.entries) {
        final m = entry.key;
        if (!others.any((o) => fits(m + o))) continue;
        final flags = entry.value;
        for (var k = 0; k < comp.cells.length; k++) {
          if (flags.canMine[k] == 1) canMine[k] = 1;
          if (flags.canSafe[k] == 1) canSafe[k] = 1;
        }
      }
      for (var k = 0; k < comp.cells.length; k++) {
        if (canMine[k] == 0 && canSafe[k] == 1) safe.add(comp.cells[k]);
        if (canSafe[k] == 0 && canMine[k] == 1) mines.add(comp.cells[k]);
      }
    }

    if (interior > 0) {
      var interiorCanMine = false;
      var interiorCanSafe = false;
      for (final total in prefix[count]) {
        if (!fits(total)) continue;
        final interiorMines = remaining - total;
        if (interiorMines >= 1) interiorCanMine = true;
        if (interiorMines <= interior - 1) interiorCanSafe = true;
      }
      if (interiorCanMine != interiorCanSafe) {
        for (var i = 0; i < n; i++) {
          if (status[i] != CellStatus.unknown || isFrontier[i] == 1) continue;
          (interiorCanSafe ? safe : mines).add(i);
        }
      }
    }
    return _Step(safe, mines);
  }

  /// Enumera las asignaciones de un componente agrupadas por cantidad de minas.
  _Component? _enumerate(
    List<int> cells,
    List<int> consIds,
    List<List<int>> consCells,
    List<int> consMines,
    int remaining,
    _Budget budget,
  ) {
    final local = <int, int>{for (var k = 0; k < cells.length; k++) cells[k]: k};
    final cellCons = List<List<int>>.generate(cells.length, (_) => <int>[]);
    final need = Int32List(consIds.length);
    final open = Int32List(consIds.length);
    final assigned = Int32List(consIds.length);
    for (var c = 0; c < consIds.length; c++) {
      final id = consIds[c];
      need[c] = consMines[id];
      open[c] = consCells[id].length;
      for (final cell in consCells[id]) {
        cellCons[local[cell]!].add(c);
      }
    }
    final value = Int8List(cells.length);
    final byMines = <int, _Flags>{};
    var exceeded = false;

    void record(int mines) {
      final flags = byMines.putIfAbsent(mines, () => _Flags(cells.length));
      for (var k = 0; k < cells.length; k++) {
        if (value[k] == 1) {
          flags.canMine[k] = 1;
        } else {
          flags.canSafe[k] = 1;
        }
      }
    }

    void dfs(int pos, int mines) {
      if (exceeded) return;
      if (!budget.spend()) {
        exceeded = true;
        return;
      }
      if (pos == cells.length) {
        record(mines);
        return;
      }
      for (var v = 0; v <= 1; v++) {
        if (v == 1 && mines + 1 > remaining) continue;
        var ok = true;
        for (final c in cellCons[pos]) {
          open[c]--;
          assigned[c] += v;
          if (assigned[c] > need[c] || assigned[c] + open[c] < need[c]) ok = false;
        }
        if (ok) {
          value[pos] = v;
          dfs(pos + 1, mines + v);
        }
        for (final c in cellCons[pos]) {
          open[c]++;
          assigned[c] -= v;
        }
        if (exceeded) return;
      }
    }

    dfs(0, 0);
    if (exceeded) return null;
    return _Component(cells, byMines);
  }

  static Set<int> _sumSets(Iterable<int> a, Iterable<int> b, int cap) {
    final out = <int>{};
    for (final x in a) {
      for (final y in b) {
        if (x + y <= cap) out.add(x + y);
      }
    }
    return out;
  }
}

final class _Budget {
  _Budget(this._left);

  int _left;

  bool spend() => --_left >= 0;
}

final class _Flags {
  _Flags(int size) : canMine = Uint8List(size), canSafe = Uint8List(size);

  final Uint8List canMine;
  final Uint8List canSafe;
}

final class _Component {
  _Component(this.cells, this.byMines);

  final List<int> cells;
  final Map<int, _Flags> byMines;
}

final class _Step {
  _Step(this.safe, this.mines);

  final List<int> safe;
  final List<int> mines;
}
