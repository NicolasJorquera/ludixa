import 'dart:typed_data';

import 'package:puzzle_core/puzzle_core.dart';

import '../generator.dart';
import '../layout.dart';
import 'hint.dart';

/// Estado de la partida.
enum GameStatus {
  /// Esperando el primer toque (partida libre: el tablero aún no existe).
  ready,
  playing,
  won,
  lost,
}

/// Lo que se ve de una celda.
enum CellView {
  hidden,
  flagged,

  /// Revelada; el número está en [MinesweeperGame.numberAt].
  revealed,

  /// Tras perder: mina sin bandera.
  mine,

  /// Tras perder: la mina que terminó la partida.
  fatal,

  /// Tras perder: bandera puesta en una celda sin mina.
  wrongFlag,
}

/// Resultado de un movimiento.
enum MoveOutcome {
  /// No cambió nada (celda ya revelada, partida terminada, etc.).
  ignored,
  changed,
  won,
  lost,
}

const _hidden = 0;
const _revealed = 1;
const _flagged = 2;

/// Partida de Buscaminas: reglas, deshacer, rescate, pistas y guardado.
///
/// Es Dart puro y no depende del tiempo: el temporizador vive en la interfaz.
/// En la partida libre el tablero se genera tras el primer toque, fuera de este
/// objeto (en un isolate) con [generateBoard], y se entrega con [begin].
final class MinesweeperGame {
  MinesweeperGame._({
    required this.spec,
    required this.seed,
    required this.suggestedStart,
    MineLayout? layout,
    Uint8List? cells,
    GameStatus? status,
    this.fatal,
    this.rescueUsed = false,
    List<List<int>>? history,
  }) : _layout = layout,
       _cells = cells ?? Uint8List(spec.cellCount),
       _status = status ?? (layout == null ? GameStatus.ready : GameStatus.playing),
       _history = history ?? <List<int>>[];

  /// Partida libre: el tablero se genera tras el primer toque, donde sea.
  factory MinesweeperGame.free({required BoardSpec spec, required PuzzleSeed seed}) =>
      MinesweeperGame._(spec: spec, seed: seed, suggestedStart: null);

  /// Reto diario: tablero y celda de inicio salen de la semilla, iguales para
  /// todos. La interfaz señala [suggestedStart].
  factory MinesweeperGame.daily({required BoardSpec spec, required PuzzleSeed seed}) {
    final board = const NoGuessGenerator().generateDaily(spec, seed);
    return MinesweeperGame._(spec: spec, seed: seed, suggestedStart: board.start, layout: board.layout);
  }

  /// Genera el tablero de una partida libre para el primer toque [start].
  /// Es determinista y pesado: llamarlo dentro de `Isolate.run`.
  static MineLayout generateBoard(BoardSpec spec, String seedKey, int start) =>
      const NoGuessGenerator().generate(spec, PuzzleSeed.fromKey(seedKey).createRandom(), start).layout;

  final BoardSpec spec;
  final PuzzleSeed seed;

  /// Celda de inicio recomendada (solo en el reto diario).
  final int? suggestedStart;

  MineLayout? _layout;
  final Uint8List _cells;
  GameStatus _status;
  final List<List<int>> _history;

  /// Mina que terminó la partida.
  int? fatal;

  /// Ya se usó el rescate (deshacer el error fatal con un video).
  bool rescueUsed;

  GameStatus get status => _status;

  bool get isOver => _status == GameStatus.won || _status == GameStatus.lost;

  /// Falta el tablero: la próxima jugada debe ser [begin].
  bool get needsBoard => _layout == null;

  Geometry get geometry => Geometry.of(spec.width, spec.height);

  int get flagCount => _cells.where((c) => c == _flagged).length;

  /// Contador de la interfaz: minas menos banderas (puede ser negativo).
  int get minesRemaining => spec.mines - flagCount;

  bool get canUndo => _status == GameStatus.playing && _history.isNotEmpty;

  /// Se puede ofrecer el rescate: se perdió y aún no se usó.
  bool get canRescue => _status == GameStatus.lost && !rescueUsed;

  /// Número de minas vecinas de una celda revelada.
  int numberAt(int index) => _layout!.numbers[index];

  CellView viewAt(int index) {
    final state = _cells[index];
    if (_status == GameStatus.lost) {
      final mine = _layout!.isMine(index);
      if (index == fatal) return CellView.fatal;
      if (state == _flagged) return mine ? CellView.flagged : CellView.wrongFlag;
      if (mine) return CellView.mine;
    }
    return switch (state) {
      _revealed => CellView.revealed,
      _flagged => CellView.flagged,
      _ => CellView.hidden,
    };
  }

