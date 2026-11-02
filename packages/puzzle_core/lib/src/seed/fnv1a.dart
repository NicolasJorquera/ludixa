import 'dart:convert';

// 0xcbf29ce484222325 expresado como entero con signo de 64 bits.
const int _fnvOffsetBasis = -3750763034362895579;
const int _fnvPrime = 0x100000001b3;

/// Hash FNV-1a de 64 bits sobre los bytes UTF-8 de [input].
///
/// Es estable entre ejecuciones y plataformas nativas, a diferencia de
/// `String.hashCode`. El resultado es un `int` con signo que representa los
/// 64 bits del hash.
int fnv1a64(String input) {
  var hash = _fnvOffsetBasis;
  for (final byte in utf8.encode(input)) {
    hash ^= byte;
    hash *= _fnvPrime;
  }
  return hash;
}
