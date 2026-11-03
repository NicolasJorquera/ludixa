// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'words_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class WordsLocalizationsEn extends WordsLocalizations {
  WordsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get gameName => 'Word search';

  @override
  String get levelEasy => 'Easy';

  @override
  String get levelMedium => 'Medium';

  @override
  String get levelHard => 'Hard';

  @override
  String get levelExpert => 'Expert';

  @override
  String get levelEasyDescription => '8×8 · 6 words · right and down';

  @override
  String get levelMediumDescription => '10×10 · 9 words · diagonals too';

  @override
  String get levelHardDescription => '12×12 · 12 words · all 8 directions';

  @override
  String get levelExpertDescription => '14×14 · 15 words · with decoys';

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
  String wordsCount(int found, int total) {
    return '$found of $total';
  }

  @override
  String wordsCountLabel(int found, int total) {
    return '$found of $total words found';
  }

  @override
  String get wordsShow => 'Show words';

  @override
  String get wordsHide => 'Hide words';

  @override
  String wordFound(String word) {
    return '$word, found';
  }

  @override
  String wordPending(String word) {
    return '$word, to find';
  }

  @override
  String announceFound(String word) {
    return 'You found $word';
  }

  @override
  String get announceAll => 'You found all the words!';

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
  String hintAnnounce(int row, int column) {
    return 'A word starts in row $row, column $column';
  }

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Fit to width';

  @override
  String get tapModeStart => 'Tap the first letter';

  @override
  String get tapModeEnd => 'Now tap the last letter';

  @override
  String boardLabel(int size) {
    return 'Word search, $size by $size';
  }

  @override
  String cellLabel(int row, int column, String letter, String state) {
    return 'Row $row, column $column, $letter$state';
  }

  @override
  String get cellInWord => ', in a found word';

  @override
  String get cellSelected => ', selected';

  @override
  String get cellHint => ', start of a word (hint)';

  @override
  String get tutorialSkip => 'Skip tutorial';

  @override
  String tutorialStep(int step) {
    return 'Step $step of 3';
  }

  @override
  String get tutorialRuleDrag => 'Drag your finger over the letters of a word.';

  @override
  String get tutorialTaskDrag => 'Find SUN, left to right.';

  @override
  String get tutorialRuleDirections => 'Words run straight: diagonally or backwards too.';

  @override
  String get tutorialTaskDirections => 'Find SEA: it runs diagonally.';

  @override
  String get tutorialRuleList => 'The list shows what is left. Found words are crossed out.';

  @override
  String get tutorialTaskList => 'Find the word still missing from the list.';

  @override
  String get tutorialWrong => 'That is not the word. Try again: no harm done.';

  @override
  String get tutorialRight => 'Well done!';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialStart => 'Start playing';

  @override
  String get tutorialBoardLabel => '6 by 6 practice puzzle';

  @override
  String get settingsSelection => 'How to select words';

  @override
  String get settingsSelectionDrag => 'Drag';

  @override
  String get settingsSelectionTap => 'Tap start and end';

  @override
  String get settingsSelectionHelp => 'With TalkBack, tap start and end is always used.';

  @override
  String get settingsLanguage => 'Words language';

  @override
  String get settingsLanguageApp => 'Same as the app';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsTutorial => 'How to play';
}