  /// Entrega el tablero generado para el primer toque.
  void begin(MineLayout layout) {
    if (_layout != null) throw StateError('El tablero ya existe');
    if (layout.spec.width != spec.width || layout.spec.height != spec.height || layout.spec.mines != spec.mines) {
      throw ArgumentError('El tablero no coincide con $spec');
    }
    _layout = layout;
    _status = GameStatus.playing;
  }

  /// Revela una celda. Si es 0, abre la zona en cascada.
  MoveOutcome reveal(int index) {
    _requireBoard();
    if (_status != GameStatus.playing || _cells[index] != _hidden) return MoveOutcome.ignored;
    final changes = <int>[];
    if (_layout!.isMine(index)) return _lose(index, changes);
    _flood(index, changes);
    return _commit(changes);
  }

  /// Pone o quita una bandera en una celda sin revelar.
  MoveOutcome toggleFlag(int index) {
    _requireBoard();
    if (_status != GameStatus.playing || _cells[index] == _revealed) return MoveOutcome.ignored;
    final changes = <int>[index, _cells[index]];
    _cells[index] = _cells[index] == _flagged ? _hidden : _flagged;
    _history.add(changes);
    return MoveOutcome.changed;
  }

  /// Toque sobre un número con todas sus banderas: revela sus otras vecinas.
  /// Si alguna bandera estaba mal, revela una mina y se pierde.
  MoveOutcome chord(int index) {
    _requireBoard();
    if (_status != GameStatus.playing || _cells[index] != _revealed) return MoveOutcome.ignored;
    final neighbors = geometry.neighbors[index];
    var flags = 0;
    for (final n in neighbors) {
      if (_cells[n] == _flagged) flags++;
    }
    if (flags != numberAt(index)) return MoveOutcome.ignored;
    final changes = <int>[];
    for (final n in neighbors) {
      if (_cells[n] != _hidden) continue;
      if (_layout!.isMine(n)) return _lose(n, changes);
      _flood(n, changes);
    }
    return changes.isEmpty ? MoveOutcome.ignored : _commit(changes);
  }

  /// Deshace la última jugada (no después de ganar o perder).
  bool undo() {
    if (!canUndo) return false;
    _restore(_history.removeLast());
    return true;
  }

  /// Rescate: deshace la jugada que perdió la partida. Una vez por partida.
  bool rescue() {
    if (!canRescue) return false;
    _restore(_history.removeLast());
    fatal = null;
    rescueUsed = true;
    _status = GameStatus.playing;
    return true;
  }

  /// Pista: primero una bandera equivocada; si no hay, la siguiente deducción
  /// a partir de lo que el jugador ve. Null si la partida no está en juego.
  MinesweeperHint? hint() {
    if (_status != GameStatus.playing) return null;
    final layout = _layout!;
    for (var i = 0; i < _cells.length; i++) {
      if (_cells[i] == _flagged && !layout.isMine(i)) {
        return MinesweeperHint(cell: i, isMine: false, reason: HintReason.wrongFlag);
      }
    }
    return _deduce() ?? _fallbackHint();
  }

  // ── Reglas internas ────────────────────────────────────────────────────────

  void _requireBoard() {
    if (_layout == null) throw StateError('Falta el tablero: llamar a begin() con el tablero generado');
  }

  void _flood(int start, List<int> changes) {
    final stack = <int>[start];
    while (stack.isNotEmpty) {
      final i = stack.removeLast();
      if (_cells[i] != _hidden) continue;
      changes
        ..add(i)
        ..add(_hidden);
      _cells[i] = _revealed;
      if (_layout!.numbers[i] == 0) {
        for (final n in geometry.neighbors[i]) {
          if (_cells[n] == _hidden) stack.add(n);
        }
      }
    }
  }

  MoveOutcome _commit(List<int> changes) {
    _history.add(changes);
    if (_allSafeRevealed()) {
      _status = GameStatus.won;
      // Las minas restantes se marcan solas.
      for (final m in _layout!.mineIndices) {
        _cells[m] = _flagged;
      }
      return MoveOutcome.won;
    }
    return MoveOutcome.changed;
  }

  MoveOutcome _lose(int mine, List<int> changes) {
    // La jugada perdedora queda en el historial para poder rescatarla.
    _history.add(changes);
    fatal = mine;
    _status = GameStatus.lost;
    return MoveOutcome.lost;
  }

  void _restore(List<int> changes) {
    for (var k = changes.length - 2; k >= 0; k -= 2) {
      _cells[changes[k]] = changes[k + 1];
    }
  }

  bool _allSafeRevealed() {
    final layout = _layout!;
    for (var i = 0; i < _cells.length; i++) {
      if (_cells[i] != _revealed && !layout.isMine(i)) return false;
    }
    return true;
  }

