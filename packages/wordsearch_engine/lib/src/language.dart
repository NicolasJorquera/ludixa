/// Reglas de un idioma para la Sopa de letras: qué letras usa la grilla,
/// cómo se normalizan las palabras y con qué frecuencia rellenar.
final class WordLanguage {
  const WordLanguage._({required this.code, required this.letterWeights, required this.foldings});

  /// Español: mayúsculas sin tildes ni diéresis, conservando la Ñ, como es
  /// convención en las sopas de letras en español.
  static const spanish = WordLanguage._(
    code: 'es',
    foldings: {'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U', 'Ü': 'U'},
    // Frecuencia aproximada de letras en textos en español (por mil).
    letterWeights: {
      'E': 137, 'A': 125, 'O': 87, 'S': 80, 'R': 69, 'N': 67, 'I': 63, 'D': 59, 'L': 50, 'C': 47, //
      'T': 46, 'U': 39, 'M': 32, 'P': 25, 'B': 14, 'G': 10, 'V': 9, 'Y': 9, 'Q': 9, 'H': 7,
      'F': 7, 'Z': 5, 'J': 4, 'Ñ': 3, 'X': 2, 'K': 1, 'W': 1,
    },
  );

  /// Inglés: mayúsculas A–Z; las letras acentuadas de préstamos se simplifican.
  static const english = WordLanguage._(
    code: 'en',
    foldings: {
      'Á': 'A',
      'À': 'A',
      'Â': 'A',
      'Ä': 'A',
      'É': 'E',
      'È': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Í': 'I',
      'Ï': 'I',
      'Ó': 'O',
      'Ô': 'O',
      'Ö': 'O',
      'Ú': 'U',
      'Ü': 'U',
      'Ç': 'C',
      'Ñ': 'N',
    },
    // Frecuencia aproximada de letras en textos en inglés (por mil).
    letterWeights: {
      'E': 127, 'T': 91, 'A': 82, 'O': 75, 'I': 70, 'N': 67, 'S': 63, 'H': 61, 'R': 60, 'D': 43, //
      'L': 40, 'C': 28, 'U': 28, 'M': 24, 'W': 24, 'F': 22, 'G': 20, 'Y': 20, 'P': 19, 'B': 15,
      'V': 10, 'K': 8, 'J': 2, 'X': 2, 'Q': 1, 'Z': 1,
    },
  );

  static const all = [spanish, english];

  static WordLanguage byCode(String code) =>
      all.firstWhere((l) => l.code == code, orElse: () => throw ArgumentError('Idioma no soportado: $code'));

  final String code;

  /// Letras del alfabeto de la grilla con su peso para el relleno.
  final Map<String, int> letterWeights;

  /// Letras que se simplifican al normalizar.
  final Map<String, String> foldings;

  Set<String> get alphabet => letterWeights.keys.toSet();

  /// Forma de la palabra en la grilla: mayúsculas, sin tildes y solo con
  /// letras del alfabeto. Null si la palabra no sirve (espacios, guiones,
  /// cifras o letras ajenas al idioma).
  String? normalize(String word) {
    final buffer = StringBuffer();
    for (final rune in word.trim().toUpperCase().runes) {
      final ch = String.fromCharCode(rune);
      final folded = foldings[ch] ?? ch;
      if (!letterWeights.containsKey(folded)) return null;
      buffer.write(folded);
    }
    final result = buffer.toString();
    return result.isEmpty ? null : result;
  }

  /// Letras de una palabra normalizada (la Ñ cuenta como una sola).
  static List<String> lettersOf(String normalized) => [for (final r in normalized.runes) String.fromCharCode(r)];
}
