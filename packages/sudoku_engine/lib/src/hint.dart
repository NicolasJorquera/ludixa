import 'human/candidate_grid.dart';
import 'human/human_solver.dart';
import 'human/techniques.dart';

/// Pista para el jugador.
///
/// Si hay un número equivocado, la pista lo señala ([errorCell]). Si no,
/// indica la próxima celda que se puede deducir ([cell] y [digit]) con la
/// técnica que la hace posible, el patrón y las unidades a resaltar.
final class SudokuHint {
  const SudokuHint.error(int this.errorCell)
    : cell = null,
      digit = null,
      technique = null,
      pattern = const [],
      units = const [];

  const SudokuHint.deduction({
    required int this.cell,
    required int this.digit,
    required SudokuTechnique this.technique,
    required this.pattern,
    required this.units,
  }) : errorCell = null;

  /// Respaldo cuando las técnicas no alcanzan desde el estado del jugador.
  const SudokuHint.reveal({required int this.cell, required int this.digit})
    : errorCell = null,
      technique = null,
      pattern = const [],
      units = const [];

  final int? errorCell;
  final int? cell;
  final int? digit;

  /// Técnica decisiva (la más difícil usada hasta llegar a la celda).
  final SudokuTechnique? technique;
  final List<int> pattern;
  final List<int> units;

  bool get isError => errorCell != null;
}

abstract final class SudokuHinter {
  /// Pista para el estado [values] (pistas iniciales más lo que colocó el
  /// jugador), sabiendo la [solution].
  static SudokuHint? hint(List<int> values, List<int> solution) {
    for (var i = 0; i < values.length; i++) {
      if (values[i] != 0 && values[i] != solution[i]) return SudokuHint.error(i);
    }
    if (!values.contains(0)) return null;

    // Razona desde lo colocado hasta la primera celda que se puede llenar.
    final grid = CandidateGrid.fromValues(values);
    SudokuStep? decisive;
    while (true) {
      final step = HumanSolver.nextStep(grid);
      if (step == null) break;
      if (decisive == null || step.technique.index >= decisive.technique.index) decisive = step;
      if (step.isPlacement) {
        return SudokuHint.deduction(
          cell: step.cell!,
          digit: step.digit!,
          technique: decisive.technique,
          pattern: decisive.pattern,
          units: decisive.units,
        );
      }
      step.applyTo(grid);
    }
    final empty = values.indexOf(0);
    return SudokuHint.reveal(cell: empty, digit: solution[empty]);
  }
}
