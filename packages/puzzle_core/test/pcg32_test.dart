import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

void main() {
  group('Pcg32', () {
    test('reproduce el vector de referencia de pcg32-demo (seed 42, seq 54)', () {
      final rng = Pcg32(42, 54);
      final outputs = List<int>.generate(6, (_) => rng.nextUint32());
      expect(outputs, [0xa15c02b7, 0x7b47f409, 0xba1d3330, 0x83d2f293, 0xbfa4784b, 0xcbed606e]);
    });

    test('la misma semilla produce la misma secuencia', () {
      final a = Pcg32(123456789, 987654321);
      final b = Pcg32(123456789, 987654321);
      for (var i = 0; i < 10000; i++) {
        expect(a.nextUint32(), b.nextUint32());
      }
    });

    test('secuencias distintas divergen', () {
      final a = Pcg32(1, 1);
      final b = Pcg32(1, 2);
      final sa = List<int>.generate(8, (_) => a.nextUint32());
      final sb = List<int>.generate(8, (_) => b.nextUint32());
      expect(sa, isNot(equals(sb)));
    });

    test('nextUint32 siempre está en [0, 2^32)', () {
      final rng = Pcg32(7, 11);
      for (var i = 0; i < 100000; i++) {
        final v = rng.nextUint32();
        expect(v >= 0 && v < 0x100000000, isTrue, reason: 'valor $v');
      }
    });

    test('nextInt respeta el límite y es aproximadamente uniforme', () {
      final rng = Pcg32(2026, 11);
      const bound = 9;
      const samples = 90000;
      final counts = List<int>.filled(bound, 0);
      for (var i = 0; i < samples; i++) {
        final v = rng.nextInt(bound);
        expect(v, inInclusiveRange(0, bound - 1));
        counts[v]++;
      }
      for (final c in counts) {
        // Esperado 10.000 por valor; ±5% es más de 10 desviaciones típicas.
        expect(c, inInclusiveRange(9500, 10500));
      }
    });

    test('nextInt rechaza límites fuera de rango', () {
      final rng = Pcg32(1, 1);
      expect(() => rng.nextInt(0), throwsRangeError);
      expect(() => rng.nextInt(0x100000001), throwsRangeError);
      expect(rng.nextInt(1), 0);
    });

    test('nextIntInRange incluye ambos extremos', () {
      final rng = Pcg32(5, 5);
      final seen = <int>{};
      for (var i = 0; i < 1000; i++) {
        seen.add(rng.nextIntInRange(3, 6));
      }
      expect(seen, {3, 4, 5, 6});
      expect(() => rng.nextIntInRange(2, 1), throwsArgumentError);
    });

    test('nextDouble está en [0, 1)', () {
      final rng = Pcg32(9, 9);
      for (var i = 0; i < 10000; i++) {
        final d = rng.nextDouble();
        expect(d >= 0 && d < 1, isTrue);
      }
    });

    test('shuffle es determinista y conserva los elementos', () {
      final a = List<int>.generate(81, (i) => i);
      final b = List<int>.generate(81, (i) => i);
      Pcg32(31, 7).shuffle(a);
      Pcg32(31, 7).shuffle(b);
      expect(a, b);
      expect(a.toSet(), Set<int>.from(List<int>.generate(81, (i) => i)));
      expect(a, isNot(equals(List<int>.generate(81, (i) => i))));
    });

    test('pick falla con una lista vacía', () {
      expect(() => Pcg32(1, 1).pick(<int>[]), throwsArgumentError);
    });
  });
}
