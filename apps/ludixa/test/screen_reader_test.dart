import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

import 'support/test_app.dart';

/// H7-02: los retos de Sudoku y Sopa de letras se completan solo con lo que
/// ofrece el lector de pantalla. La prueba no toca la pantalla: lee el
/// tablero de las etiquetas de semántica y juega con sus acciones, como
/// TalkBack ("tocar dos veces para activar").
void main() {
  Future<SemanticsHandle> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      accessibleNavigation: true,
    );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final semantics = tester.ensureSemantics();
    await pumpLudixa(tester);
    await activate(tester, find.semantics.byLabel(RegExp(r'^Reto\n')));
    return semantics;
  }

  for (final game in ['Sudoku', 'Buscaminas', 'Sopa de letras']) {
    testWidgets('$game: la pista se anuncia con su nombre y lo que queda, y se activa', (tester) async {
      final semantics = await start(tester);
      await activate(tester, find.semantics.byLabel('Jugar $game'));
      final hint = find.semantics.byLabel('Pista').evaluate().single.getSemanticsData();
      expect(hint.value, 'quedan 2 gratis');
      expect(hint.hasAction(SemanticsAction.tap), isTrue);
      semantics.dispose();
    });
  }

  testWidgets('el reto de Sudoku se completa solo con el lector de pantalla', (tester) async {
    final semantics = await start(tester);
    await activate(tester, find.semantics.byLabel('Jugar Sudoku'));

    // El tablero, leído de las etiquetas: "Fila 1, columna 4, 2, fijo" o "…, vacía".
    final cell = RegExp(r'^Fila (\d), columna (\d), (?:(\d), fijo|vacía)$');
    final grid = List.filled(81, 0);
    final empty = <(int, int)>[];
    for (final node in find.semantics.byLabel(cell).evaluate()) {
      final m = cell.firstMatch(node.label)!;
      final (row, column) = (int.parse(m[1]!), int.parse(m[2]!));
      if (m[3] case final digit?) {
        grid[(row - 1) * 9 + column - 1] = int.parse(digit);
      } else {
        empty.add((row, column));
      }
    }
    expect(grid.where((d) => d > 0).length + empty.length, 81);
    final solution = BitSolver.solve(grid)!;

    for (final (row, column) in empty) {
      await activate(tester, find.semantics.byLabel('Fila $row, columna $column, vacía'));
      final digit = solution[(row - 1) * 9 + column - 1];
      await activate(tester, find.semantics.byLabel(RegExp('^$digit, ')));
    }
    await tester.pumpAndSettle();
    expect(find.semantics.byLabel(RegExp('Reto: 1 de 3')), findsOne);
    semantics.dispose();
  });

  testWidgets('el reto de Sopa de letras se completa solo con el lector de pantalla', (tester) async {
    final semantics = await start(tester);
    await activate(tester, find.semantics.byLabel('Jugar Sopa de letras'));
    // Con TalkBack la selección es por toques: letra inicial y letra final.
    expect(find.semantics.byLabel('Toca la letra inicial'), findsOne);

    final cell = RegExp(r'^Fila (\d+), columna (\d+), (\S+)$');
    final letters = <(int, int), String>{};
    for (final node in find.semantics.byLabel(cell).evaluate()) {
      final m = cell.firstMatch(node.label)!;
      letters[(int.parse(m[1]!), int.parse(m[2]!))] = m[3]!;
    }
    final size = letters.keys.map((k) => k.$1).reduce((a, b) => a > b ? a : b);
    expect(letters, hasLength(size * size));

    // La lista de palabras viene abierta si hay lugar; si no, se abre.
    final show = find.semantics.byLabel('Ver palabras');
    if (show.evaluate().isNotEmpty) await activate(tester, show);
    final pending = RegExp(r'^(.+), por encontrar$');
    final words = [for (final node in find.semantics.byLabel(pending).evaluate()) pending.firstMatch(node.label)![1]!];
    expect(words, isNotEmpty);

    // Con la última palabra el juego termina y pasa al Resultado.
    final result = find.semantics.byLabel(RegExp('Reto: 1 de 3'));
    for (final word in words) {
      final found = find.semantics.byLabel('$word, encontrada');
      // La palabra puede formarse también por azar en el relleno: se prueba
      // cada lugar hasta que el juego la acepte, como haría una persona.
      for (final (start, end) in _locate(_fold(word), letters, size)) {
        // La etiqueta suma el estado (", seleccionada"): se busca por el inicio.
        for (final (row, column) in [start, end]) {
          await activate(
            tester,
            find.semantics.byLabel(RegExp('^Fila $row, columna $column, ${letters[(row, column)]}')),
          );
        }
        if (found.evaluate().isNotEmpty || result.evaluate().isNotEmpty) break;
      }
      expect(word == words.last ? result : found, findsOne, reason: word);
    }
    semantics.dispose();
  });
}

/// Activa un nodo como TalkBack: la acción de tocar, sin coordenadas.
Future<void> activate(WidgetTester tester, SemanticsFinder finder) async {
  tester.semantics.tap(finder);
  await tester.pumpAndSettle();
}

/// Forma de la palabra en la grilla: mayúsculas y sin tildes (la Ñ se queda).
String _fold(String word) => word
    .toUpperCase()
    .replaceAll('Á', 'A')
    .replaceAll('É', 'E')
    .replaceAll('Í', 'I')
    .replaceAll('Ó', 'O')
    .replaceAll(RegExp('[ÚÜ]'), 'U');

/// Cada inicio y fin de [word] en la grilla, en cualquiera de las 8 direcciones.
Iterable<((int, int), (int, int))> _locate(String word, Map<(int, int), String> letters, int size) sync* {
  final chars = word.split('');
  for (var row = 1; row <= size; row++) {
    for (var column = 1; column <= size; column++) {
      for (final (dr, dc) in const [(0, 1), (1, 0), (1, 1), (1, -1), (0, -1), (-1, 0), (-1, -1), (-1, 1)]) {
        var ok = true;
        for (var i = 0; i < chars.length && ok; i++) {
          ok = letters[(row + dr * i, column + dc * i)] == chars[i];
        }
        if (ok) yield ((row, column), (row + dr * (chars.length - 1), column + dc * (chars.length - 1)));
      }
    }
  }
}
