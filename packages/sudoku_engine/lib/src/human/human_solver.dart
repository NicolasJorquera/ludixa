import 'candidate_grid.dart';
import 'techniques.dart';

/// Resultado de resolver con técnicas humanas.
final class HumanSolveReport {
  const HumanSolveReport({required this.solved, required this.steps, required this.hardest});

  /// Se completó la grilla solo con las técnicas soportadas.
  final bool solved;
  final List<SudokuStep> steps;

  /// Técnica más difícil usada (null si no hubo pasos).
  final SudokuTechnique? hardest;

  /// Dificultad del puzzle, o null si exige técnicas que no soportamos.
  SudokuDifficulty? get difficulty => solved ? (hardest?.difficulty ?? SudokuDifficulty.easy) : null;
}

/// Resuelve como una persona: en cada paso aplica la técnica más simple que
/// sirve. La dificultad es la técnica más avanzada que hizo falta.
abstract final class HumanSolver {
  /// Siguiente paso desde [grid], o null si ninguna técnica sirve.
  static SudokuStep? nextStep(CandidateGrid grid, {SudokuDifficulty limit = SudokuDifficulty.expert}) {
    for (final technique in SudokuTechnique.values) {
      if (technique.difficulty.index > limit.index) break;
      final step = findStep(technique, grid);
      if (step != null) return step;
    }
    return null;
  }

  /// Resuelve desde los valores dados. Con [limit] se detiene si hace falta
  /// una técnica de mayor dificultad (sirve para generar sin pasarse).
  static HumanSolveReport solve(List<int> values, {SudokuDifficulty limit = SudokuDifficulty.expert}) {
    final grid = CandidateGrid.fromValues(values);
    final steps = <SudokuStep>[];
    SudokuTechnique? hardest;
    while (!grid.isSolved) {
      final step = nextStep(grid, limit: limit);
      if (step == null) return HumanSolveReport(solved: false, steps: steps, hardest: hardest);
      step.applyTo(grid);
      steps.add(step);
      if (hardest == null || step.technique.index > hardest.index) hardest = step.technique;
    }
    return HumanSolveReport(solved: true, steps: steps, hardest: hardest);
  }

  /// Dificultad de un puzzle, o null si supera nuestras técnicas.
  static SudokuDifficulty? grade(List<int> givens) => solve(givens).difficulty;
}
