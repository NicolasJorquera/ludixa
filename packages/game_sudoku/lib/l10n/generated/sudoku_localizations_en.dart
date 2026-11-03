// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'sudoku_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SudokuLocalizationsEn extends SudokuLocalizations {
  SudokuLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get gameName => 'Sudoku';

  @override
  String get levelEasy => 'Easy';

  @override
  String get levelMedium => 'Medium';

  @override
  String get levelHard => 'Hard';

  @override
  String get levelExpert => 'Expert';

  @override
  String get levelEasyDescription => '3–6 min · last possible number';

  @override
  String get levelMediumDescription => '6–12 min · box-line intersections';

  @override
  String get levelHardDescription => '12–20 min · pairs and triples';

  @override
  String get levelExpertDescription => '20–40 min · X-Wing and other chains';

  @override
  String topBarProgress(String level, int percent) {
    return '$level · $percent%';
  }

  @override
  String get back => 'Back';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get pausedBoard => 'Board hidden while paused';

  @override
  String elapsed(String time) {
    return 'Time $time';
  }

  @override
  String get undo => 'Undo';

  @override
  String get erase => 'Erase';

  @override
  String get notes => 'Notes';

  @override
  String notesState(String on) {
    String _temp0 = intl.Intl.selectLogic(on, {'true': 'on', 'other': 'off'});
    return '$_temp0';
  }

  @override
  String get hint => 'Hint';

  @override
  String hintsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count free left',
      one: '1 free left',
      zero: 'no free hints',
    );
    return '$_temp0';
  }

  @override
  String get noMoreHints => 'No more hints for this puzzle';

  @override
  String keyRemaining(int digit, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: '$remaining left',
      one: '1 left',
      zero: 'complete',
    );
    return '$digit, $_temp0';
  }

  @override
  String get boardLabel => 'Sudoku board, 9 by 9';

  @override
  String cellLabel(int row, int column, String content) {
    return 'Row $row, column $column, $content';
  }

  @override
  String get cellEmpty => 'empty';

  @override
  String cellGiven(int digit) {
    return '$digit, given';
  }

  @override
  String cellNotes(String digits) {
    return 'notes $digits';
  }

  @override
  String get cellConflict => 'in conflict';

  @override
  String get cellSelected => 'selected';

  @override
  String get solved => 'Solved!';

  @override
  String get preparing => 'Preparing the puzzle';
}
