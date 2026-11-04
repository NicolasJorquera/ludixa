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
  String dailyPlayGame(String game) {
    return 'Play $game';
  }

  @override
  String dailyContinueGame(String game) {
    return 'Continue $game';
  }

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

  @override
  String get progressTabStats => 'Statistics';

  @override
  String get progressTabAchievements => 'Achievements';

  @override
  String get progressEmptyTitle => 'No statistics yet';

  @override
  String get progressEmpty => 'Your statistics will show up once you finish your first puzzle.';

  @override
  String get progressEmptyAction => 'Go to today\'s challenge';

  @override
  String get progressCompleted => 'Puzzles completed';

  @override
  String get progressTotalTime => 'Total time';

  @override
  String get progressStreak => 'Streak';

  @override
  String progressStreakBest(int count) {
    return 'Best: $count';
  }

  @override
  String get progressPerfectDays => 'Perfect days';

  @override
  String get progressGame => 'Game';

  @override
  String get progressColLevel => 'Level';

  @override
  String get progressColPlayed => 'Played';

  @override
  String get progressColWon => 'Won';

  @override
  String get progressColBest => 'Best';

  @override
  String get progressColMean => 'Average';

  @override
  String get progressNotPlayed => 'Not played yet';

  @override
  String progressWonRate(int won, String rate) {
    return '$won ($rate)';
  }

  @override
  String get progressTableHint => 'Long-press a level to reset its statistics.';

  @override
  String get progressResetLevel => 'Reset statistics for this level';

  @override
  String progressResetTitle(String game, String level) {
    return 'Reset $game · $level?';
  }

  @override
  String get progressResetBody =>
      'Games played, best time and average for this level go back to zero. Your streak, calendar and achievements stay the same.';

  @override
  String get progressResetConfirm => 'Reset';

  @override
  String progressResetDone(String level) {
    return '$level statistics reset';
  }

  @override
  String achievementDescription(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'first_puzzle': 'Finish your first puzzle, in any game.',
      'all_three_games': 'Finish at least one puzzle in each game.',
      'streak_3': 'Play the daily challenge 3 days in a row.',
      'streak_7': 'Play the daily challenge 7 days in a row.',
      'streak_30': 'Play the daily challenge 30 days in a row.',
      'streak_100': 'Play the daily challenge 100 days in a row.',
      'perfect_day': 'Finish all three challenges on the same day.',
      'full_month': 'Play the daily challenge on 20 days of the same month.',
      'ten_unassisted': 'Finish 10 puzzles with no hints or help.',
      'sudoku_first_hard': 'Finish a Hard Sudoku.',
      'sudoku_first_expert': 'Finish an Expert Sudoku.',
      'sudoku_fast_medium': 'Finish a Medium Sudoku in under 6 minutes.',
      'mines_first_expert': 'Win an Expert Minesweeper.',
      'mines_five_in_a_row': 'Win 5 Minesweeper games in a row without losing in between.',
      'mines_no_flags': 'Win a Minesweeper without placing any flag.',
      'words_ten_themes': 'Finish word searches from 10 different themes.',
      'words_expert_no_hints': 'Finish an Expert word search without hints.',
      'other': 'Finish 50 word searches.',
    });
    return '$_temp0';
  }

  @override
  String get achievementUnlocked => 'Unlocked';

  @override
  String achievementUnlockedOn(String date) {
    return 'Unlocked on $date';
  }

  @override
  String get achievementLocked => 'Locked';

  @override
  String achievementProgress(int progress, int target) {
    return '$progress of $target';
  }

  @override
  String achievementsCount(int unlocked, int total) {
    return '$unlocked of $total achievements';
  }

  @override
  String get progressNoTime => 'No time';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get textSizeSystem => 'Same as system';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeLarger => 'Larger';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionHint => 'Removes motion effects even if your system allows them';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsHapticsHint => 'When tapping, flagging and finishing a puzzle';

  @override
  String get settingsShowTimer => 'Show the timer';

  @override
  String get settingsShowTimerHint => 'Time is still measured for your statistics';

  @override
  String get settingsGamesSection => 'Games';

  @override
  String get settingsDataSection => 'Data and privacy';

  @override
  String get settingsResetStats => 'Reset statistics';

  @override
  String get settingsResetStatsHint => 'Your streak, calendar and achievements stay the same';

  @override
  String get settingsResetStatsBody => 'Games played, best times and averages for the game you choose go back to zero.';

  @override
  String settingsResetStatsGame(String game) {
    return 'Reset $game';
  }

  @override
  String settingsResetStatsDone(String game) {
    return '$game statistics reset';
  }

  @override
  String get settingsResetAll => 'Reset all progress';

  @override
  String get settingsResetAllHint => 'Deletes games, streak, calendar, achievements and statistics';

  @override
  String get settingsResetAllTitle => 'Delete all your progress?';

  @override
  String get settingsResetAllBody =>
      'Your games, streak, calendar, achievements and statistics will be deleted. Your settings are kept. This can\'t be undone.';

  @override
  String get settingsResetAllWord => 'DELETE';

  @override
  String settingsResetAllPrompt(String word) {
    return 'Type $word to confirm';
  }

  @override
  String get settingsResetAllConfirm => 'Delete everything';

  @override
  String get settingsResetAllDone => 'Your progress was deleted';

  @override
  String get settingsAdsContract => 'Our ad promise';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get linkOpenFailed => 'Couldn\'t open the link';

  @override
  String get adsContractIntro => 'Ludixa is free thanks to ads. These rules don\'t change:';

  @override
  String get adsPromiseMidGame => 'You\'ll never see an ad in the middle of a game.';

  @override
  String get adsPromiseOnOpen => 'You\'ll never see an ad when you open the app.';

  @override
  String get adsPromiseRewarded => 'Rewarded videos are always optional and always give you what they promise.';

  @override
  String get adsPromiseAfterVideo => 'No other ad ever shows right after a rewarded video.';

  @override
  String get adsPromiseOffline => 'Every game works without internet.';

  @override
  String get settingsVersion => 'Version';

  @override
  String get backupExport => 'Export progress';

  @override
  String get backupExportHint => 'Saves a file with your games, streak and achievements';

  @override
  String get backupImport => 'Import progress';

  @override
  String get backupImportHint => 'Replaces your progress with an exported file';

  @override
  String get backupExported => 'Progress exported';

  @override
  String get backupSaveFailed => 'The file couldn\'t be saved. Try another folder.';

  @override
  String get backupOpenFailed => 'The file couldn\'t be opened.';

  @override
  String get backupImportTitle => 'Replace your progress?';

  @override
  String backupImportBody(String date, int sessions, int completed, int best) {
    String _temp0 = intl.Intl.pluralLogic(sessions, locale: localeName, other: '$sessions games', one: '1 game');
    String _temp1 = intl.Intl.pluralLogic(best, locale: localeName, other: '$best days', one: '1 day');
    return 'The backup from $date has $_temp0 ($completed completed) and a best streak of $_temp1. It replaces all your current progress; your settings don\'t change.';
  }

  @override
  String get backupImportConfirm => 'Replace';

  @override
  String get backupImported => 'Progress imported';

  @override
  String get backupProblemTitle => 'Can\'t import';

  @override
  String get backupNotLudixa => 'That file isn\'t a Ludixa backup. Choose the .json file you exported from Settings.';

  @override
  String get backupNewerVersion => 'That backup is from a newer version of Ludixa. Update the app to import it.';

  @override
  String get backupCorrupt => 'The backup is damaged or incomplete. Nothing was changed.';

  @override
  String get backupProblemOk => 'Got it';

  @override
  String get settingsPrivacyOptions => 'Privacy options';

  @override
  String get settingsPrivacyOptionsHint => 'Change your ad choices';

  @override
  String get adLabel => 'Ad';

  @override
  String get devRewardedTest => 'Test rewarded video (development)';

  @override
  String devRewardedResult(String outcome) {
    return 'Video: $outcome';
  }

  @override
  String get hintOfferTitle => 'Extra hint';

  @override
  String hintOfferVideoBody(int free, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left video hints left',
      one: '1 video hint left',
    );
    return 'You used your $free free hints for this puzzle. Watch a video to get one more: $_temp0.';
  }

  @override
  String get hintOfferVideo => 'Watch video · 1 hint';

  @override
  String get hintOfferVideoRule => 'You get the hint only if you watch the whole video.';

  @override
  String get hintOfferCourtesyBody =>
      'There are no videos right now (offline or no ads available). Here\'s a courtesy hint: 1 per day.';

  @override
  String get hintOfferCourtesy => 'Use courtesy hint';

  @override
  String get hintOfferNoneBody =>
      'There are no videos right now and you already used today\'s courtesy hint. Try again later, online.';

  @override
  String get hintOfferLater => 'Not now';
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
  String dailyPlayGame(String game) {
    return '[Þļáý $game ··]';
  }

  @override
  String dailyContinueGame(String game) {
    return '[Çöñţîñûé $game ····]';
  }

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

  @override
  String get progressTabStats => '[Šţáţîšţîçš ····]';

  @override
  String get progressTabAchievements => '[Åçĥîéṽéɱéñţš ·····]';

  @override
  String get progressEmptyTitle => '[Ñö šţáţîšţîçš ýéţ ······]';

  @override
  String get progressEmpty => '[Ýöûŕ šţáţîšţîçš ŵîļļ šĥöŵ ûþ öñçé ýöû ƒîñîšĥ ýöûŕ ƒîŕšţ þûžžļé. ·····················]';

  @override
  String get progressEmptyAction => '[Ĝö ţö ţöðáý\'š çĥáļļéñĝé ········]';

  @override
  String get progressCompleted => '[Þûžžļéš çöɱþļéţéð ·······]';

  @override
  String get progressTotalTime => '[Ţöţáļ ţîɱé ····]';

  @override
  String get progressStreak => '[Šţŕéáķ ···]';

  @override
  String progressStreakBest(int count) {
    return '[Ɓéšţ: $count ··]';
  }

  @override
  String get progressPerfectDays => '[Þéŕƒéçţ ðáýš ·····]';

  @override
  String get progressGame => '[Ĝáɱé ··]';

  @override
  String get progressColLevel => '[Ļéṽéļ ··]';

  @override
  String get progressColPlayed => '[Þļáýéð ···]';

  @override
  String get progressColWon => '[Ŵöñ ··]';

  @override
  String get progressColBest => '[Ɓéšţ ··]';

  @override
  String get progressColMean => '[Åṽéŕáĝé ···]';

  @override
  String get progressNotPlayed => '[Ñöţ þļáýéð ýéţ ·····]';

  @override
  String progressWonRate(int won, String rate) {
    return '[$won ($rate) ]';
  }

  @override
  String get progressTableHint => '[Ļöñĝ-þŕéšš á ļéṽéļ ţö ŕéšéţ îţš šţáţîšţîçš. ··············]';

  @override
  String get progressResetLevel => '[Ŕéšéţ šţáţîšţîçš ƒöŕ ţĥîš ļéṽéļ ···········]';

  @override
  String progressResetTitle(String game, String level) {
    return '[Ŕéšéţ $game · $level? ··]';
  }

  @override
  String get progressResetBody =>
      '[Ĝáɱéš þļáýéð, ƀéšţ ţîɱé áñð áṽéŕáĝé ƒöŕ ţĥîš ļéṽéļ ĝö ƀáçķ ţö žéŕö. Ýöûŕ šţŕéáķ, çáļéñðáŕ áñð áçĥîéṽéɱéñţš šţáý ţĥé šáɱé. ·······································]';

  @override
  String get progressResetConfirm => '[Ŕéšéţ ··]';

  @override
  String progressResetDone(String level) {
    return '[$level šţáţîšţîçš ŕéšéţ ······]';
  }

  @override
  String achievementDescription(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'first_puzzle': 'Finish your first puzzle, in any game.',
      'all_three_games': 'Finish at least one puzzle in each game.',
      'streak_3': 'Play the daily challenge 3 days in a row.',
      'streak_7': 'Play the daily challenge 7 days in a row.',
      'streak_30': 'Play the daily challenge 30 days in a row.',
      'streak_100': 'Play the daily challenge 100 days in a row.',
      'perfect_day': 'Finish all three challenges on the same day.',
      'full_month': 'Play the daily challenge on 20 days of the same month.',
      'ten_unassisted': 'Finish 10 puzzles with no hints or help.',
      'sudoku_first_hard': 'Finish a Hard Sudoku.',
      'sudoku_first_expert': 'Finish an Expert Sudoku.',
      'sudoku_fast_medium': 'Finish a Medium Sudoku in under 6 minutes.',
      'mines_first_expert': 'Win an Expert Minesweeper.',
      'mines_five_in_a_row': 'Win 5 Minesweeper games in a row without losing in between.',
      'mines_no_flags': 'Win a Minesweeper without placing any flag.',
      'words_ten_themes': 'Finish word searches from 10 different themes.',
      'words_expert_no_hints': 'Finish an Expert word search without hints.',
      'other': 'Finish 50 word searches.',
    });
    return '[$_temp0 ]';
  }

  @override
  String get achievementUnlocked => '[Ûñļöçķéð ····]';

  @override
  String achievementUnlockedOn(String date) {
    return '[Ûñļöçķéð öñ $date ····]';
  }

  @override
  String get achievementLocked => '[Ļöçķéð ···]';

  @override
  String achievementProgress(int progress, int target) {
    return '[$progress öƒ $target ·]';
  }

  @override
  String achievementsCount(int unlocked, int total) {
    return '[$unlocked öƒ $total áçĥîéṽéɱéñţš ······]';
  }

  @override
  String get progressNoTime => '[Ñö ţîɱé ···]';

  @override
  String get settingsGeneralSection => '[Ĝéñéŕáļ ···]';

  @override
  String get settingsTextSize => '[Ţéẋţ šîžé ····]';

  @override
  String get textSizeSystem => '[Šáɱé áš šýšţéɱ ·····]';

  @override
  String get textSizeLarge => '[Ļáŕĝé ··]';

  @override
  String get textSizeLarger => '[Ļáŕĝéŕ ···]';

  @override
  String get settingsReduceMotion => '[Ŕéðûçé ɱöţîöñ ·····]';

  @override
  String get settingsReduceMotionHint => '[Ŕéɱöṽéš ɱöţîöñ éƒƒéçţš éṽéñ îƒ ýöûŕ šýšţéɱ áļļöŵš ţĥéɱ ···················]';

  @override
  String get settingsHaptics => '[Ṽîƀŕáţîöñ ····]';

  @override
  String get settingsHapticsHint => '[Ŵĥéñ ţáþþîñĝ, ƒļáĝĝîñĝ áñð ƒîñîšĥîñĝ á þûžžļé ················]';

  @override
  String get settingsShowTimer => '[Šĥöŵ ţĥé ţîɱéŕ ·····]';

  @override
  String get settingsShowTimerHint => '[Ţîɱé îš šţîļļ ɱéášûŕéð ƒöŕ ýöûŕ šţáţîšţîçš ···············]';

  @override
  String get settingsGamesSection => '[Ĝáɱéš ··]';

  @override
  String get settingsDataSection => '[Ðáţá áñð þŕîṽáçý ······]';

  @override
  String get settingsResetStats => '[Ŕéšéţ šţáţîšţîçš ······]';

  @override
  String get settingsResetStatsHint => '[Ýöûŕ šţŕéáķ, çáļéñðáŕ áñð áçĥîéṽéɱéñţš šţáý ţĥé šáɱé ··················]';

  @override
  String get settingsResetStatsBody =>
      '[Ĝáɱéš þļáýéð, ƀéšţ ţîɱéš áñð áṽéŕáĝéš ƒöŕ ţĥé ĝáɱé ýöû çĥööšé ĝö ƀáçķ ţö žéŕö. ·························]';

  @override
  String settingsResetStatsGame(String game) {
    return '[Ŕéšéţ $game ··]';
  }

  @override
  String settingsResetStatsDone(String game) {
    return '[$game šţáţîšţîçš ŕéšéţ ······]';
  }

  @override
  String get settingsResetAll => '[Ŕéšéţ áļļ þŕöĝŕéšš ·······]';

  @override
  String get settingsResetAllHint =>
      '[Ðéļéţéš ĝáɱéš, šţŕéáķ, çáļéñðáŕ, áçĥîéṽéɱéñţš áñð šţáţîšţîçš ·····················]';

  @override
  String get settingsResetAllTitle => '[Ðéļéţé áļļ ýöûŕ þŕöĝŕéšš? ·········]';

  @override
  String get settingsResetAllBody =>
      '[Ýöûŕ ĝáɱéš, šţŕéáķ, çáļéñðáŕ, áçĥîéṽéɱéñţš áñð šţáţîšţîçš ŵîļļ ƀé ðéļéţéð. Ýöûŕ šéţţîñĝš áŕé ķéþţ. Ţĥîš çáñ\'ţ ƀé ûñðöñé. ·······································]';

  @override
  String get settingsResetAllWord => '[ÐÉĻÉŢÉ ···]';

  @override
  String settingsResetAllPrompt(String word) {
    return '[Ţýþé $word ţö çöñƒîŕɱ ······]';
  }

  @override
  String get settingsResetAllConfirm => '[Ðéļéţé éṽéŕýţĥîñĝ ·······]';

  @override
  String get settingsResetAllDone => '[Ýöûŕ þŕöĝŕéšš ŵáš ðéļéţéð ·········]';

  @override
  String get settingsAdsContract => '[Öûŕ áð þŕöɱîšé ·····]';

  @override
  String get settingsPrivacyPolicy => '[Þŕîṽáçý þöļîçý ······]';

  @override
  String get linkOpenFailed => '[Çöûļðñ\'ţ öþéñ ţĥé ļîñķ ········]';

  @override
  String get adsContractIntro => '[Ļûðîẋá îš ƒŕéé ţĥáñķš ţö áðš. Ţĥéšé ŕûļéš ðöñ\'ţ çĥáñĝé: ··················]';

  @override
  String get adsPromiseMidGame => '[Ýöû\'ļļ ñéṽéŕ šéé áñ áð îñ ţĥé ɱîððļé öƒ á ĝáɱé. ··············]';

  @override
  String get adsPromiseOnOpen => '[Ýöû\'ļļ ñéṽéŕ šéé áñ áð ŵĥéñ ýöû öþéñ ţĥé áþþ. ··············]';

  @override
  String get adsPromiseRewarded =>
      '[Ŕéŵáŕðéð ṽîðéöš áŕé áļŵáýš öþţîöñáļ áñð áļŵáýš ĝîṽé ýöû ŵĥáţ ţĥéý þŕöɱîšé. ·························]';

  @override
  String get adsPromiseAfterVideo => '[Ñö öţĥéŕ áð éṽéŕ šĥöŵš ŕîĝĥţ áƒţéŕ á ŕéŵáŕðéð ṽîðéö. ·················]';

  @override
  String get adsPromiseOffline => '[Éṽéŕý ĝáɱé ŵöŕķš ŵîţĥöûţ îñţéŕñéţ. ············]';

  @override
  String get settingsVersion => '[Ṽéŕšîöñ ···]';

  @override
  String get backupExport => '[Éẋþöŕţ þŕöĝŕéšš ······]';

  @override
  String get backupExportHint => '[Šáṽéš á ƒîļé ŵîţĥ ýöûŕ ĝáɱéš, šţŕéáķ áñð áçĥîéṽéɱéñţš ··················]';

  @override
  String get backupImport => '[Îɱþöŕţ þŕöĝŕéšš ······]';

  @override
  String get backupImportHint => '[Ŕéþļáçéš ýöûŕ þŕöĝŕéšš ŵîţĥ áñ éẋþöŕţéð ƒîļé ················]';

  @override
  String get backupExported => '[Þŕöĝŕéšš éẋþöŕţéð ·······]';

  @override
  String get backupSaveFailed => '[Ţĥé ƒîļé çöûļðñ\'ţ ƀé šáṽéð. Ţŕý áñöţĥéŕ ƒöļðéŕ. ···············]';

  @override
  String get backupOpenFailed => '[Ţĥé ƒîļé çöûļðñ\'ţ ƀé öþéñéð. ·········]';

  @override
  String get backupImportTitle => '[Ŕéþļáçé ýöûŕ þŕöĝŕéšš? ········]';

  @override
  String backupImportBody(String date, int sessions, int completed, int best) {
    String _temp0 = intl.Intl.pluralLogic(sessions, locale: localeName, other: '$sessions games', one: '1 game');
    String _temp1 = intl.Intl.pluralLogic(best, locale: localeName, other: '$best days', one: '1 day');
    return '[Ţĥé ƀáçķûþ ƒŕöɱ $date ĥáš $_temp0 ($completed çöɱþļéţéð) áñð á ƀéšţ šţŕéáķ öƒ $_temp1. Îţ ŕéþļáçéš áļļ ýöûŕ çûŕŕéñţ þŕöĝŕéšš; ýöûŕ šéţţîñĝš ðöñ\'ţ çĥáñĝé. ······································]';
  }

  @override
  String get backupImportConfirm => '[Ŕéþļáçé ···]';

  @override
  String get backupImported => '[Þŕöĝŕéšš îɱþöŕţéð ·······]';

  @override
  String get backupProblemTitle => '[Çáñ\'ţ îɱþöŕţ ····]';

  @override
  String get backupNotLudixa =>
      '[Ţĥáţ ƒîļé îšñ\'ţ á Ļûðîẋá ƀáçķûþ. Çĥööšé ţĥé .ĵšöñ ƒîļé ýöû éẋþöŕţéð ƒŕöɱ Šéţţîñĝš. ··························]';

  @override
  String get backupNewerVersion =>
      '[Ţĥáţ ƀáçķûþ îš ƒŕöɱ á ñéŵéŕ ṽéŕšîöñ öƒ Ļûðîẋá. Ûþðáţé ţĥé áþþ ţö îɱþöŕţ îţ. ························]';

  @override
  String get backupCorrupt => '[Ţĥé ƀáçķûþ îš ðáɱáĝéð öŕ îñçöɱþļéţé. Ñöţĥîñĝ ŵáš çĥáñĝéð. ···················]';

  @override
  String get backupProblemOk => '[Ĝöţ îţ ··]';

  @override
  String get settingsPrivacyOptions => '[Þŕîṽáçý öþţîöñš ······]';

  @override
  String get settingsPrivacyOptionsHint => '[Çĥáñĝé ýöûŕ áð çĥöîçéš ········]';

  @override
  String get adLabel => '[Åð ·]';

  @override
  String get devRewardedTest => '[Ţéšţ ŕéŵáŕðéð ṽîðéö (ðéṽéļöþɱéñţ) ············]';

  @override
  String devRewardedResult(String outcome) {
    return '[Ṽîðéö: $outcome ··]';
  }

  @override
  String get hintOfferTitle => '[Éẋţŕá ĥîñţ ····]';

  @override
  String hintOfferVideoBody(int free, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left video hints left',
      one: '1 video hint left',
    );
    return '[Ýöû ûšéð ýöûŕ $free ƒŕéé ĥîñţš ƒöŕ ţĥîš þûžžļé. Ŵáţçĥ á ṽîðéö ţö ĝéţ öñé ɱöŕé: $_temp0. ·······················]';
  }

  @override
  String get hintOfferVideo => '[Ŵáţçĥ ṽîðéö · 1 ĥîñţ ······]';

  @override
  String get hintOfferVideoRule => '[Ýöû ĝéţ ţĥé ĥîñţ öñļý îƒ ýöû ŵáţçĥ ţĥé ŵĥöļé ṽîðéö. ················]';

  @override
  String get hintOfferCourtesyBody =>
      '[Ţĥéŕé áŕé ñö ṽîðéöš ŕîĝĥţ ñöŵ (öƒƒļîñé öŕ ñö áðš áṽáîļáƀļé). Ĥéŕé\'š á çöûŕţéšý ĥîñţ: 1 þéŕ ðáý. ·····························]';

  @override
  String get hintOfferCourtesy => '[Ûšé çöûŕţéšý ĥîñţ ······]';

  @override
  String get hintOfferNoneBody =>
      '[Ţĥéŕé áŕé ñö ṽîðéöš ŕîĝĥţ ñöŵ áñð ýöû áļŕéáðý ûšéð ţöðáý\'š çöûŕţéšý ĥîñţ. Ţŕý áĝáîñ ļáţéŕ, öñļîñé. ································]';

  @override
  String get hintOfferLater => '[Ñöţ ñöŵ ···]';
}
