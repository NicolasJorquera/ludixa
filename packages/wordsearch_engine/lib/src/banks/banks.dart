import 'en.dart';
import 'es.dart';
import 'word_theme.dart';

export 'word_theme.dart';

/// Bancos de palabras por idioma. Los dos idiomas comparten los
/// identificadores de tema, así el reto diario usa el mismo tema en ambos.
///
/// Son un borrador: requieren revisión nativa antes de publicar (P-07).
abstract final class WordBanks {
  static List<WordTheme> themes(String languageCode) => switch (languageCode) {
    'es' => spanishThemes,
    'en' => englishThemes,
    _ => throw ArgumentError('Idioma sin banco de palabras: $languageCode'),
  };

  static WordTheme theme(String languageCode, String id) => themes(
    languageCode,
  ).firstWhere((t) => t.id == id, orElse: () => throw ArgumentError('Tema desconocido: $languageCode/$id'));

  /// Palabras que la grilla nunca debe formar fuera de una palabra buscada.
  static Set<String> blocklist(String languageCode) => switch (languageCode) {
    'es' => spanishBlocklist,
    'en' => englishBlocklist,
    _ => throw ArgumentError('Idioma sin banco de palabras: $languageCode'),
  };
}
