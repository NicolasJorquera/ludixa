/// Tema de la Sopa de letras: un identificador estable (forma parte de la
/// semilla del reto diario y del guardado), un nombre visible y sus palabras
/// con la ortografía que se muestra en la lista.
final class WordTheme {
  const WordTheme(this.id, this.name, this.words);

  final String id;
  final String name;
  final List<String> words;
}
