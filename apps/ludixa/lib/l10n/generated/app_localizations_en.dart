// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Ludixa';

  @override
  String get navHome => 'Home';

  @override
  String get navDaily => 'Daily';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get navigationLabel => 'Main navigation';

  @override
  String get homeTitle => 'Home';

  @override
  String get dailyTitle => 'Today\'s challenge';

  @override
  String get progressTitle => 'Progress';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get comingSoon => 'This screen arrives in an upcoming development build.';

  @override
  String get settingsThemeSection => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get colorblindPalette => 'Colorblind palette';

  @override
  String get colorblindPaletteHint => 'Swaps reds and greens for oranges and blues';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePseudo => 'Pseudo-localization (development)';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsComponentCatalog => 'Component catalog (development)';

  @override
  String get settingsLicenses => 'Open source licenses';

  @override
  String get settingsDevGames => 'Try games (development)';

  @override
  String get pauseTitle => 'Paused';

  @override
  String get pauseBoardHidden => 'Board hidden while paused';

  @override
  String get pauseResume => 'Resume';

  @override
  String get pauseRestart => 'Restart';

  @override
  String get pauseRestartConfirm => 'You will lose your progress on this puzzle.';

  @override
  String get pauseRestartYes => 'Yes, restart';

  @override
  String get pauseCancel => 'Cancel';

  @override
  String get pauseHowToPlay => 'How to play';

  @override
  String get pauseGameSettings => 'Game settings';

  @override
  String get pauseSaveExit => 'Save and exit';

  @override
  String get pauseAutosave => 'Your game saves itself after every move.';

  @override
  String difficultyTitle(String game) {
    return '$game: choose a difficulty';
  }

  @override
  String get difficultyLast => 'The one you played last';

  @override
  String get resultSolved => 'Solved!';

  @override
  String get resultUnassisted => 'No help';

  @override
  String get resultNewRecord => 'New record';

  @override
  String get resultTime => 'Time';

  @override
  String get resultBest => 'Best';

  @override
  String get resultHints => 'Hints';

  @override
  String resultMastery(String level) {
    return 'Mastery on $level';
  }

  @override
  String masteryLevel(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'bronze': 'Bronze',
      'silver': 'Silver',
      'gold': 'Gold',
      'other': 'No medal',
    });
    return '$_temp0';
  }

  @override
  String masteryToNext(int count, String next) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more games for $next',
      one: '1 more game for $next',
    );
    return '$_temp0';
  }

  @override
  String get masteryComplete => 'Mastery complete';

  @override
  String resultDaily(int done, int before, int after) {
    return 'Challenge: $done of 3 · streak $before → $after';
  }

  @override
  String get resultAchievement => 'Achievement unlocked';

  @override
  String resultPlayAgain(String level) {
    return 'Play again on $level';
  }

  @override
  String get resultNextDaily => 'Next challenge';

  @override
  String get resultHome => 'Back to home';

  @override
  String achievementTitle(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'first_puzzle': 'First puzzle',
      'all_three_games': 'Try all three games',
      'streak_3': '3-day streak',
      'streak_7': '7-day streak',
      'streak_30': '30-day streak',
      'streak_100': '100-day streak',
      'perfect_day': 'Perfect day',
      'full_month': 'Full month',
      'ten_unassisted': '10 puzzles with no help',
      'sudoku_first_hard': 'First Hard Sudoku',
      'sudoku_first_expert': 'First Expert Sudoku',
      'sudoku_fast_medium': 'Medium Sudoku in under 6 minutes',
      'mines_first_expert': 'First Expert Minesweeper',
      'mines_five_in_a_row': '5 Minesweeper wins in a row',
      'mines_no_flags': 'Win without flags',
      'words_ten_themes': 'Explore 10 themes',
      'words_expert_no_hints': 'Expert word search with no hints',
      'other': '50 word searches done',
    });
    return '$_temp0';
  }
}

/// The translations for English (`en_XA`).
class AppLocalizationsEnXa extends AppLocalizationsEn {
  AppLocalizationsEnXa() : super('en_XA');

  @override
  String get appName => '[Ļûðîẋá ···]';

  @override
  String get navHome => '[Ĥöɱé ··]';

  @override
  String get navDaily => '[Ðáîļý ··]';

  @override
  String get navProgress => '[Þŕöĝŕéšš ····]';

  @override
  String get navSettings => '[Šéţţîñĝš ····]';

  @override
  String get navigationLabel => '[Ṁáîñ ñáṽîĝáţîöñ ······]';

  @override
  String get homeTitle => '[Ĥöɱé ··]';

  @override
  String get dailyTitle => '[Ţöðáý\'š çĥáļļéñĝé ······]';

  @override
  String get progressTitle => '[Þŕöĝŕéšš ····]';

  @override
  String get settingsTitle => '[Šéţţîñĝš ····]';

  @override
  String get comingSoon => '[Ţĥîš šçŕééñ áŕŕîṽéš îñ áñ ûþçöɱîñĝ ðéṽéļöþɱéñţ ƀûîļð. ··················]';

  @override
  String get settingsThemeSection => '[Ţĥéɱé ··]';

  @override
  String get themeSystem => '[Šýšţéɱ ðéƒáûļţ ······]';

  @override
  String get themeLight => '[Ļîĝĥţ ··]';

  @override
  String get themeDark => '[Ðáŕķ ··]';

