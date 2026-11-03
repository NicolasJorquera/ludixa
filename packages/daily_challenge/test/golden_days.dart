import 'package:puzzle_core/puzzle_core.dart';

/// 30 días seguidos desde un lunes: cubren cada día de la semana cuatro veces.
final goldenDays = [for (var i = 0; i < 30; i++) LocalDay(2026, 11, 2).addDays(i)];
