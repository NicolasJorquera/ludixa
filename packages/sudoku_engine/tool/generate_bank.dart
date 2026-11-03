// Genera el banco de Sudokus pregenerados (lib/src/bank/bank_data.dart).
//
// Uso (desde packages/sudoku_engine):
//   dart compile exe tool/generate_bank.dart -o build/generate_bank && build/generate_bank --count 300
//   dart format lib/src/bank/bank_data.dart
//
// La salida es reproducible: con la misma versión del banco y del generador,
// vuelve a escribir el mismo archivo.
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:sudoku_engine/sudoku_engine.dart';

void main(List<String> args) {
  var count = 300;
  final countIndex = args.indexOf('--count');
  if (countIndex >= 0) count = int.parse(args[countIndex + 1]);

  final out = StringBuffer()
    ..writeln('// GENERADO por tool/generate_bank.dart: no editar a mano.')
    ..writeln('// Banco v${SudokuBank.version}, generador v${SudokuGenerator.version}, $count puzzles por nivel.')
    ..writeln('// Cada entrada son las 81 pistas por filas, con 0 para las celdas vacías.')
    ..writeln("import '../human/techniques.dart';")
    ..writeln()
    ..writeln('const sudokuBankData = <SudokuDifficulty, List<String>>{');
  for (final level in SudokuDifficulty.values) {
    final watch = Stopwatch()..start();
    final entries = SudokuBank.build(level, count);
    print('${level.name}: ${entries.length} puzzles en ${watch.elapsed.inMilliseconds} ms');
    out.writeln('  SudokuDifficulty.${level.name}: [');
    for (final e in entries) {
      out.writeln("    '$e',");
    }
    out.writeln('  ],');
  }
  out.writeln('};');
  File('lib/src/bank/bank_data.dart').writeAsStringSync(out.toString());
}
