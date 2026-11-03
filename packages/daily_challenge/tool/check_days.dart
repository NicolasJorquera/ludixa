// Genera el reto de muchos días seguidos y falla si alguno no sale.
//
// Uso (desde packages/daily_challenge):
//   dart run tool/check_days.dart --from 2026-11-02 --days 730
//
// La sopa no tiene banco de respaldo: un día sin grilla sería un día sin
// reto. Lo corre la CI (dos años por PR, diez por noche).
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:daily_challenge/daily_challenge.dart';
import 'package:puzzle_core/puzzle_core.dart';

void main(List<String> args) {
  String? arg(String name) {
    final i = args.indexOf(name);
    return i >= 0 ? args[i + 1] : null;
  }

  final from = LocalDay.parse(arg('--from') ?? '2026-11-02');
  final days = int.parse(arg('--days') ?? '730');
  final micros = <int>[];
  final problems = <String>[];
  for (var i = 0; i < days; i++) {
    final day = from.addDays(i);
    final watch = Stopwatch()..start();
    try {
      DailyChallenge.sudoku(day, today: day);
      DailyChallenge.minesweeper(day, today: day);
      for (final code in const ['es', 'en']) {
        DailyChallenge.wordSearch(day, code, today: day);
      }
      micros.add(watch.elapsedMicroseconds);
    } on Object catch (e) {
      problems.add('$day: $e');
    }
  }
  micros.sort();
  String ms(double p) => micros.isEmpty ? '-' : (micros[((micros.length - 1) * p).round()] / 1000).toStringAsFixed(1);
  print('### Reto diario · $days días desde $from\n');
  print('| Días | p50 ms | p95 ms | máx ms | sin reto |');
  print('|---:|---:|---:|---:|---:|');
  print('| $days | ${ms(.5)} | ${ms(.95)} | ${ms(1)} | ${problems.length} |');
  for (final p in problems.take(10)) {
    stderr.writeln('SIN RETO $p');
  }
  exitCode = problems.isEmpty ? 0 : 1;
}
