// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'sudoku_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SudokuLocalizationsEs extends SudokuLocalizations {
  SudokuLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get gameName => 'Sudoku';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelMedium => 'Medio';

  @override
  String get levelHard => 'Difícil';

  @override
  String get levelExpert => 'Experto';

  @override
  String get levelEasyDescription => '3–6 min · el último número posible';

  @override
  String get levelMediumDescription => '6–12 min · intersecciones caja-línea';

  @override
  String get levelHardDescription => '12–20 min · pares y tríos';

  @override
  String get levelExpertDescription => '20–40 min · X-Wing y otras cadenas';

  @override
  String topBarProgress(String level, int percent) {
    return '$level · $percent %';
  }

  @override
  String get back => 'Volver';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get pausedBoard => 'Tablero oculto en pausa';

  @override
  String elapsed(String time) {
    return 'Tiempo $time';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String get erase => 'Borrar';

  @override
  String get notes => 'Notas';

  @override
  String notesState(String on) {
    String _temp0 = intl.Intl.selectLogic(on, {'true': 'activadas', 'other': 'desactivadas'});
    return '$_temp0';
  }

  @override
  String get hint => 'Pista';

  @override
  String hintsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'quedan $count gratis',
      one: 'queda 1 gratis',
      zero: 'sin pistas gratis',
    );
    return '$_temp0';
  }

  @override
  String get noMoreHints => 'Sin más pistas en este puzzle';

  @override
  String keyRemaining(int digit, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'quedan $remaining',
      one: 'queda 1',
      zero: 'completo',
    );
    return '$digit, $_temp0';
  }

  @override
  String get boardLabel => 'Tablero de Sudoku, 9 por 9';

  @override
  String cellLabel(int row, int column, String content) {
    return 'Fila $row, columna $column, $content';
  }

  @override
  String get cellEmpty => 'vacía';

  @override
  String cellGiven(int digit) {
    return '$digit, fijo';
  }

  @override
  String cellNotes(String digits) {
    return 'notas $digits';
  }

  @override
  String get cellConflict => 'en conflicto';

  @override
  String get cellSelected => 'seleccionada';

  @override
  String get solved => '¡Resuelto!';

  @override
  String get preparing => 'Preparando el puzzle';
}
