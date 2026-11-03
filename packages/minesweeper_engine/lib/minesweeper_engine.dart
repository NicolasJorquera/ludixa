/// Motor de Buscaminas de Ludixa: tableros resolubles sin adivinar.
///
/// Dart puro: no depende de Flutter.
library;

export 'src/game/hint.dart';
export 'src/game/minesweeper_game.dart';
export 'src/generator.dart';
export 'src/layout.dart';
export 'src/solver/exact_solver.dart';
export 'src/solver/rule_solver.dart';
export 'src/solver/solve_state.dart' show CellStatus, SolveState, UnsoundDeduction;
