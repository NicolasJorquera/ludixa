import 'dart:typed_data';

import 'generator.dart';
import 'grid.dart';
import 'human/techniques.dart';

/// Partida de Sudoku: lo que el jugador escribe sobre un puzzle.
///
/// No hay límite de errores ni derrota (PRD): los errores solo se señalan,
/// según el modo que elija la interfaz ([conflicts] o [mistakes]).
final class SudokuGame {
  SudokuGame(this.puzzle, {this.removeNotesOnPlace = true})
    : _values = Uint8List.fromList(puzzle.givens),
      _notes = Uint16List(SudokuGrid.cellCount);

  static const int saveVersion = 1;

  final SudokuPuzzle puzzle;

  /// Al colocar un número se borra ese candidato de las notas de su fila,
  /// columna y caja (PRD; se puede desactivar).
  bool removeNotesOnPlace;

  final Uint8List _values;
  final Uint16List _notes;
  final List<(Uint8List, Uint16List)> _history = [];

  int valueAt(int cell) => _values[cell];
  bool isGiven(int cell) => puzzle.givens[cell] != 0;

  /// Candidatos anotados en una celda vacía, de menor a mayor.
  List<int> notesAt(int cell) => digitsOf(_notes[cell]);

  bool get canUndo => _history.isNotEmpty;
  bool get isSolved => _values.every((v) => v != 0) && _sameAs(puzzle.solution);

  /// Celdas vacías al empezar.
  int get emptyAtStart => puzzle.givens.where((v) => v == 0).length;

  /// Celdas que el jugador llenó (correctas o no).
  int get filledByPlayer => [
    for (var i = 0; i < SudokuGrid.cellCount; i++)
      if (!isGiven(i) && _values[i] != 0) i,
  ].length;

  /// Veces que aparece [digit] en la grilla (para el teclado: 9 = completo).
  int countOf(int digit) => _values.where((v) => v == digit).length;

  /// Celdas con un número repetido en su fila, columna o caja.
  Set<int> get conflicts => {
    for (var i = 0; i < SudokuGrid.cellCount; i++)
      if (_values[i] != 0 && SudokuGrid.peers[i].any((p) => _values[p] == _values[i])) i,
  };

  /// Números del jugador que no coinciden con la solución.
  Set<int> get mistakes => {
    for (var i = 0; i < SudokuGrid.cellCount; i++)
      if (!isGiven(i) && _values[i] != 0 && _values[i] != puzzle.solution[i]) i,
  };

  /// Coloca [digit] en [cell]. Si ya estaba, lo quita. Devuelve si cambió algo.
  bool place(int cell, int digit) {
    _checkDigit(digit);
    if (isGiven(cell)) return false;
    _record();
    if (_values[cell] == digit) {
      _values[cell] = 0;
    } else {
      _values[cell] = digit;
      _notes[cell] = 0;
      if (removeNotesOnPlace) {
        for (final p in SudokuGrid.peers[cell]) {
          _notes[p] &= ~(1 << digit);
        }
      }
    }
    return true;
  }

  /// Anota o quita [digit] como candidato de una celda vacía.
  bool toggleNote(int cell, int digit) {
    _checkDigit(digit);
    if (isGiven(cell) || _values[cell] != 0) return false;
    _record();
    _notes[cell] ^= 1 << digit;
    return true;
  }

  /// Borra el número y las notas de una celda.
  bool erase(int cell) {
    if (isGiven(cell) || (_values[cell] == 0 && _notes[cell] == 0)) return false;
    _record();
    _values[cell] = 0;
    _notes[cell] = 0;
    return true;
  }

  /// Deshace el último cambio. Sin límite.
  bool undo() {
    if (_history.isEmpty) return false;
    final (values, notes) = _history.removeLast();
    _values.setAll(0, values);
    _notes.setAll(0, notes);
    return true;
  }

  /// Valores actuales (pistas incluidas), para la pista y el guardado.
  Uint8List get values => Uint8List.fromList(_values);

  Map<String, Object?> toJson() => {
    'v': saveVersion,
    'difficulty': puzzle.difficulty.name,
    'givens': formatGrid(puzzle.givens),
    'solution': formatGrid(puzzle.solution),
    'values': formatGrid(_values),
    'notes': _notes.toList(),
    'removeNotesOnPlace': removeNotesOnPlace,
    'history': [
      for (final (values, notes) in _history) {'values': formatGrid(values), 'notes': notes.toList()},
    ],
  };

  factory SudokuGame.fromJson(Map<String, Object?> json) {
    if (json['v'] != saveVersion) throw FormatException('Versión de guardado desconocida', json['v']);
    final puzzle = SudokuPuzzle(
      givens: parseGrid(json['givens']! as String),
      solution: parseGrid(json['solution']! as String),
      difficulty: SudokuDifficulty.values.byName(json['difficulty']! as String),
    );
    Uint16List notesFrom(Object? list) => Uint16List.fromList([for (final n in list! as List) n as int]);
    final game = SudokuGame(puzzle, removeNotesOnPlace: json['removeNotesOnPlace'] as bool? ?? true);
    game._values.setAll(0, parseGrid(json['values']! as String));
    game._notes.setAll(0, notesFrom(json['notes']));
    for (final entry in json['history'] as List? ?? const []) {
      final map = entry as Map;
      game._history.add((parseGrid(map['values'] as String), notesFrom(map['notes'])));
    }
    return game;
  }

  void _record() => _history.add((Uint8List.fromList(_values), Uint16List.fromList(_notes)));

  bool _sameAs(List<int> other) {
    for (var i = 0; i < SudokuGrid.cellCount; i++) {
      if (_values[i] != other[i]) return false;
    }
    return true;
  }

  static void _checkDigit(int digit) => RangeError.checkValueInInterval(digit, 1, 9, 'digit');
}
