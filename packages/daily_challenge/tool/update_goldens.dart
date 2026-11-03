// Reescribe test/goldens/daily.json con el reto de 30 fechas seguidas.
//
// Uso (desde packages/daily_challenge): dart run tool/update_goldens.dart
//
// Solo se corre a propósito, al subir la versión de un juego en
// DailyChallenge: si los goldens cambian sin subir versión, los retos de
// fechas pasadas cambiarían para los jugadores.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:daily_challenge/daily_challenge.dart';

import '../test/golden_days.dart';

void main() {
  final snapshots = [for (final day in goldenDays) dailySnapshot(day)];
  File('test/goldens/daily.json').writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(snapshots)}\n');
  print('${snapshots.length} días escritos en test/goldens/daily.json');
}
