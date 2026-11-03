// Benchmark y propiedades del generador de Sopa de letras por nivel e idioma.
//
// Uso (desde packages/wordsearch_engine):
//   dart compile exe tool/benchmark.dart -o build/bench && build/bench --count 1000 --verify
//
// Recorre todos los temas del banco de cada idioma, con su lista bloqueada, e
// imprime una tabla Markdown con percentiles de tiempo. Con --verify
// comprueba cada grilla: letras del alfabeto, direcciones del nivel, cada
// palabra exactamente una vez y ninguna palabra bloqueada suelta. --salt
// cambia las semillas. Sale con código 1 si hay violaciones o grillas sin
// generar (la sopa no tiene banco de respaldo).
// ignore_for_file: avoid_print
import 'dart:io';

import 'package:puzzle_core/puzzle_core.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

void main(List<String> args) {
  final count = _intArg(args, '--count') ?? 1000;
  final salt = _stringArg(args, '--salt') ?? 'bench';
  final verify = args.contains('--verify');
  const generator = WordSearchGenerator();
  var broken = false;

  print('### Sopa de letras · $count grillas por nivel e idioma · semilla `$salt`${verify ? ' · verificadas' : ''}\n');
  print('| Idioma | Nivel | p50 ms | p95 ms | p99 ms | máx ms | sin generar | violaciones |');
  print('|---|---|---:|---:|---:|---:|---:|---:|');
  for (final language in WordLanguage.all) {
    final themes = WordBanks.themes(language.code);
    final blocklist = WordBanks.blocklist(language.code);
    final blocked = {for (final b in blocklist) ?language.normalize(b)};
    for (final difficulty in WordSearchDifficulty.values) {
      final micros = <int>[];
      var failures = 0;
      final violations = <String>[];
      for (var i = 0; i < count; i++) {
        final theme = themes[i % themes.length];
        final random = PuzzleSeed.fromKey('$salt|${language.code}|${difficulty.name}|$i').createRandom();
        final watch = Stopwatch()..start();
        try {
          final puzzle = generator.generate(
            themeWords: theme.words,
            blocklist: blocklist,
            language: language,
            difficulty: difficulty,
            random: random,
          );
          micros.add(watch.elapsedMicroseconds);
          if (verify) {
            final problem = _check(puzzle, language, difficulty, blocked);
            if (problem != null) violations.add('$i (${theme.id}): $problem');
          }
        } on WordSearchGenerationFailed {
          failures++;
        }
      }
      print(
        '| ${language.code} | ${difficulty.name} | ${_pct(micros, .5)} | ${_pct(micros, .95)} | ${_pct(micros, .99)} '
        '| ${_pct(micros, 1)} | $failures | ${violations.length} |',
      );
      for (final v in violations.take(10)) {
        stderr.writeln('VIOLACIÓN ${language.code} ${difficulty.name} semilla $salt índice $v');
      }
      broken |= violations.isNotEmpty || failures > 0;
    }
  }
  exitCode = broken ? 1 : 0;
}

String? _check(WordSearchPuzzle puzzle, WordLanguage language, WordSearchDifficulty difficulty, Set<String> blocked) {
  if (puzzle.letters.length != puzzle.size * puzzle.size) return 'tamaño';
  if (!puzzle.letters.every(language.alphabet.contains)) return 'letra fuera del alfabeto';
  if (puzzle.placements.length != difficulty.words) return 'cantidad de palabras';
  for (final p in puzzle.placements) {
    if (!difficulty.directions.contains(p.direction)) return '${p.word} en dirección ${p.direction.name}';
    if ([for (final c in p.cells) puzzle.letters[c]].join() != p.word) return '${p.word} no está en sus celdas';
    if (WordScanner.count(puzzle.letters, puzzle.size, p.word) != 1) return '${p.word} aparece más de una vez';
  }
  for (final b in blocked) {
    if (WordScanner.strayCount(puzzle.letters, puzzle.size, b, puzzle.placements) > 0) return 'bloqueada $b';
  }
  return null;
}

int? _intArg(List<String> args, String name) {
  final i = args.indexOf(name);
  return i >= 0 ? int.parse(args[i + 1]) : null;
}

String? _stringArg(List<String> args, String name) {
  final i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : null;
}

int _raw(List<int> values, double p) {
  if (values.isEmpty) return 0;
  final sorted = [...values]..sort();
  return sorted[((sorted.length - 1) * p).round()];
}

String _pct(List<int> micros, double p) => (_raw(micros, p) / 1000).toStringAsFixed(1);