  /// Deducciones desde lo visible. Las banderas ya están verificadas como
  /// correctas por [hint], así que cuentan como minas conocidas.
  MinesweeperHint? _deduce() {
    final neighbors = geometry.neighbors;
    final constraints = <_Constraint>[];
    for (var i = 0; i < _cells.length; i++) {
      if (_cells[i] != _revealed) continue;
      final unknown = <int>[];
      var flags = 0;
      for (final n in neighbors[i]) {
        if (_cells[n] == _hidden) unknown.add(n);
        if (_cells[n] == _flagged) flags++;
      }
      if (unknown.isEmpty) continue;
      final need = numberAt(i) - flags;
      if (need == 0) {
        return MinesweeperHint(cell: unknown.first, isMine: false, reason: HintReason.numberSatisfied, sources: [i]);
      }
      if (need == unknown.length) {
        return MinesweeperHint(cell: unknown.first, isMine: true, reason: HintReason.numberNeedsAll, sources: [i]);
      }
      constraints.add(_Constraint(i, unknown, need));
    }

    for (var a = 0; a < constraints.length; a++) {
      for (var b = 0; b < constraints.length; b++) {
        if (a == b) continue;
        final ca = constraints[a];
        final cb = constraints[b];
        if (!ca.cells.any(cb.cells.contains)) continue;
        final inter = ca.cells.where(cb.cells.contains).length;
        final aOnly = ca.cells.length - inter;
        final bOnly = cb.cells.where((c) => !ca.cells.contains(c)).toList();
        if (bOnly.isEmpty) continue;
        final maxInter = [inter, ca.need, cb.need].reduce((x, y) => x < y ? x : y);
        final minInter = [0, ca.need - aOnly, cb.need - bOnly.length].reduce((x, y) => x > y ? x : y);
        if (cb.need - maxInter >= bOnly.length) {
          return MinesweeperHint(
            cell: bOnly.first,
            isMine: true,
            reason: HintReason.twoNumbers,
            sources: [ca.source, cb.source],
          );
        }
        if (cb.need - minInter <= 0) {
          return MinesweeperHint(
            cell: bOnly.first,
            isMine: false,
            reason: HintReason.twoNumbers,
            sources: [ca.source, cb.source],
          );
        }
      }
    }

    final hidden = [
      for (var i = 0; i < _cells.length; i++)
        if (_cells[i] == _hidden) i,
    ];
    final remaining = spec.mines - flagCount;
    if (hidden.isNotEmpty && (remaining == 0 || remaining == hidden.length)) {
      return MinesweeperHint(cell: hidden.first, isMine: remaining != 0, reason: HintReason.mineCount);
    }
    return null;
  }

  MinesweeperHint? _fallbackHint() {
    final layout = _layout!;
    for (var i = 0; i < _cells.length; i++) {
      if (_cells[i] == _hidden && !layout.isMine(i)) {
        return MinesweeperHint(cell: i, isMine: false, reason: HintReason.safeReveal);
      }
    }
    return null;
  }

  // ── Guardado ───────────────────────────────────────────────────────────────

  static const _version = 1;
  static const _codes = 'hrf';

  /// Estado completo para guardar la partida en curso.
  Map<String, Object?> toJson() => {
    'v': _version,
    'spec': [spec.width, spec.height, spec.mines],
    'seed': seed.key,
    'start': suggestedStart,
    'mines': _layout?.mineIndices.toList(),
    'cells': String.fromCharCodes(_cells.map((c) => _codes.codeUnitAt(c))),
    'status': _status.name,
    'fatal': fatal,
    'rescueUsed': rescueUsed,
    'history': _history,
  };

  factory MinesweeperGame.fromJson(Map<String, Object?> json) {
    if (json['v'] != _version) throw FormatException('Versión de guardado no soportada: ${json['v']}');
    final dims = (json['spec']! as List).cast<int>();
    final spec = BoardSpec(width: dims[0], height: dims[1], mines: dims[2]);
    final mineList = (json['mines'] as List?)?.cast<int>();
    MineLayout? layout;
    if (mineList != null) {
      final bytes = Uint8List(spec.cellCount);
      for (final m in mineList) {
        bytes[m] = 1;
      }
      layout = MineLayout(spec, bytes);
    }
    final cells = Uint8List.fromList((json['cells']! as String).codeUnits.map(_codes.codeUnits.indexOf).toList());
    if (cells.length != spec.cellCount || cells.contains(-1)) throw const FormatException('Celdas inválidas');
    return MinesweeperGame._(
      spec: spec,
      seed: PuzzleSeed.fromKey(json['seed']! as String),
      suggestedStart: json['start'] as int?,
      layout: layout,
      cells: cells,
      status: GameStatus.values.byName(json['status']! as String),
      fatal: json['fatal'] as int?,
      rescueUsed: json['rescueUsed']! as bool,
      history: [for (final move in json['history']! as List) (move as List).cast<int>().toList()],
    );
  }
}

final class _Constraint {
  _Constraint(this.source, this.cells, this.need);

  final int source;
  final List<int> cells;
  final int need;
}
