import 'dart:math';

import '../model/identifiers.dart';
import '../random/pcg32.dart';
import '../time/local_day.dart';
import 'fnv1a.dart';

/// Semilla reproducible de un puzzle.
///
/// Se identifica por una [key] de texto que se puede guardar con la sesión.
/// De la clave se derivan el estado y la secuencia de [Pcg32], de modo que
/// la misma clave genera siempre el mismo puzzle.
final class PuzzleSeed {
  PuzzleSeed._(this.key) : _state = fnv1a64(key), _sequence = fnv1a64('$key#seq');

  /// Reconstruye una semilla a partir de una clave guardada.
  factory PuzzleSeed.fromKey(String key) {
    if (key.isEmpty) throw ArgumentError('La clave de semilla no puede estar vacía');
    return PuzzleSeed._(key);
  }

  /// Semilla del reto diario: idéntica para todos los jugadores que comparten
  /// fecha, juego, versión del generador e idioma de las palabras.
  factory PuzzleSeed.daily({
    required LocalDay day,
    required GameId game,
    required int generatorVersion,
    String? wordsLanguage,
  }) {
    final parts = <String>['daily', day.toIso8601(), game.value, 'v$generatorVersion', ?wordsLanguage];
    return PuzzleSeed._(parts.join('|'));
  }

  /// Semilla aleatoria para partidas libres.
  factory PuzzleSeed.random([Random? source]) {
    final random = source ?? Random.secure();
    final words = List<String>.generate(4, (_) => random.nextInt(0x100000000).toRadixString(16).padLeft(8, '0'));
    return PuzzleSeed._('free|${words.join()}');
  }

  final String key;
  final int _state;
  final int _sequence;

  /// Nuevo generador que arranca desde esta semilla.
  Pcg32 createRandom() => Pcg32(_state, _sequence);

  @override
  bool operator ==(Object other) => other is PuzzleSeed && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'PuzzleSeed($key)';
}
