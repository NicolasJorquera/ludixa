// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mines_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class MinesLocalizationsEn extends MinesLocalizations {
  MinesLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get gameName => 'Minesweeper';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelExpert => 'Expert';

  @override
  String get levelDaily => 'Small intermediate';

  @override
  String get levelBeginnerDescription => '9×9 · 10 mines · fits without zoom';

  @override
  String get levelIntermediateDescription => '16×16 · 40 mines · optional zoom';

  @override
  String get levelExpertDescription => '16×30 · 99 mines · with zoom';

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
  String minesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count mines left', one: '1 mine left');
    return '$_temp0';
  }

  @override
  String get modeReveal => 'Reveal';

  @override
  String get modeFlag => 'Flag';

  @override
  String get undo => 'Undo';

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
  String get noMoreHints => 'No more hints for this board';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Fit to width';

  @override
  String get tapToStart => 'Tap any cell to start';

  @override
  String get startHere => 'Start here: the marked cell opens an area';

  @override
  String get generating => 'Preparing the board';

  @override
  String longPressTip(String action) {
    return 'Press and hold a cell to $action';
  }

  @override
  String get longPressTipFlag => 'place a flag';

  @override
  String get longPressTipReveal => 'reveal it';

  @override
  String boardLabel(int columns, int rows) {
    return 'Minesweeper board, $columns by $rows';
  }

  @override
  String cellLabel(int row, int column, String content) {
    return 'Row $row, column $column, $content';
  }

  @override
  String get cellHidden => 'closed';

  @override
  String get cellFlagged => 'flagged';

  @override
  String get cellEmpty => 'empty';

  @override
  String cellNumber(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neighboring mines',
      one: '1 neighboring mine',
    );
    return '$_temp0';
  }

  @override
  String get cellMine => 'mine';

  @override
  String get cellFatal => 'the mine that ended the game';

  @override
  String get cellWrongFlag => 'wrong flag';

  @override
  String get cellStart => 'suggested start';

  @override
  String get cellHint => 'marked by the hint';

  @override
  String get altActionFlag => 'Place or remove flag';

  @override
  String get altActionReveal => 'Reveal';

  @override
  String get won => 'Cleared!';

  @override
  String get lostTitle => 'A mine went off this time';

  @override
  String lostWhere(int row, int column) {
    return 'The mine was in row $row, column $column.';
  }

  @override
  String get retryBoard => 'Retry this board';

  @override
  String get newBoard => 'New board';

  @override
  String get rescue => 'Undo the last tap with a video';

  @override
  String get rescueRule => 'Once per game. The video is optional.';

  @override
  String get rescueUnavailable => 'No videos available right now.';

  @override
  String get showBoard => 'Show the board';

  @override
  String get showOptions => 'Show options';

  @override
  String get hintTitle => 'Hint';

  @override
  String get hintSafe => 'The marked cell is safe.';

  @override
  String get hintMine => 'The marked cell is a mine.';

  @override
  String get hintWrongFlag => 'This flag has no mine under it.';

  @override
  String hintReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'numberSatisfied': 'This number already has all its mines marked: its other neighbors are safe.',
      'numberNeedsAll': 'This number needs as many mines as it has closed neighbors: they are all mines.',
      'twoNumbers': 'Comparing these two neighboring numbers gives the cell.',
      'mineCount': 'From the count of mines left.',
      'wrongFlag': 'Remove it: the cell is safe.',
      'other': 'There is no simple deduction from here: we show you a safe cell.',
    });
    return '$_temp0';
  }

  @override
  String get hintTryMyself => 'I will try';

  @override
  String get hintApplyReveal => 'Reveal it';

  @override
  String get hintApplyFlag => 'Flag it';

  @override
  String get hintApplyUnflag => 'Remove the flag';

  @override
  String get tutorialSkip => 'Skip tutorial';

  @override
  String tutorialStep(int step) {
    return 'Step $step of 3';
  }

  @override
  String get tutorialRuleNumber => 'A number tells how many mines are among its 8 neighbors.';

  @override
  String get tutorialTaskNumber => 'This 1 already has its mine marked. Tap another neighbor: it is safe.';

  @override
  String get tutorialRuleFlag => 'If a number has as many closed neighbors as mines, they are all mines.';

  @override
  String get tutorialTaskFlag => 'Flag the mine: press and hold the cell or use Flag mode.';

  @override
  String get tutorialRuleChord => 'If a number already has all its flags, tapping it opens its other neighbors.';

  @override
  String get tutorialTaskChord => 'Tap the 1 to open all its neighbors at once.';

  @override
  String get tutorialWrongFlagged => 'That cell has the 1’s flag: its mine is there.';

  @override
  String get tutorialWrongMine => 'Careful: the mine is there. Mark it with a flag.';

  @override
  String get tutorialWrongChord => 'That works too, but tapping the 1 opens them all at once.';

  @override
  String get tutorialRight => 'Well done!';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialStart => 'Start playing';

  @override
  String get tutorialBoardLabel => '5 by 5 practice board';

  @override
  String get settingsTapMode => 'When you tap a cell';

  @override
  String get settingsTapModeHelp => 'Press and hold does the opposite.';

  @override
  String get settingsLongPress => 'Press and hold duration';

  @override
  String get settingsLongPressShort => 'Short';

  @override
  String get settingsLongPressNormal => 'Normal';

  @override
  String get settingsLongPressLong => 'Long';

  @override
  String get settingsChord => 'Open neighbors by tapping a number';

  @override
  String get settingsChordHelp => 'Only when the number already has all its flags.';

  @override
  String get settingsTutorial => 'How to play';
}
