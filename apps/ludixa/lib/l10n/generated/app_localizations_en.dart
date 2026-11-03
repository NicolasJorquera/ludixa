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

  @override
  String difficultyStart(String level) {
    return 'Start · $level';
  }

  @override
  String difficultyBest(String time) {
    return 'Best $time';
  }

  @override
  String get difficultyNoGames => 'No games yet';

  @override
  String get difficultyLevels => 'Level';

  @override
  String homeStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count-day streak', one: '1-day streak');
    return '$_temp0';
  }

  @override
  String get homeDailyTitle => 'Today’s challenge';

  @override
  String get homeDailyFirst => 'Start with today’s challenge';

  @override
  String homeDailyProgress(int done) {
    return '$done of 3 done';
  }

  @override
  String homeDailyPlay(String game) {
    return 'Play $game';
  }

  @override
  String get homeDailyDone => 'Today: done';

  @override
  String homeDailyDoneTime(String time) {
    return 'Total time $time';
  }

  @override
  String get homeDailyArchive => 'Previous days';

  @override
  String get homeDailyStateDone => 'done';

  @override
  String get homeDailyStatePending => 'to do';

  @override
  String get homeContinue => 'Continue';

  @override
  String homeContinueDetail(String game, String level, String time) {
    return '$game · $level · $time';
  }

  @override
  String get homeGames => 'Games';

  @override
  String homeMastery(String medal, String level) {
    return '$medal mastery on $level';
  }

  @override
  String get homeNoMastery => 'No medals yet';

  @override
  String homeGameLabel(String game, String mastery) {
    return '$game, $mastery';
  }

  @override
  String get homeWeek => 'Your week';

  @override
  String homeWeekGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
      zero: 'no games',
    );
    return '$_temp0';
  }

  @override
  String homeWeekTime(String time) {
    return 'Time played $time';
  }

  @override
  String homeWeekBest(String time) {
    return 'best $time';
  }

  @override
  String get homeLoadError => 'We couldn’t load your progress';

  @override
  String get homeRetry => 'Try again';

  @override
  String dailyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in a row',
      one: '1 day in a row',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String dailyBest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your best: $count days',
      one: 'Your best: 1 day',
    );
    return '$_temp0';
  }

  @override
  String dailySavers(int count) {
    return 'Savers: $count of 2';
  }

  @override
  String get dailySaversHelp => 'You earn 1 every 7 days in a row; it covers a missed day.';

  @override
  String dailySaversNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Play today and $count savers cover the missed days.',
      one: 'Play today and a saver covers the missed day.',
    );
    return '$_temp0';
  }

  @override
  String dailyPrevious(int count) {
    return 'Previous streak: $count days. Let’s start another!';
  }

  @override
  String get dailyDone => 'Today: done';

  @override
  String dailyNext(String time) {
    return 'Next challenge at $time';
  }

  @override
  String dailyCompletedIn(String time) {
    return 'Done in $time';
  }

  @override
  String get dailyCompletedArchive => 'Done from the archive';

  @override
  String get dailyPlay => 'Play';

  @override
  String get dailyContinue => 'Continue';

  @override
  String dailyCalendar(String month) {
    return '$month calendar';
  }

  @override
  String dailyDayLabel(String date, int count, String suffix) {
    return '$date, $count of 3 challenges$suffix';
  }

  @override
  String get dailyDayToday => ', today';

  @override
  String get dailyDayPerfect => ', perfect day';

  @override
  String get dailyDaySaver => ', covered by a saver';

  @override
  String dailyDayArchive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', $count from the archive',
      one: ', 1 from the archive',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get dailyArchive => 'Previous days';

  @override
  String get archiveTitle => 'Previous days';

  @override
  String get archiveHint =>
      'You can play the last 30 days of challenges. They don’t count for your streak, but they fill in the calendar.';

  @override
  String archiveMarks(int count) {
    return '$count of 3';
  }

  @override
  String get archiveOutside => 'This day is no longer in the archive.';
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

  @override
  String difficultyStart(String level) {
    return '[Šţáŕţ · $level ··]';
  }

  @override
  String difficultyBest(String time) {
    return '[Ɓéšţ $time ··]';
  }

  @override
  String get difficultyNoGames => '[Ñö ĝáɱéš ýéţ ····]';

  @override
  String get difficultyLevels => '[Ļéṽéļ ··]';

  @override
  String homeStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count-day streak', one: '1-day streak');
    return '[$_temp0 ]';
  }

  @override
  String get homeDailyTitle => '[Ţöðáý’š çĥáļļéñĝé ······]';

  @override
  String get homeDailyFirst => '[Šţáŕţ ŵîţĥ ţöðáý’š çĥáļļéñĝé ··········]';

  @override
  String homeDailyProgress(int done) {
    return '[$done öƒ 3 ðöñé ···]';
  }

  @override
  String homeDailyPlay(String game) {
    return '[Þļáý $game ··]';
  }

  @override
  String get homeDailyDone => '[Ţöðáý: ðöñé ····]';

  @override
  String homeDailyDoneTime(String time) {
    return '[Ţöţáļ ţîɱé $time ····]';
  }

  @override
  String get homeDailyArchive => '[Þŕéṽîöûš ðáýš ·····]';

  @override
  String get homeDailyStateDone => '[ðöñé ··]';

  @override
  String get homeDailyStatePending => '[ţö ðö ··]';

  @override
  String get homeContinue => '[Çöñţîñûé ····]';

  @override
  String homeContinueDetail(String game, String level, String time) {
    return '[$game · $level · $time ]';
  }

  @override
  String get homeGames => '[Ĝáɱéš ··]';

  @override
  String homeMastery(String medal, String level) {
    return '[$medal ɱášţéŕý öñ $level ····]';
  }

  @override
  String get homeNoMastery => '[Ñö ɱéðáļš ýéţ ·····]';

  @override
  String homeGameLabel(String game, String mastery) {
    return '[$game, $mastery ]';
  }

  @override
  String get homeWeek => '[Ýöûŕ ŵééķ ····]';

  @override
  String homeWeekGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games',
      one: '1 game',
      zero: 'no games',
    );
    return '[$_temp0 ]';
  }

  @override
  String homeWeekTime(String time) {
    return '[Ţîɱé þļáýéð $time ····]';
  }

  @override
  String homeWeekBest(String time) {
    return '[ƀéšţ $time ··]';
  }

  @override
  String get homeLoadError => '[Ŵé çöûļðñ’ţ ļöáð ýöûŕ þŕöĝŕéšš ··········]';

  @override
  String get homeRetry => '[Ţŕý áĝáîñ ····]';

  @override
  String dailyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in a row',
      one: '1 day in a row',
      zero: 'No streak yet',
    );
    return '[$_temp0 ]';
  }

  @override
  String dailyBest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your best: $count days',
      one: 'Your best: 1 day',
    );
    return '[$_temp0 ]';
  }

  @override
  String dailySavers(int count) {
    return '[Šáṽéŕš: $count öƒ 2 ····]';
  }

  @override
  String get dailySaversHelp => '[Ýöû éáŕñ 1 éṽéŕý 7 ðáýš îñ á ŕöŵ; îţ çöṽéŕš á ɱîššéð ðáý. ················]';

  @override
  String dailySaversNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Play today and $count savers cover the missed days.',
      one: 'Play today and a saver covers the missed day.',
    );
    return '[$_temp0 ]';
  }

  @override
  String dailyPrevious(int count) {
    return '[Þŕéṽîöûš šţŕéáķ: $count ðáýš. Ļéţ’š šţáŕţ áñöţĥéŕ! ··············]';
  }

  @override
  String get dailyDone => '[Ţöðáý: ðöñé ····]';

  @override
  String dailyNext(String time) {
    return '[Ñéẋţ çĥáļļéñĝé áţ $time ······]';
  }

  @override
  String dailyCompletedIn(String time) {
    return '[Ðöñé îñ $time ···]';
  }

  @override
  String get dailyCompletedArchive => '[Ðöñé ƒŕöɱ ţĥé áŕçĥîṽé ········]';

  @override
  String get dailyPlay => '[Þļáý ··]';

  @override
  String get dailyContinue => '[Çöñţîñûé ····]';

  @override
  String dailyCalendar(String month) {
    return '[$month çáļéñðáŕ ····]';
  }

  @override
  String dailyDayLabel(String date, int count, String suffix) {
    return '[$date, $count öƒ 3 çĥáļļéñĝéš$suffix ·····]';
  }

  @override
  String get dailyDayToday => '[, ţöðáý ··]';

  @override
  String get dailyDayPerfect => '[, þéŕƒéçţ ðáý ····]';

  @override
  String get dailyDaySaver => '[, çöṽéŕéð ƀý á šáṽéŕ ······]';

  @override
  String dailyDayArchive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', $count from the archive',
      one: ', 1 from the archive',
      zero: '',
    );
    return '[$_temp0 ]';
  }

  @override
  String get dailyArchive => '[Þŕéṽîöûš ðáýš ·····]';

  @override
  String get archiveTitle => '[Þŕéṽîöûš ðáýš ·····]';

  @override
  String get archiveHint =>
      '[Ýöû çáñ þļáý ţĥé ļášţ 30 ðáýš öƒ çĥáļļéñĝéš. Ţĥéý ðöñ’ţ çöûñţ ƒöŕ ýöûŕ šţŕéáķ, ƀûţ ţĥéý ƒîļļ îñ ţĥé çáļéñðáŕ. ··································]';

  @override
  String archiveMarks(int count) {
    return '[$count öƒ 3 ·]';
  }

  @override
  String get archiveOutside => '[Ţĥîš ðáý îš ñö ļöñĝéŕ îñ ţĥé áŕçĥîṽé. ············]';
}
