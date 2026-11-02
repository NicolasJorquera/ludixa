import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

int _hex64(String hex) => BigInt.parse(hex, radix: 16).toSigned(64).toInt();

void main() {
  group('fnv1a64', () {
    test('coincide con los vectores de referencia de FNV-1a de 64 bits', () {
      expect(fnv1a64(''), _hex64('cbf29ce484222325'));
      expect(fnv1a64('a'), _hex64('af63dc4c8601ec8c'));
      expect(fnv1a64('foobar'), _hex64('85944171f73967e8'));
    });

    test('usa los bytes UTF-8 (ñ y tildes)', () {
      expect(fnv1a64('ñ'), isNot(fnv1a64('n')));
      expect(fnv1a64('LIMÓN'), fnv1a64('LIMÓN'));
    });
  });
}
