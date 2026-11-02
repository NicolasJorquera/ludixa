/// Generador PCG32 (Melissa O'Neill, https://www.pcg-random.org).
///
/// Es determinista entre dispositivos y versiones de Dart: la misma semilla
/// produce siempre la misma secuencia. Por eso los motores lo usan en lugar
/// de `dart:math` `Random`, cuya implementación podría cambiar.
///
/// Depende de la aritmética entera de 64 bits con desbordamiento de la VM y
/// de AOT. No es válido en Dart web, donde los enteros no son de 64 bits.
final class Pcg32 {
  /// Crea el generador igual que `pcg32_srandom_r(initState, initSeq)`.
  Pcg32(int initState, int initSeq) {
    _inc = (initSeq << 1) | 1;
    _state = 0;
    nextUint32();
    _state += initState;
    nextUint32();
  }

  static const int _multiplier = 6364136223846793005;
  static const int _two32 = 0x100000000;

  late int _state;
  late int _inc;

  /// Siguiente entero sin signo de 32 bits, en `[0, 2^32)`.
  int nextUint32() {
    final old = _state;
    _state = old * _multiplier + _inc;
    final xorShifted = (((old >>> 18) ^ old) >>> 27) & 0xFFFFFFFF;
    final rot = old >>> 59;
    return ((xorShifted >>> rot) | (xorShifted << ((-rot) & 31))) & 0xFFFFFFFF;
  }

  /// Entero uniforme en `[0, bound)`, sin sesgo de módulo.
  int nextInt(int bound) {
    RangeError.checkValueInInterval(bound, 1, _two32, 'bound');
    final threshold = (_two32 - bound) % bound;
    while (true) {
      final r = nextUint32();
      if (r >= threshold) return r % bound;
    }
  }

  /// Entero uniforme en `[min, max]`, ambos incluidos.
  int nextIntInRange(int min, int max) {
    if (max < min) {
      throw ArgumentError('max ($max) debe ser mayor o igual que min ($min)');
    }
    return min + nextInt(max - min + 1);
  }

  /// Valor uniforme en `[0, 1)` con 32 bits de precisión.
  double nextDouble() => nextUint32() / _two32;

  bool nextBool() => (nextUint32() >>> 31) == 1;

  /// Mezcla [list] en el lugar con Fisher-Yates.
  void shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }

  /// Elemento uniforme de [items], que no puede estar vacía.
  T pick<T>(List<T> items) {
    if (items.isEmpty) throw ArgumentError('No se puede elegir de una lista vacía');
    return items[nextInt(items.length)];
  }
}
