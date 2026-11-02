// Genera lib/l10n/app_en_XA.arb a partir de app_en.arb.
//
// La pseudolocalización acentúa las letras y alarga cada texto cerca de un 40%
// para detectar cortes y textos fijos sin traducir. Solo se usa en desarrollo.
// Ejecutar desde apps/ludixa:  dart run tool/pseudo_l10n.dart
//
// Limitación: el texto dentro de llaves (variables y formas plurales ICU) se
// copia sin cambios.
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

const _accents = {
  'a': 'á', 'b': 'ƀ', 'c': 'ç', 'd': 'ð', 'e': 'é', 'f': 'ƒ', 'g': 'ĝ', 'h': 'ĥ', 'i': 'î', 'j': 'ĵ', //
  'k': 'ķ', 'l': 'ļ', 'm': 'ɱ', 'n': 'ñ', 'o': 'ö', 'p': 'þ', 'q': 'ǫ', 'r': 'ŕ', 's': 'š', 't': 'ţ',
  'u': 'û', 'v': 'ṽ', 'w': 'ŵ', 'x': 'ẋ', 'y': 'ý', 'z': 'ž', 'A': 'Å', 'B': 'Ɓ', 'C': 'Ç', 'D': 'Ð',
  'E': 'É', 'F': 'Ƒ', 'G': 'Ĝ', 'H': 'Ĥ', 'I': 'Î', 'J': 'Ĵ', 'K': 'Ķ', 'L': 'Ļ', 'M': 'Ṁ', 'N': 'Ñ',
  'O': 'Ö', 'P': 'Þ', 'Q': 'Ǫ', 'R': 'Ŕ', 'S': 'Š', 'T': 'Ţ', 'U': 'Û', 'V': 'Ṽ', 'W': 'Ŵ', 'X': 'Ẋ',
  'Y': 'Ý', 'Z': 'Ž',
};

String pseudo(String text) {
  final out = StringBuffer('[');
  var depth = 0;
  var letters = 0;
  for (final ch in text.split('')) {
    if (ch == '{') depth++;
    if (depth == 0) {
      final mapped = _accents[ch];
      if (mapped != null) letters++;
      out.write(mapped ?? ch);
    } else {
      out.write(ch);
    }
    if (ch == '}') depth--;
  }
  out.write(' ${'·' * (letters * 0.4).ceil()}]');
  return out.toString();
}

void main() {
  final source = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, Object?>;
  final result = <String, Object?>{'@@locale': 'en_XA'};
  for (final entry in source.entries) {
    if (entry.key.startsWith('@')) continue;
    result[entry.key] = pseudo(entry.value! as String);
  }
  File('lib/l10n/app_en_XA.arb').writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(result)}\n');
  print('lib/l10n/app_en_XA.arb: ${result.length - 1} textos');
}
