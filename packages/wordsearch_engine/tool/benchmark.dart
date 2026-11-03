// Benchmark del generador de Sopa de letras por nivel e idioma.
//
// Uso (desde packages/wordsearch_engine):
//   dart compile exe tool/benchmark.dart -o build/bench && build/bench --count 1000
//
// Recorre todos los temas del banco de cada idioma, con su lista bloqueada.
// ignore_for_file: avoid_print
import 'package:puzzle_core/puzzle_core.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

void main(List<String> args) {
  var count = 500;
  final countIndex = args.indexOf('--count');
  if (countIndex >= 0) count = int.parse(args[countIndex + 1]);
  const generator = WordSearchGenerator();

  for (final language in WordLanguage.all) {
    final themes = WordBanks.themes(language.code);
    for (final difficulty in WordSearchDifficulty.values) {
      final micros = <int>[];
      var failures = 0;
      for (var i = 0; i < count; i++) {
        final random = PuzzleSeed.fromKey('bench|${language.code}|${difficulty.name}|$i').createRandom();
        final watch = Stopwatch()..start();
        try {
          generator.generate(
            themeWords: themes[i % themes.length].words,
            blocklist: WordBanks.blocklist(language.code),
            language: language,
            difficulty: difficulty,
            random: random,
          );
          micros.add(watch.elapsedMicroseconds);
        } on WordSearchGenerationFailed {
          failures++;
        }
      }
      micros.sort();
      String ms(int us) => (us / 1000).toStringAsFixed(1);
      int pct(double p) => micros[((micros.length - 1) * p).round()];
      print(
        '${language.code} ${difficulty.name.padRight(6)}  p50 ${ms(pct(.5))} ms  p95 ${ms(pct(.95))} ms  '
        'máx ${ms(micros.last)} ms  fallos $failures/$count',
      );
    }
  }
}
