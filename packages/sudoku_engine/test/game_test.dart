import 'dart:convert';

import 'package:sudoku_engine/sudoku_engine.dart';
import 'package:test/test.dart';

SudokuGame _game() => SudokuGame(SudokuBank.at(SudokuDifficulty.easy, 0));

int _emptyCell(SudokuGame g, [int skip = 0]) {
  var seen = 0;
  for (var i = 0; i < 81; i++) {
    if (!g.isGiven(i) && seen++ == skip) return i;
  }
  throw StateError('sin celdas vacías');
}

void main() {
  test('colocar, repetir el mismo número lo quita, y las pistas no se tocan', () {
    final g = _game();
    final cell = _emptyCell(g);
    expect(g.place(cell, 5), isTrue);
    expect(g.valueAt(cell), 5);
    expect(g.place(cell, 5), isTrue);
    expect(g.valueAt(cell), 0);
    final given = g.puzzle.givens.indexWhere((v) => v != 0);
    expect(g.place(given, 1), isFalse);
    expect(g.erase(given), isFalse);
  });

  test('notas: solo en celdas vacías; colocar borra la nota en fila, columna y caja', () {
    final g = _game();
    final cell = _emptyCell(g);
    final peer = SudokuGrid.peers[cell].firstWhere((p) => !g.isGiven(p));
    g.toggleNote(peer, 4);
    g.toggleNote(peer, 7);
    g.toggleNote(cell, 4);
    expect(g.notesAt(cell), [4]);
    g.place(cell, 4);
    expect(g.notesAt(cell), isEmpty);
    expect(g.notesAt(peer), [7]);
    expect(g.toggleNote(cell, 2), isFalse);
  });

  test('sin borrado automático, las notas vecinas se conservan', () {
    final g = _game()..removeNotesOnPlace = false;
    final cell = _emptyCell(g);
    final peer = SudokuGrid.peers[cell].firstWhere((p) => !g.isGiven(p));
    g.toggleNote(peer, 4);
    g.place(cell, 4);
    expect(g.notesAt(peer), [4]);
  });

  test('conflictos por regla y errores contra la solución son cosas distintas', () {
    final g = _game();
    final cell = _emptyCell(g);
    final correct = g.puzzle.solution[cell];
    final peerGiven = SudokuGrid.peers[cell].firstWhere(g.isGiven);
    g.place(cell, g.puzzle.givens[peerGiven]);
    expect(g.conflicts, containsAll([cell, peerGiven]));
    expect(g.mistakes, {cell});
    // Un número equivocado sin conflicto visible: error, no conflicto.
    final g2 = _game();
    final c2 = _emptyCell(g2);
    final wrong = [
      for (var d = 1; d <= 9; d++)
        if (d != g2.puzzle.solution[c2] && SudokuGrid.peers[c2].every((p) => g2.valueAt(p) != d)) d,
    ];
    if (wrong.isNotEmpty) {
      g2.place(c2, wrong.first);
      expect(g2.conflicts, isEmpty);
      expect(g2.mistakes, {c2});
    }
    g.place(cell, correct);
    expect(g.conflicts, isEmpty);
  });

  test('deshacer es ilimitado y vuelve exactamente al estado anterior', () {
    final g = _game();
    final a = _emptyCell(g), b = _emptyCell(g, 1);
    final start = g.toJson()['values'];
    g
      ..toggleNote(a, 3)
      ..place(a, 2)
      ..place(b, 6)
      ..erase(b);
    expect(g.canUndo, isTrue);
    while (g.undo()) {}
    expect(g.toJson()['values'], start);
    expect(g.notesAt(a), isEmpty);
    expect(g.canUndo, isFalse);
  });

  test('conteo por número y avance', () {
    final g = _game();
    final cell = _emptyCell(g);
    final digit = g.puzzle.solution[cell];
    final before = g.countOf(digit);
    g.place(cell, digit);
    expect(g.countOf(digit), before + 1);
    expect(g.filledByPlayer, 1);
    expect(g.emptyAtStart, 81 - g.puzzle.givenCount);
  });

  test('llenar con la solución resuelve', () {
    final g = _game();
    for (var i = 0; i < 81; i++) {
      if (!g.isGiven(i)) g.place(i, g.puzzle.solution[i]);
    }
    expect(g.isSolved, isTrue);
    expect(g.countOf(1), 9);
  });

  test('guardado de ida y vuelta conserva valores, notas e historial', () {
    final g = _game();
    final a = _emptyCell(g);
    g
      ..toggleNote(a, 8)
      ..place(_emptyCell(g, 1), 3);
    final copy = SudokuGame.fromJson(jsonDecode(jsonEncode(g.toJson())) as Map<String, Object?>);
    expect(copy.toJson(), g.toJson());
    copy.undo();
    expect(copy.notesAt(a), [8]);
    expect(copy.filledByPlayer, 0);
    expect(() => SudokuGame.fromJson({...g.toJson(), 'v': 9}), throwsFormatException);
  });
}
