import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

/// Goldens de regresión del generador.
///
/// Si esta prueba falla, cambió la secuencia que produce una semilla, y con
/// ello cambiarían los retos diarios ya publicados. No se actualizan estos
/// valores sin subir la versión de los generadores afectados.
void main() {
  const goldens = <(int, int), String>{
    (0, 0): '550c0437ee640447',
    (42, 54): '9e6a073d222235a8',
    (2026, 11): '4a349a573aad400f',
    (-1, 7): 'b5ac9aceb4cf54b5',
    (123456789, 987654321): '24e421269b5ef501',
  };

  for (final entry in goldens.entries) {
    final (state, sequence) = entry.key;
    test('las primeras 1.000 salidas de ($state, $sequence) no cambian', () {
      final rng = Pcg32(state, sequence);
      final outputs = List<int>.generate(1000, (_) => rng.nextUint32());
      final digest = BigInt.from(fnv1a64(outputs.join(','))).toUnsigned(64).toRadixString(16);
      expect(digest, entry.value);
    });
  }
}
