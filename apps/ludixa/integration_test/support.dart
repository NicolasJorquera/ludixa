import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_engine/sudoku_engine.dart';

/// Deja la app como recién instalada: sin preferencias ni base de progreso.
/// [locale] fija el idioma; [adPolicy] siembra los contadores de anuncios.
///
/// Borra los datos de la versión con la que corre la prueba (dev o prod) en
/// ese dispositivo.
Future<void> resetApp({String locale = 'es', Map<String, Object?>? adPolicy}) async {
  final prefs = SharedPreferencesAsync();
  await prefs.clear();
  await prefs.setString('settings.locale', locale);
  if (adPolicy != null) await prefs.setString('ads.policy', jsonEncode(adPolicy));
  final documents = await getApplicationDocumentsDirectory();
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final file = File('${documents.path}/progress.sqlite$suffix');
    if (file.existsSync()) file.deleteSync();
  }
}

/// Cómo anuncian los juegos sus celdas en cada idioma.
enum BoardLabels {
  es(row: 'Fila', column: 'columna', empty: 'vacía', given: 'fijo', pending: 'por encontrar'),
  en(row: 'Row', column: 'column', empty: 'empty', given: 'given', pending: 'to find');

  const BoardLabels({
    required this.row,
    required this.column,
    required this.empty,
    required this.given,
    required this.pending,
  });

  final String row;
  final String column;
  final String empty;
  final String given;
  final String pending;

  /// "Fila 1, columna 4, …"
  String cell(int r, int c) => '$row $r, $column $c, ';
}

/// Resuelve el Sudoku en pantalla con toques reales. El tablero se lee de
/// las etiquetas de semántica ("Fila 1, columna 4, 2, fijo" o "…, vacía").
/// [limit] deja de escribir después de esa cantidad de celdas.
Future<void> solveSudoku(WidgetTester tester, {BoardLabels labels = BoardLabels.es, int? limit}) async {
  final cell = RegExp('^${labels.row} (\\d), ${labels.column} (\\d), (?:(\\d), ${labels.given}|${labels.empty})\$');
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
  final solution = BitSolver.solve(grid)!;
  for (final (row, column) in empty.take(limit ?? empty.length)) {
    await tester.tap(find.bySemanticsLabel('${labels.cell(row, column)}${labels.empty}'));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(find.bySemanticsLabel(RegExp('^${solution[(row - 1) * 9 + column - 1]}, ')));
    await tester.pump(const Duration(milliseconds: 120));
  }
  await tester.pumpAndSettle();
}

/// Avanza hasta que [finder] encuentra algo: la base de progreso y la
/// generación responden desde otro isolate, y `pumpAndSettle` no las espera.
Future<void> pumpUntil(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 20)}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) throw TestFailure('No apareció: $finder');
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}
