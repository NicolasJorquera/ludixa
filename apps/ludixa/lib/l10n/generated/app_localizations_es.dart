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
  String get comingSoon => 'Esta pantalla llega en una próxima versión de desarrollo.';

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
  String get difficultyLast => 'La última que jugaste';

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
}
