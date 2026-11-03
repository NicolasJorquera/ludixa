import 'package:minesweeper_engine/minesweeper_engine.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:sudoku_engine/sudoku_engine.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

/// Dificultad de cada juego en un día. La semana sube como los crucigramas de
/// periódico: el lunes es suave y el domingo, exigente (PRD, reto diario).
///
/// | Día     | Sudoku     | Buscaminas                  | Sopa de letras            |
/// |---------|------------|-----------------------------|---------------------------|
/// | Lun–Mar | Fácil      | Principiante                | Fácil · tema del día      |
/// | Mié–Jue | Medio      | Intermedio reducido (12×12) | Medio · tema del día      |
/// | Vie–Sáb | Medio alto | Intermedio                  | Difícil · tema del día    |
/// | Dom     | Difícil    | Intermedio                  | Difícil · tema especial   |
final class DailyLineup {
  const DailyLineup({
    required this.sudoku,
    required this.sudokuUpperMedium,
    required this.minesweeper,
    required this.wordSearch,
    required this.specialTheme,
  });

  /// Intermedio reducido de mitad de semana: 12×12 con 22 minas.
  static const reducedIntermediate = BoardSpec(width: 12, height: 12, mines: 22);

  factory DailyLineup.of(LocalDay day) => switch (DateTime.utc(day.year, day.month, day.day).weekday) {
    DateTime.monday || DateTime.tuesday => const DailyLineup(
      sudoku: SudokuDifficulty.easy,
      sudokuUpperMedium: false,
      minesweeper: BoardSpec.beginner,
      wordSearch: WordSearchDifficulty.easy,
      specialTheme: false,
    ),
    DateTime.wednesday || DateTime.thursday => const DailyLineup(
      sudoku: SudokuDifficulty.medium,
      sudokuUpperMedium: false,
      minesweeper: reducedIntermediate,
      wordSearch: WordSearchDifficulty.medium,
      specialTheme: false,
    ),
    DateTime.friday || DateTime.saturday => const DailyLineup(
      sudoku: SudokuDifficulty.medium,
      sudokuUpperMedium: true,
      minesweeper: BoardSpec.intermediate,
      wordSearch: WordSearchDifficulty.hard,
      specialTheme: false,
    ),
    _ => const DailyLineup(
      sudoku: SudokuDifficulty.hard,
      sudokuUpperMedium: false,
      minesweeper: BoardSpec.intermediate,
      wordSearch: WordSearchDifficulty.hard,
      specialTheme: true,
    ),
  };

  final SudokuDifficulty sudoku;

  /// "Medio alto": un Medio que exige técnicas de nivel Medio más de una vez.
  final bool sudokuUpperMedium;
  final BoardSpec minesweeper;
  final WordSearchDifficulty wordSearch;

  /// El domingo la sopa mezcla tres temas en vez de uno.
  final bool specialTheme;
}
