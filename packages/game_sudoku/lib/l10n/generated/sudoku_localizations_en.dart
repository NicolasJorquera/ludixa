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

  @override
  String hintStep(int step) {
    return 'Hint · step $step of 3';
  }

  @override
  String hintZone(String zone) {
    return 'There is a deduction in $zone.';
  }

  @override
  String get hintZoneDetail => 'Look at where each number can go in that area.';

  @override
  String hintNumber(int digit, int row, int column) {
    return 'A $digit goes in row $row, column $column.';
  }

  @override
  String get hintNumberRevealed => 'This cell needs a technique we do not explain yet.';

  @override
  String get hintErrorTitle => 'One number does not belong';

  @override
  String hintErrorDetail(int row, int column) {
    return 'Check row $row, column $column. You can fix it yourself or erase it.';
  }

  @override
  String get hintTryMyself => 'I will try';

  @override
  String get hintNextStep => 'Show the technique';

  @override
  String get hintShowNumber => 'Show the number';

  @override
  String get hintEraseError => 'Erase the number';

  @override
  String get hintDone => 'Got it';

  @override
  String zoneRow(int n) {
    return 'row $n';
  }

  @override
  String zoneColumn(int n) {
    return 'column $n';
  }

  @override
  String zoneBox(String index) {
    String _temp0 = intl.Intl.selectLogic(index, {
      '0': 'the top-left box',
      '1': 'the top-middle box',
      '2': 'the top-right box',
      '3': 'the middle-left box',
      '4': 'the center box',
      '5': 'the middle-right box',
      '6': 'the bottom-left box',
      '7': 'the bottom-middle box',
      'other': 'the bottom-right box',
    });
    return '$_temp0';
  }

  @override
  String zoneTwo(String a, String b) {
    return '$a and $b';
  }

  @override
  String zoneThree(String a, String b, String c) {
    return '$a, $b and $c';
  }

  @override
  String techniqueName(String technique) {
    String _temp0 = intl.Intl.selectLogic(technique, {
      'nakedSingle': 'Naked single',
      'hiddenSingle': 'Hidden single',
      'pointing': 'Pointing',
      'claiming': 'Claiming',
      'nakedPair': 'Naked pair',
      'hiddenPair': 'Hidden pair',
      'nakedTriple': 'Naked triple',
      'hiddenTriple': 'Hidden triple',
      'xWing': 'X-Wing',
      'xyWing': 'XY-Wing',
      'other': 'Swordfish',
    });
    return '$_temp0';
  }

  @override
  String techniqueExplanation(String technique) {
    String _temp0 = intl.Intl.selectLogic(technique, {
      'nakedSingle': 'Only one number is left for this cell: the others are already in its row, column or box.',
      'hiddenSingle': 'In this area, that number fits in only one cell.',
      'pointing':
          'Inside the box, the number can only go in one line, so it is removed from the rest of that row or column.',
      'claiming':
          'In the row or column, the number only fits inside one box, so it is removed from the rest of the box.',
      'nakedPair': 'Two cells share the same two candidates, so those numbers are removed from the rest of the area.',
      'hiddenPair': 'Two numbers fit only in the same two cells, so other candidates are removed there.',
      'nakedTriple': 'Three cells share the same three candidates, so they are removed from the rest of the area.',
      'hiddenTriple': 'Three numbers fit only in the same three cells, so other candidates are removed there.',
      'xWing':
          'A number forms a rectangle across two rows and two columns, so it is removed from the rest of those columns.',
      'xyWing': 'Three two-candidate cells form a pincer: the number shared by the ends is removed where both see it.',
      'other': 'Like the X-Wing, but with three rows and three columns.',
    });
    return '$_temp0';
  }

  @override
  String get tutorialSkip => 'Skip tutorial';

  @override
  String tutorialStep(int step) {
    return 'Step $step of 3';
  }

  @override
  String get tutorialRuleRow => 'Each row has every number, with no repeats.';

  @override
  String get tutorialRuleColumn => 'Each column too.';

  @override
  String get tutorialRuleBox => 'And each box.';

  @override
  String get tutorialAsk => 'Which number goes in the marked cell?';

  @override
  String tutorialWrongRow(int digit) {
    return '$digit is already in this row. Try another.';
  }

  @override
  String tutorialWrongColumn(int digit) {
    return '$digit is already in this column. Try another.';
  }

  @override
  String tutorialWrongBox(int digit) {
    return '$digit is already in this box. Try another.';
  }

  @override
  String tutorialRight(int digit) {
    return 'Right! $digit is the only one missing.';
  }

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialStart => 'Start playing';

  @override
  String get tutorialBoardLabel => '4 by 4 practice board';

  @override
  String get settingsInput => 'How to enter numbers';

  @override
  String get settingsInputCellFirst => 'Cell first';

  @override
  String get settingsInputNumberFirst => 'Number first';

  @override
  String get settingsErrors => 'Mistakes';

  @override
  String get settingsErrorsConflicts => 'Repeated numbers';

  @override
  String get settingsErrorsSolution => 'Against the solution';

  @override
  String get settingsErrorsNone => 'No marking';

  @override
  String get settingsErrorsHelp => 'There is no mistake limit: this only changes how they are shown.';

  @override
  String get settingsRemoveNotes => 'Clear notes when placing a number';

  @override
  String get settingsHighlightSame => 'Highlight matching numbers';

  @override
  String get settingsTutorial => 'How to play';
}
