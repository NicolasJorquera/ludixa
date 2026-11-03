import 'dart:convert';
import 'dart:io';

import 'package:daily_challenge/daily_challenge.dart';
import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';
import 'package:test/test.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

import 'golden_days.dart';

void main() {
  final monday = LocalDay(2026, 11, 2);

  group('calendario', () {
    test('la dificultad sube de lunes a domingo según el PRD', () {
      final week = [for (var i = 0; i < 7; i++) DailyLineup.of(monday.addDays(i))];
      expect(
        [for (final l in week) l.sudoku],
        [
          for (final d in ['easy', 'easy', 'medium', 'medium', 'medium', 'medium', 'hard'])
            SudokuDifficulty.values.byName(d),
        ],
      );
      expect([for (final l in week) l.sudokuUpperMedium], [false, false, false, false, true, true, false]);
      expect(
        [for (final l in week) l.minesweeper.toString()],
        ['9x9/10', '9x9/10', '12x12/22', '12x12/22', '16x16/40', '16x16/40', '16x16/40'],
      );
      expect([for (final l in week) l.wordSearch.name], ['easy', 'easy', 'medium', 'medium', 'hard', 'hard', 'hard']);
      expect([for (final l in week) l.specialTheme], [false, false, false, false, false, false, true]);
    });
  });

  group('disponibilidad', () {
    test('el reto de un día futuro no se puede generar', () {
      final tomorrow = monday.addDays(1);
      expect(() => DailyChallenge.sudoku(tomorrow, today: monday), throwsA(isA<DailyNotAvailable>()));
      expect(() => DailyChallenge.minesweeper(tomorrow, today: monday), throwsA(isA<DailyNotAvailable>()));
      expect(() => DailyChallenge.wordSearch(tomorrow, 'es', today: monday), throwsA(isA<DailyNotAvailable>()));
    });

    test('hoy y los días pasados sí', () {
      expect(DailyChallenge.sudoku(monday, today: monday).difficulty, SudokuDifficulty.easy);
      expect(DailyChallenge.sudoku(monday.addDays(-3), today: monday), isNotNull);
    });
  });

  group('semillas', () {
    test('incluyen fecha, juego, versión e idioma de las palabras', () {
      expect(DailyChallenge.seed(GameId.sudoku, monday).key, 'daily|2026-11-02|sudoku|v1');
      expect(
        DailyChallenge.seed(GameId.wordSearch, monday, wordsLanguage: 'en').key,
        'daily|2026-11-02|wordsearch|v1|en',
      );
    });

    test('las versiones del reto se revisan cuando cambia un motor', () {
      // Si falla, cambió un motor o el banco: sube la versión del juego en
      // DailyChallenge, regenera los goldens y actualiza este valor.
      expect(
        (SudokuBank.version, SudokuGenerator.version, NoGuessGenerator.version, WordSearchGenerator.version),
        (1, 1, 1, 1),
      );
    });
  });

  group('Sudoku', () {
    test('viernes y sábado son Medios altos; miércoles y jueves, Medios cualquiera', () {
      for (final day in goldenDays) {
        final lineup = DailyLineup.of(day);
        final puzzle = DailyChallenge.sudoku(day, today: day);
        expect(HumanSolver.grade(puzzle.givens), lineup.sudoku, reason: '$day');
        if (lineup.sudokuUpperMedium) {
          expect(DailyChallenge.mediumSteps(puzzle.givens), greaterThanOrEqualTo(2), reason: '$day');
        }
      }
    });

    test('el umbral de Medio alto deja en el banco más de un tercio y menos de dos tercios', () {
      final size = SudokuBank.sizeOf(SudokuDifficulty.medium);
      final upper = [
        for (var i = 0; i < size; i++) SudokuBank.at(SudokuDifficulty.medium, i),
      ].where((p) => DailyChallenge.mediumSteps(p.givens) >= DailyChallenge.upperMediumMinSteps).length;
      expect(upper / size, inInclusiveRange(1 / 3, 2 / 3));
    });
  });

  group('Sopa de letras', () {
    test('ningún tema se repite en 14 días seguidos y el domingo mezcla tres', () {
      for (var start = -30; start < 30; start++) {
        final themes = [for (var i = 0; i < 14; i++) ...DailyChallenge.themesFor(monday.addDays(start + i))];
        expect(themes, hasLength(18));
        expect(themes.toSet(), hasLength(18), reason: 'desde ${monday.addDays(start)}');
      }
      final sunday = monday.addDays(6);
      final ws = DailyChallenge.wordSearch(sunday, 'es', today: sunday);
      expect(ws.special, isTrue);
      expect(ws.themeIds.toSet(), hasLength(3));
    });

    test('los dos idiomas comparten tema pero no grilla', () {
      final es = DailyChallenge.wordSearch(monday, 'es', today: monday);
      final en = DailyChallenge.wordSearch(monday, 'en', today: monday);
      expect(es.themeIds, en.themeIds);
      expect(es.puzzle.language, 'es');
      expect(en.puzzle.language, 'en');
      expect(es.puzzle.letters, isNot(en.puzzle.letters));
    });

    test('los bancos de ambos idiomas tienen los mismos temas', () {
      expect({for (final t in WordBanks.themes('en')) t.id}, {for (final t in WordBanks.themes('es')) t.id});
    });
  });

  test('goldens: el reto de 30 fechas es idéntico al guardado', () {
    final saved = jsonDecode(File('test/goldens/daily.json').readAsStringSync()) as List<Object?>;
    expect(saved, hasLength(goldenDays.length));
    for (var i = 0; i < goldenDays.length; i++) {
      // Ida y vuelta por JSON para comparar los mismos tipos.
      expect(jsonDecode(jsonEncode(dailySnapshot(goldenDays[i]))), saved[i], reason: '${goldenDays[i]}');
    }
  });
}
