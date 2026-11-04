// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Ludixa';

  @override
  String get navHome => 'Inicio';

  @override
  String get navDaily => 'Reto';

  @override
  String get navProgress => 'Progreso';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navigationLabel => 'Navegación principal';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get dailyTitle => 'Reto de hoy';

  @override
  String get progressTitle => 'Progreso';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsThemeSection => 'Tema';

  @override
  String get themeSystem => 'Como el sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get colorblindPalette => 'Paleta para daltonismo';

  @override
  String get colorblindPaletteHint => 'Cambia rojos y verdes por naranjas y azules';

  @override
  String get settingsLanguageSection => 'Idioma';

  @override
  String get languageSystem => 'Como el sistema';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePseudo => 'Pseudolocalización (desarrollo)';

  @override
  String get settingsAboutSection => 'Información';

  @override
  String get settingsComponentCatalog => 'Catálogo de componentes (desarrollo)';

  @override
  String get settingsLicenses => 'Licencias de código abierto';

  @override
  String get settingsDevGames => 'Probar juegos (desarrollo)';

  @override
  String get pauseTitle => 'Pausa';

  @override
  String get pauseBoardHidden => 'Tablero oculto en pausa';

  @override
  String get pauseResume => 'Reanudar';

  @override
  String get pauseRestart => 'Reiniciar';

  @override
  String get pauseRestartConfirm => 'Se perderá el avance de este puzzle.';

  @override
  String get pauseRestartYes => 'Sí, reiniciar';

  @override
  String get pauseCancel => 'Cancelar';

  @override
  String get pauseHowToPlay => 'Cómo se juega';

  @override
  String get pauseGameSettings => 'Ajustes del juego';

  @override
  String get pauseSaveExit => 'Guardar y salir';

  @override
  String get pauseAutosave => 'Tu partida se guarda sola en cada jugada.';

  @override
  String difficultyTitle(String game) {
    return '$game: elige la dificultad';
  }

  @override
  String get resultSolved => '¡Resuelto!';

  @override
  String get resultUnassisted => 'Sin ayuda';

  @override
  String get resultNewRecord => 'Nuevo récord';

  @override
  String get resultTime => 'Tiempo';

  @override
  String get resultBest => 'Récord';

  @override
  String get resultHints => 'Pistas';

  @override
  String resultMastery(String level) {
    return 'Maestría en $level';
  }

  @override
  String masteryLevel(String level) {
    String _temp0 = intl.Intl.selectLogic(level, {
      'bronze': 'Bronce',
      'silver': 'Plata',
      'gold': 'Oro',
      'other': 'Sin medalla',
    });
    return '$_temp0';
  }

  @override
  String masteryToNext(int count, String next) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas más para $next',
      one: '1 partida más para $next',
    );
    return '$_temp0';
  }

  @override
  String get masteryComplete => 'Maestría completa';

  @override
  String resultDaily(int done, int before, int after) {
    return 'Reto: $done de 3 · racha $before → $after';
  }

  @override
  String get resultAchievement => 'Logro desbloqueado';

  @override
  String resultPlayAgain(String level) {
    return 'Otra partida en $level';
  }

  @override
  String get resultNextDaily => 'Siguiente reto';

  @override
  String get resultHome => 'Volver al inicio';

  @override
  String achievementTitle(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'first_puzzle': 'Primer puzzle',
      'all_three_games': 'Prueba los tres juegos',
      'streak_3': 'Racha de 3 días',
      'streak_7': 'Racha de 7 días',
      'streak_30': 'Racha de 30 días',
      'streak_100': 'Racha de 100 días',
      'perfect_day': 'Día perfecto',
      'full_month': 'Mes completo',
      'ten_unassisted': '10 puzzles sin ayuda',
      'sudoku_first_hard': 'Primer Sudoku Difícil',
      'sudoku_first_expert': 'Primer Sudoku Experto',
      'sudoku_fast_medium': 'Sudoku Medio en menos de 6 minutos',
      'mines_first_expert': 'Primer Buscaminas Experto',
      'mines_five_in_a_row': '5 victorias seguidas en Buscaminas',
      'mines_no_flags': 'Ganar sin banderas',
      'words_ten_themes': 'Explora 10 temas',
      'words_expert_no_hints': 'Sopa Experta sin pistas',
      'other': '50 sopas completadas',
    });
    return '$_temp0';
  }

  @override
  String difficultyStart(String level) {
    return 'Empezar · $level';
  }

  @override
  String difficultyBest(String time) {
    return 'Récord $time';
  }

  @override
  String get difficultyNoGames => 'Sin partidas';

  @override
  String get difficultyLevels => 'Nivel';

  @override
  String homeStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha de $count días',
      one: 'Racha de 1 día',
    );
    return '$_temp0';
  }

  @override
  String get homeDailyTitle => 'Reto de hoy';

  @override
  String get homeDailyFirst => 'Empieza con el reto de hoy';

  @override
  String homeDailyProgress(int done) {
    return '$done de 3 hechos';
  }

  @override
  String homeDailyPlay(String game) {
    return 'Jugar $game';
  }

  @override
  String get homeDailyDone => 'Hoy: hecho';

  @override
  String homeDailyDoneTime(String time) {
    return 'Tiempo total $time';
  }

  @override
  String get homeDailyArchive => 'Días anteriores';

  @override
  String get homeDailyStateDone => 'hecho';

  @override
  String get homeDailyStatePending => 'pendiente';

  @override
  String get homeContinue => 'Continuar';

  @override
  String homeContinueDetail(String game, String level, String time) {
    return '$game · $level · $time';
  }

  @override
  String get homeGames => 'Juegos';

  @override
  String homeMastery(String medal, String level) {
    return 'Maestría $medal en $level';
  }

  @override
  String get homeNoMastery => 'Sin medallas todavía';

  @override
  String homeGameLabel(String game, String mastery) {
    return '$game, $mastery';
  }

  @override
  String get homeWeek => 'Tu semana';

  @override
  String homeWeekGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas',
      one: '1 partida',
      zero: 'sin partidas',
    );
    return '$_temp0';
  }

  @override
  String homeWeekTime(String time) {
    return 'Tiempo jugado $time';
  }

  @override
  String homeWeekBest(String time) {
    return 'mejor $time';
  }

  @override
  String get homeLoadError => 'No pudimos cargar tu progreso';

  @override
  String get homeRetry => 'Reintentar';

  @override
  String dailyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días seguidos',
      one: '1 día seguido',
      zero: 'Sin racha todavía',
    );
    return '$_temp0';
  }

  @override
  String dailyBest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu máximo: $count días',
      one: 'Tu máximo: 1 día',
    );
    return '$_temp0';
  }

  @override
  String dailySavers(int count) {
    return 'Comodines: $count de 2';
  }

  @override
  String get dailySaversHelp => 'Se gana 1 cada 7 días seguidos y cubre un día sin jugar.';

  @override
  String dailySaversNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Si juegas hoy, $count comodines cubren los días que faltaron.',
      one: 'Si juegas hoy, un comodín cubre el día que faltó.',
    );
    return '$_temp0';
  }

  @override
  String dailyPrevious(int count) {
    return 'Racha anterior: $count días. ¡A por otra!';
  }

  @override
  String get dailyDone => 'Hoy: hecho';

  @override
  String dailyNext(String time) {
    return 'Próximo reto a las $time';
  }

  @override
  String dailyCompletedIn(String time) {
    return 'Completado en $time';
  }

  @override
  String get dailyCompletedArchive => 'Completado desde el archivo';

  @override
  String get dailyPlay => 'Jugar';

  @override
  String get dailyContinue => 'Continuar';

  @override
  String dailyCalendar(String month) {
    return 'Calendario de $month';
  }

  @override
  String dailyDayLabel(String date, int count, String suffix) {
    return '$date, $count de 3 retos$suffix';
  }

  @override
  String get dailyDayToday => ', hoy';

  @override
  String get dailyDayPerfect => ', día perfecto';

  @override
  String get dailyDaySaver => ', cubierto por un comodín';

  @override
  String dailyDayArchive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ', $count desde el archivo',
      one: ', 1 desde el archivo',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get dailyArchive => 'Días anteriores';

  @override
  String get archiveTitle => 'Días anteriores';

  @override
  String get archiveHint =>
      'Puedes jugar los retos de los últimos 30 días. No suman a la racha, pero completan el calendario.';

  @override
  String archiveMarks(int count) {
    return '$count de 3';
  }

  @override
  String get archiveOutside => 'Este día ya no está en el archivo.';

  @override
  String get progressTabStats => 'Estadísticas';

  @override
  String get progressTabAchievements => 'Logros';

  @override
  String get progressEmptyTitle => 'Aún no hay estadísticas';

  @override
  String get progressEmpty => 'Tus estadísticas aparecerán al completar tu primer puzzle.';

  @override
  String get progressEmptyAction => 'Ir al reto de hoy';

  @override
  String get progressCompleted => 'Puzzles completados';

  @override
  String get progressTotalTime => 'Tiempo total';

  @override
  String get progressStreak => 'Racha';

  @override
  String progressStreakBest(int count) {
    return 'Mejor: $count';
  }

  @override
  String get progressPerfectDays => 'Días perfectos';

  @override
  String get progressGame => 'Juego';

  @override
  String get progressColLevel => 'Nivel';

  @override
  String get progressColPlayed => 'Partidas';

  @override
  String get progressColWon => 'Ganadas';

  @override
  String get progressColBest => 'Mejor';

  @override
  String get progressColMean => 'Media';

  @override
  String get progressNotPlayed => 'Aún sin jugar';

  @override
  String progressWonRate(int won, String rate) {
    return '$won ($rate)';
  }

  @override
  String get progressTableHint => 'Mantén pulsado un nivel para reiniciar sus estadísticas.';

  @override
  String get progressResetLevel => 'Reiniciar estadísticas de este nivel';

  @override
  String progressResetTitle(String game, String level) {
    return '¿Reiniciar $game · $level?';
  }

  @override
  String get progressResetBody =>
      'Partidas, mejor tiempo y media de este nivel vuelven a cero. Tu racha, el calendario y los logros no cambian.';

  @override
  String get progressResetConfirm => 'Reiniciar';

  @override
  String progressResetDone(String level) {
    return 'Estadísticas de $level reiniciadas';
  }

  @override
  String achievementDescription(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'first_puzzle': 'Completa tu primer puzzle, en cualquier juego.',
      'all_three_games': 'Completa al menos un puzzle de cada juego.',
      'streak_3': 'Juega el reto diario 3 días seguidos.',
      'streak_7': 'Juega el reto diario 7 días seguidos.',
      'streak_30': 'Juega el reto diario 30 días seguidos.',
      'streak_100': 'Juega el reto diario 100 días seguidos.',
      'perfect_day': 'Completa los tres retos de un mismo día.',
      'full_month': 'Juega el reto diario 20 días de un mismo mes.',
      'ten_unassisted': 'Completa 10 puzzles sin pistas ni ayudas.',
      'sudoku_first_hard': 'Completa un Sudoku en Difícil.',
      'sudoku_first_expert': 'Completa un Sudoku en Experto.',
      'sudoku_fast_medium': 'Completa un Sudoku Medio en menos de 6 minutos.',
      'mines_first_expert': 'Gana un Buscaminas en Experto.',
      'mines_five_in_a_row': 'Gana 5 partidas de Buscaminas seguidas, sin perder entre medio.',
      'mines_no_flags': 'Gana un Buscaminas sin poner ninguna bandera.',
      'words_ten_themes': 'Completa sopas de letras de 10 temas distintos.',
      'words_expert_no_hints': 'Completa una sopa de letras en Experto sin usar pistas.',
      'other': 'Completa 50 sopas de letras.',
    });
    return '$_temp0';
  }

  @override
  String get achievementUnlocked => 'Desbloqueado';

  @override
  String achievementUnlockedOn(String date) {
    return 'Desbloqueado el $date';
  }

  @override
  String get achievementLocked => 'Pendiente';

  @override
  String achievementProgress(int progress, int target) {
    return '$progress de $target';
  }

  @override
  String achievementsCount(int unlocked, int total) {
    return '$unlocked de $total logros';
  }

  @override
  String get progressNoTime => 'Sin tiempo';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsTextSize => 'Tamaño del texto';

  @override
  String get textSizeSystem => 'Como el sistema';

  @override
  String get textSizeLarge => 'Grande';

  @override
  String get textSizeLarger => 'Más grande';

  @override
  String get settingsReduceMotion => 'Reducir animaciones';

  @override
  String get settingsReduceMotionHint => 'Quita los efectos de movimiento aunque el sistema los tenga activos';

  @override
  String get settingsHaptics => 'Vibración';

  @override
  String get settingsHapticsHint => 'Al tocar, poner banderas y completar un puzzle';

  @override
  String get settingsShowTimer => 'Mostrar el temporizador';

  @override
  String get settingsShowTimerHint => 'El tiempo se mide igual para tus estadísticas';

  @override
  String get settingsGamesSection => 'Juegos';

  @override
  String get settingsDataSection => 'Datos y privacidad';

  @override
  String get settingsResetStats => 'Reiniciar estadísticas';

  @override
  String get settingsResetStatsHint => 'Tu racha, el calendario y los logros no cambian';

  @override
  String get settingsResetStatsBody =>
      'Las partidas jugadas, los mejores tiempos y las medias del juego que elijas vuelven a cero.';

  @override
  String settingsResetStatsGame(String game) {
    return 'Reiniciar $game';
  }

  @override
  String settingsResetStatsDone(String game) {
    return 'Estadísticas de $game reiniciadas';
  }

  @override
  String get settingsResetAll => 'Reiniciar todo el progreso';

  @override
  String get settingsResetAllHint => 'Borra partidas, racha, calendario, logros y estadísticas';

  @override
  String get settingsResetAllTitle => '¿Borrar todo tu progreso?';

  @override
  String get settingsResetAllBody =>
      'Se borran tus partidas, la racha, el calendario, los logros y las estadísticas. Tus ajustes se conservan. No se puede deshacer.';

  @override
  String get settingsResetAllWord => 'BORRAR';

  @override
  String settingsResetAllPrompt(String word) {
    return 'Escribe $word para confirmar';
  }

  @override
  String get settingsResetAllConfirm => 'Borrar todo';

  @override
  String get settingsResetAllDone => 'Se borró tu progreso';

  @override
  String get settingsAdsContract => 'Contrato de anuncios';

  @override
  String get adsContractIntro => 'Ludixa es gratis gracias a los anuncios. Estas reglas no cambian:';

  @override
  String get adsPromiseMidGame => 'Nunca verás un anuncio en mitad de una partida.';

  @override
  String get adsPromiseOnOpen => 'Nunca verás un anuncio al abrir la app.';

  @override
  String get adsPromiseRewarded => 'Los videos con recompensa son siempre opcionales y siempre te dan lo prometido.';

  @override
  String get adsPromiseAfterVideo => 'Después de un video con recompensa nunca aparece otro anuncio.';

  @override
  String get adsPromiseOffline => 'Todos los juegos funcionan sin internet.';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get backupExport => 'Exportar progreso';

  @override
  String get backupExportHint => 'Guarda un archivo con tus partidas, racha y logros';

  @override
  String get backupImport => 'Importar progreso';

  @override
  String get backupImportHint => 'Reemplaza tu progreso por el de un archivo exportado';

  @override
  String get backupExported => 'Progreso exportado';

  @override
  String get backupSaveFailed => 'No se pudo guardar el archivo. Prueba en otra carpeta.';

  @override
  String get backupOpenFailed => 'No se pudo abrir el archivo.';

  @override
  String get backupImportTitle => '¿Reemplazar tu progreso?';

  @override
  String backupImportBody(String date, int sessions, int completed, int best) {
    String _temp0 = intl.Intl.pluralLogic(sessions, locale: localeName, other: '$sessions partidas', one: '1 partida');
    String _temp1 = intl.Intl.pluralLogic(
      completed,
      locale: localeName,
      other: '$completed completadas',
      one: '1 completada',
    );
    String _temp2 = intl.Intl.pluralLogic(best, locale: localeName, other: '$best días', one: '1 día');
    return 'El respaldo del $date tiene $_temp0 ($_temp1) y una racha máxima de $_temp2. Reemplaza todo tu progreso actual; tus ajustes no cambian.';
  }

  @override
  String get backupImportConfirm => 'Reemplazar';

  @override
  String get backupImported => 'Progreso importado';

  @override
  String get backupProblemTitle => 'No se puede importar';

  @override
  String get backupNotLudixa =>
      'Ese archivo no es un respaldo de Ludixa. Elige el archivo .json que exportaste desde Ajustes.';

  @override
  String get backupNewerVersion =>
      'Ese respaldo es de una versión más nueva de Ludixa. Actualiza la app para importarlo.';

  @override
  String get backupCorrupt => 'El respaldo está dañado o incompleto. No se cambió nada.';

  @override
  String get backupProblemOk => 'Entendido';

  @override
  String get settingsPrivacyOptions => 'Opciones de privacidad';

  @override
  String get settingsPrivacyOptionsHint => 'Cambia tu elección sobre los anuncios';

  @override
  String get adLabel => 'Anuncio';

  @override
  String get devRewardedTest => 'Probar video con recompensa (desarrollo)';

  @override
  String devRewardedResult(String outcome) {
    return 'Video: $outcome';
  }
}