  @override
  String get colorblindPalette => '[Çöļöŕƀļîñð þáļéţţé ·······]';

  @override
  String get colorblindPaletteHint => '[Šŵáþš ŕéðš áñð ĝŕééñš ƒöŕ öŕáñĝéš áñð ƀļûéš ···············]';

  @override
  String get settingsLanguageSection => '[Ļáñĝûáĝé ····]';

  @override
  String get languageSystem => '[Šýšţéɱ ðéƒáûļţ ······]';

  @override
  String get languageSpanish => '[Éšþáñöļ ···]';

  @override
  String get languageEnglish => '[Éñĝļîšĥ ···]';

  @override
  String get languagePseudo => '[Þšéûðö-ļöçáļîžáţîöñ (ðéṽéļöþɱéñţ) ············]';

  @override
  String get settingsAboutSection => '[Åƀöûţ ··]';

  @override
  String get settingsComponentCatalog => '[Çöɱþöñéñţ çáţáļöĝ (ðéṽéļöþɱéñţ) ···········]';

  @override
  String get settingsLicenses => '[Öþéñ šöûŕçé ļîçéñšéš ········]';

  @override
  String get settingsDevGames => '[Ţŕý ĝáɱéš (ðéṽéļöþɱéñţ) ········]';

  @override
  String get pauseTitle => '[Þáûšéð ···]';

  @override
  String get pauseBoardHidden => '[Ɓöáŕð ĥîððéñ ŵĥîļé þáûšéð ·········]';

  @override
  String get pauseResume => '[Ŕéšûɱé ···]';

  @override
  String get pauseRestart => '[Ŕéšţáŕţ ···]';

  @override
  String get pauseRestartConfirm => '[Ýöû ŵîļļ ļöšé ýöûŕ þŕöĝŕéšš öñ ţĥîš þûžžļé. ··············]';

  @override
  String get pauseRestartYes => '[Ýéš, ŕéšţáŕţ ····]';

  @override
  String get pauseCancel => '[Çáñçéļ ···]';

  @override
  String get pauseHowToPlay => '[Ĥöŵ ţö þļáý ····]';

  @override
  String get pauseGameSettings => '[Ĝáɱé šéţţîñĝš ·····]';

  @override
  String get pauseSaveExit => '[Šáṽé áñð éẋîţ ·····]';

  @override
  String get pauseAutosave => '[Ýöûŕ ĝáɱé šáṽéš îţšéļƒ áƒţéŕ éṽéŕý ɱöṽé. ··············]';

  @override
  String difficultyTitle(String game) {
    return '[$game: çĥööšé á ðîƒƒîçûļţý ·······]';
  }

  @override
  String get difficultyLast => '[Ţĥé öñé ýöû þļáýéð ļášţ ········]';

  @override
  String get resultSolved => '[Šöļṽéð! ···]';

  @override
  String get resultUnassisted => '[Ñö ĥéļþ ···]';

  @override
  String get resultNewRecord => '[Ñéŵ ŕéçöŕð ····]';

  @override
  String get resultTime => '[Ţîɱé ··]';

  @override
  String get resultBest => '[Ɓéšţ ··]';

  @override
  String get resultHints => '[Ĥîñţš ··]';

  @override
  String resultMastery(String level) {
    return '[Ṁášţéŕý öñ $level ····]';
  }

  @override
  String masteryLevel(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'bronze': 'Bronze',
      'silver': 'Silver',
      'gold': 'Gold',
      'other': 'No medal',
    });
    return '[$_temp0 ]';
  }

  @override
  String masteryToNext(int count, String next) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more games for $next',
      one: '1 more game for $next',
    );
    return '[$_temp0 ]';
  }

  @override
  String get masteryComplete => '[Ṁášţéŕý çöɱþļéţé ······]';

  @override
  String resultDaily(int done, int before, int after) {
    return '[Çĥáļļéñĝé: $done öƒ 3 · šţŕéáķ $before → $after ·······]';
  }

  @override
  String get resultAchievement => '[Åçĥîéṽéɱéñţ ûñļöçķéð ········]';

  @override
  String resultPlayAgain(String level) {
    return '[Þļáý áĝáîñ öñ $level ·····]';
  }

  @override
  String get resultNextDaily => '[Ñéẋţ çĥáļļéñĝé ······]';

  @override
  String get resultHome => '[Ɓáçķ ţö ĥöɱé ····]';

  @override
  String achievementTitle(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'first_puzzle': 'First puzzle',
      'all_three_games': 'Try all three games',
      'streak_3': '3-day streak',
      'streak_7': '7-day streak',
      'streak_30': '30-day streak',
      'streak_100': '100-day streak',
      'perfect_day': 'Perfect day',
      'full_month': 'Full month',
      'ten_unassisted': '10 puzzles with no help',
      'sudoku_first_hard': 'First Hard Sudoku',
      'sudoku_first_expert': 'First Expert Sudoku',
      'sudoku_fast_medium': 'Medium Sudoku in under 6 minutes',
      'mines_first_expert': 'First Expert Minesweeper',
      'mines_five_in_a_row': '5 Minesweeper wins in a row',
      'mines_no_flags': 'Win without flags',
      'words_ten_themes': 'Explore 10 themes',
      'words_expert_no_hints': 'Expert word search with no hints',
      'other': '50 word searches done',
    });
    return '[$_temp0 ]';
  }
}
