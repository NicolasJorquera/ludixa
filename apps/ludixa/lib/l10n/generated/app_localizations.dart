import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('en', 'XA'), Locale('es')];

  /// Nombre de la app.
  ///
  /// In es, this message translates to:
  /// **'Ludixa'**
  String get appName;

  /// Pestaña de la portada.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// Pestaña del reto diario.
  ///
  /// In es, this message translates to:
  /// **'Reto'**
  String get navDaily;

  /// Pestaña de estadísticas y logros.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get navProgress;

  /// Pestaña de ajustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// Etiqueta de accesibilidad de la barra de pestañas.
  ///
  /// In es, this message translates to:
  /// **'Navegación principal'**
  String get navigationLabel;

  /// Título de la portada.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeTitle;

  /// Título de la pantalla del reto diario.
  ///
  /// In es, this message translates to:
  /// **'Reto de hoy'**
  String get dailyTitle;

  /// Título de la pantalla de progreso.
  ///
  /// In es, this message translates to:
  /// **'Progreso'**
  String get progressTitle;

  /// Título de la pantalla de ajustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// Encabezado de la sección de tema.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get settingsThemeSection;

  /// Opción de tema que sigue al sistema.
  ///
  /// In es, this message translates to:
  /// **'Como el sistema'**
  String get themeSystem;

  /// Opción de tema claro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// Opción de tema oscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// Interruptor de la paleta que no depende de distinguir rojo y verde.
  ///
  /// In es, this message translates to:
  /// **'Paleta para daltonismo'**
  String get colorblindPalette;

  /// Explicación breve bajo el interruptor de daltonismo.
  ///
  /// In es, this message translates to:
  /// **'Cambia rojos y verdes por naranjas y azules'**
  String get colorblindPaletteHint;

  /// Encabezado de la sección de idioma.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguageSection;

  /// Opción de idioma que sigue al sistema.
  ///
  /// In es, this message translates to:
  /// **'Como el sistema'**
  String get languageSystem;

  /// Nombre del español, siempre en español.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Nombre del inglés, siempre en inglés.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Idioma de prueba que alarga y acentúa los textos. Solo en desarrollo.
  ///
  /// In es, this message translates to:
  /// **'Pseudolocalización (desarrollo)'**
  String get languagePseudo;

  /// Encabezado de la sección de información.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get settingsAboutSection;

  /// Entrada al catálogo del sistema visual. Solo en desarrollo.
  ///
  /// In es, this message translates to:
  /// **'Catálogo de componentes (desarrollo)'**
  String get settingsComponentCatalog;

  /// Entrada que abre las licencias de las dependencias.
  ///
  /// In es, this message translates to:
  /// **'Licencias de código abierto'**
  String get settingsLicenses;

  /// Entrada a los juegos de prueba. Solo en desarrollo.
  ///
  /// In es, this message translates to:
  /// **'Probar juegos (desarrollo)'**
  String get settingsDevGames;

  /// Título de la pantalla de pausa.
  ///
  /// In es, this message translates to:
  /// **'Pausa'**
  String get pauseTitle;

  /// Se anuncia al abrir la pausa.
  ///
  /// In es, this message translates to:
  /// **'Tablero oculto en pausa'**
  String get pauseBoardHidden;

  /// Botón principal de la pausa.
  ///
  /// In es, this message translates to:
  /// **'Reanudar'**
  String get pauseResume;

  /// Empezar el puzzle de cero.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar'**
  String get pauseRestart;

  /// Confirmación de reiniciar, dentro de la pausa.
  ///
  /// In es, this message translates to:
  /// **'Se perderá el avance de este puzzle.'**
  String get pauseRestartConfirm;

  /// Confirma reiniciar.
  ///
  /// In es, this message translates to:
  /// **'Sí, reiniciar'**
  String get pauseRestartYes;

  /// Cancela reiniciar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get pauseCancel;

  /// Abre el tutorial.
  ///
  /// In es, this message translates to:
  /// **'Cómo se juega'**
  String get pauseHowToPlay;

  /// Abre los ajustes del juego.
  ///
  /// In es, this message translates to:
  /// **'Ajustes del juego'**
  String get pauseGameSettings;

  /// Sale de la partida; queda guardada.
  ///
  /// In es, this message translates to:
  /// **'Guardar y salir'**
  String get pauseSaveExit;

  /// Nota de guardado automático.
  ///
  /// In es, this message translates to:
  /// **'Tu partida se guarda sola en cada jugada.'**
  String get pauseAutosave;

  /// Título de la hoja de dificultad.
  ///
  /// In es, this message translates to:
  /// **'{game}: elige la dificultad'**
  String difficultyTitle(String game);

  /// Título del resultado.
  ///
  /// In es, this message translates to:
  /// **'¡Resuelto!'**
  String get resultSolved;

  /// Chip: sin pistas ni rescate.
  ///
  /// In es, this message translates to:
  /// **'Sin ayuda'**
  String get resultUnassisted;

  /// Chip de récord nuevo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo récord'**
  String get resultNewRecord;

  /// Métrica.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get resultTime;

  /// Métrica: mejor tiempo del nivel.
  ///
  /// In es, this message translates to:
  /// **'Récord'**
  String get resultBest;

  /// Métrica.
  ///
  /// In es, this message translates to:
  /// **'Pistas'**
  String get resultHints;

  /// Encabezado del bloque de maestría.
  ///
  /// In es, this message translates to:
  /// **'Maestría en {level}'**
  String resultMastery(String level);

  /// Nivel de maestría.
  ///
  /// In es, this message translates to:
  /// **'{level, select, bronze{Bronce} silver{Plata} gold{Oro} other{Sin medalla}}'**
  String masteryLevel(String level);

  /// Partidas que faltan para el siguiente nivel.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 partida más para {next}} other{{count} partidas más para {next}}}'**
  String masteryToNext(int count, String next);

  /// Ya en Oro.
  ///
  /// In es, this message translates to:
  /// **'Maestría completa'**
  String get masteryComplete;

  /// Bloque del reto diario en el resultado.
  ///
  /// In es, this message translates to:
  /// **'Reto: {done} de 3 · racha {before} → {after}'**
  String resultDaily(int done, int before, int after);

  /// Tarjeta de logro en el resultado.
  ///
  /// In es, this message translates to:
  /// **'Logro desbloqueado'**
  String get resultAchievement;

  /// Botón: otra partida del mismo nivel.
  ///
  /// In es, this message translates to:
  /// **'Otra partida en {level}'**
  String resultPlayAgain(String level);

  /// Botón: el siguiente reto pendiente del día.
  ///
  /// In es, this message translates to:
  /// **'Siguiente reto'**
  String get resultNextDaily;

  /// Botón secundario del resultado.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get resultHome;

  /// Nombre de un logro, por su id estable.
  ///
  /// In es, this message translates to:
  /// **'{key, select, first_puzzle{Primer puzzle} all_three_games{Prueba los tres juegos} streak_3{Racha de 3 días} streak_7{Racha de 7 días} streak_30{Racha de 30 días} streak_100{Racha de 100 días} perfect_day{Día perfecto} full_month{Mes completo} ten_unassisted{10 puzzles sin ayuda} sudoku_first_hard{Primer Sudoku Difícil} sudoku_first_expert{Primer Sudoku Experto} sudoku_fast_medium{Sudoku Medio en menos de 6 minutos} mines_first_expert{Primer Buscaminas Experto} mines_five_in_a_row{5 victorias seguidas en Buscaminas} mines_no_flags{Ganar sin banderas} words_ten_themes{Explora 10 temas} words_expert_no_hints{Sopa Experta sin pistas} other{50 sopas completadas}}'**
  String achievementTitle(String key);

  /// Botón principal de la hoja de dificultad.
  ///
  /// In es, this message translates to:
  /// **'Empezar · {level}'**
  String difficultyStart(String level);

  /// Mejor tiempo del nivel.
  ///
  /// In es, this message translates to:
  /// **'Récord {time}'**
  String difficultyBest(String time);

  /// Nivel sin partidas ganadas.
  ///
  /// In es, this message translates to:
  /// **'Sin partidas'**
  String get difficultyNoGames;

  /// Nombre del grupo de opciones de nivel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get difficultyLevels;

  /// Chip de racha en la portada.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Racha de 1 día} other{Racha de {count} días}}'**
  String homeStreak(int count);

  /// Tarjeta del reto en la portada.
  ///
  /// In es, this message translates to:
  /// **'Reto de hoy'**
  String get homeDailyTitle;

  /// Primera vez: invitación al reto.
  ///
  /// In es, this message translates to:
  /// **'Empieza con el reto de hoy'**
  String get homeDailyFirst;

  /// Avance del reto del día.
  ///
  /// In es, this message translates to:
  /// **'{done} de 3 hechos'**
  String homeDailyProgress(int done);

  /// Botón principal: el primer reto pendiente.
  ///
  /// In es, this message translates to:
  /// **'Jugar {game}'**
  String homeDailyPlay(String game);

  /// Reto del día completo.
  ///
  /// In es, this message translates to:
  /// **'Hoy: hecho'**
  String get homeDailyDone;

  /// Tiempo de los tres retos.
  ///
  /// In es, this message translates to:
  /// **'Tiempo total {time}'**
  String homeDailyDoneTime(String time);

  /// Enlace al archivo (pestaña Reto).
  ///
  /// In es, this message translates to:
  /// **'Días anteriores'**
  String get homeDailyArchive;

  /// Estado de un juego en el reto.
  ///
  /// In es, this message translates to:
  /// **'hecho'**
  String get homeDailyStateDone;

  /// Estado de un juego en el reto.
  ///
  /// In es, this message translates to:
  /// **'pendiente'**
  String get homeDailyStatePending;

  /// Tarjeta de la partida en curso.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get homeContinue;

  /// Detalle de la partida en curso.
  ///
  /// In es, this message translates to:
  /// **'{game} · {level} · {time}'**
  String homeContinueDetail(String game, String level, String time);

  /// Título del catálogo.
  ///
  /// In es, this message translates to:
  /// **'Juegos'**
  String get homeGames;

  /// Maestría del juego en la portada.
  ///
  /// In es, this message translates to:
  /// **'Maestría {medal} en {level}'**
  String homeMastery(String medal, String level);

  /// Juego sin partidas ganadas.
  ///
  /// In es, this message translates to:
  /// **'Sin medallas todavía'**
  String get homeNoMastery;

  /// Etiqueta accesible de una tarjeta de juego.
  ///
  /// In es, this message translates to:
  /// **'{game}, {mastery}'**
  String homeGameLabel(String game, String mastery);

  /// Resumen semanal.
  ///
  /// In es, this message translates to:
  /// **'Tu semana'**
  String get homeWeek;

  /// Partidas completadas de un juego en la semana.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{sin partidas} =1{1 partida} other{{count} partidas}}'**
  String homeWeekGames(int count);

  /// Tiempo total de la semana.
  ///
  /// In es, this message translates to:
  /// **'Tiempo jugado {time}'**
  String homeWeekTime(String time);

  /// Mejor marca de la semana de un juego.
  ///
  /// In es, this message translates to:
  /// **'mejor {time}'**
  String homeWeekBest(String time);

  /// Error al leer los datos.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu progreso'**
  String get homeLoadError;

  /// Reintentar la carga.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get homeRetry;

  /// Racha actual en la pestaña Reto.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin racha todavía} =1{1 día seguido} other{{count} días seguidos}}'**
  String dailyStreakDays(int count);

  /// Racha máxima.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Tu máximo: 1 día} other{Tu máximo: {count} días}}'**
  String dailyBest(int count);

  /// Comodines disponibles.
  ///
  /// In es, this message translates to:
  /// **'Comodines: {count} de 2'**
  String dailySavers(int count);

  /// Ayuda de los comodines.
  ///
  /// In es, this message translates to:
  /// **'Se gana 1 cada 7 días seguidos y cubre un día sin jugar.'**
  String get dailySaversHelp;

  /// Racha en riesgo sostenida por comodines.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Si juegas hoy, un comodín cubre el día que faltó.} other{Si juegas hoy, {count} comodines cubren los días que faltaron.}}'**
  String dailySaversNeeded(int count);

  /// Texto neutro cuando se rompe la racha.
  ///
  /// In es, this message translates to:
  /// **'Racha anterior: {count} días. ¡A por otra!'**
  String dailyPrevious(int count);

  /// Día completo.
  ///
  /// In es, this message translates to:
  /// **'Hoy: hecho'**
  String get dailyDone;

  /// Hora del próximo reto.
  ///
  /// In es, this message translates to:
  /// **'Próximo reto a las {time}'**
  String dailyNext(String time);

  /// Reto completado ese día.
  ///
  /// In es, this message translates to:
  /// **'Completado en {time}'**
  String dailyCompletedIn(String time);

  /// Reto completado después, desde el archivo.
  ///
  /// In es, this message translates to:
  /// **'Completado desde el archivo'**
  String get dailyCompletedArchive;

  /// Botón para jugar un reto.
  ///
  /// In es, this message translates to:
  /// **'Jugar'**
  String get dailyPlay;

  /// Botón para continuar un reto empezado.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get dailyContinue;

  /// Etiqueta accesible del calendario.
  ///
  /// In es, this message translates to:
  /// **'Calendario de {month}'**
  String dailyCalendar(String month);

  /// Etiqueta accesible de un día del calendario.
  ///
  /// In es, this message translates to:
  /// **'{date}, {count} de 3 retos{suffix}'**
  String dailyDayLabel(String date, int count, String suffix);

  /// Sufijo: el día es hoy.
  ///
  /// In es, this message translates to:
  /// **', hoy'**
  String get dailyDayToday;

  /// Sufijo: día perfecto.
  ///
  /// In es, this message translates to:
  /// **', día perfecto'**
  String get dailyDayPerfect;

  /// Sufijo: día cubierto por un comodín.
  ///
  /// In es, this message translates to:
  /// **', cubierto por un comodín'**
  String get dailyDaySaver;

  /// Sufijo: retos hechos desde el archivo.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{} =1{, 1 desde el archivo} other{, {count} desde el archivo}}'**
  String dailyDayArchive(int count);

  /// Botón al archivo.
  ///
  /// In es, this message translates to:
  /// **'Días anteriores'**
  String get dailyArchive;

  /// Título del archivo de 30 días.
  ///
  /// In es, this message translates to:
  /// **'Días anteriores'**
  String get archiveTitle;

  /// Explicación del archivo.
  ///
  /// In es, this message translates to:
  /// **'Puedes jugar los retos de los últimos 30 días. No suman a la racha, pero completan el calendario.'**
  String get archiveHint;

  /// Retos completados de un día del archivo.
  ///
  /// In es, this message translates to:
  /// **'{count} de 3'**
  String archiveMarks(int count);

  /// Día fuera de la ventana de 30 días.
  ///
  /// In es, this message translates to:
  /// **'Este día ya no está en el archivo.'**
  String get archiveOutside;

  /// Pestaña de estadísticas en Progreso.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get progressTabStats;

  /// Pestaña de logros en Progreso.
  ///
  /// In es, this message translates to:
  /// **'Logros'**
  String get progressTabAchievements;

  /// Título del estado vacío de Progreso.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay estadísticas'**
  String get progressEmptyTitle;

  /// Estado vacío de Progreso.
  ///
  /// In es, this message translates to:
  /// **'Tus estadísticas aparecerán al completar tu primer puzzle.'**
  String get progressEmpty;

  /// Botón del estado vacío: abre la pestaña Reto.
  ///
  /// In es, this message translates to:
  /// **'Ir al reto de hoy'**
  String get progressEmptyAction;

  /// Total: partidas ganadas en todos los juegos.
  ///
  /// In es, this message translates to:
  /// **'Puzzles completados'**
  String get progressCompleted;

  /// Total: tiempo de las partidas terminadas.
  ///
  /// In es, this message translates to:
  /// **'Tiempo total'**
  String get progressTotalTime;

  /// Total: racha actual del reto diario, en días.
  ///
  /// In es, this message translates to:
  /// **'Racha'**
  String get progressStreak;

  /// Mejor racha bajo la racha actual.
  ///
  /// In es, this message translates to:
  /// **'Mejor: {count}'**
  String progressStreakBest(int count);

  /// Total: días con los tres retos completos.
  ///
  /// In es, this message translates to:
  /// **'Días perfectos'**
  String get progressPerfectDays;

  /// Nombre del selector de juego de la tabla.
  ///
  /// In es, this message translates to:
  /// **'Juego'**
  String get progressGame;

  /// Encabezado de columna.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get progressColLevel;

  /// Encabezado de columna: partidas empezadas.
  ///
  /// In es, this message translates to:
  /// **'Partidas'**
  String get progressColPlayed;

  /// Encabezado de columna: partidas ganadas.
  ///
  /// In es, this message translates to:
  /// **'Ganadas'**
  String get progressColWon;

  /// Encabezado de columna: mejor tiempo.
  ///
  /// In es, this message translates to:
  /// **'Mejor'**
  String get progressColBest;

  /// Encabezado de columna: tiempo medio de las ganadas.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get progressColMean;

  /// Nivel sin partidas.
  ///
  /// In es, this message translates to:
  /// **'Aún sin jugar'**
  String get progressNotPlayed;

  /// Ganadas con su porcentaje (Buscaminas).
  ///
  /// In es, this message translates to:
  /// **'{won} ({rate})'**
  String progressWonRate(int won, String rate);

  /// Ayuda bajo la tabla.
  ///
  /// In es, this message translates to:
  /// **'Mantén pulsado un nivel para reiniciar sus estadísticas.'**
  String get progressTableHint;

  /// Acción al mantener pulsada una fila.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar estadísticas de este nivel'**
  String get progressResetLevel;

  /// Título de la confirmación.
  ///
  /// In es, this message translates to:
  /// **'¿Reiniciar {game} · {level}?'**
  String progressResetTitle(String game, String level);

  /// Explica qué se reinicia.
  ///
  /// In es, this message translates to:
  /// **'Partidas, mejor tiempo y media de este nivel vuelven a cero. Tu racha, el calendario y los logros no cambian.'**
  String get progressResetBody;

  /// Confirma el reinicio.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar'**
  String get progressResetConfirm;

  /// Aviso tras reiniciar.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas de {level} reiniciadas'**
  String progressResetDone(String level);

  /// Qué pide un logro, por su id estable.
  ///
  /// In es, this message translates to:
  /// **'{key, select, first_puzzle{Completa tu primer puzzle, en cualquier juego.} all_three_games{Completa al menos un puzzle de cada juego.} streak_3{Juega el reto diario 3 días seguidos.} streak_7{Juega el reto diario 7 días seguidos.} streak_30{Juega el reto diario 30 días seguidos.} streak_100{Juega el reto diario 100 días seguidos.} perfect_day{Completa los tres retos de un mismo día.} full_month{Juega el reto diario 20 días de un mismo mes.} ten_unassisted{Completa 10 puzzles sin pistas ni ayudas.} sudoku_first_hard{Completa un Sudoku en Difícil.} sudoku_first_expert{Completa un Sudoku en Experto.} sudoku_fast_medium{Completa un Sudoku Medio en menos de 6 minutos.} mines_first_expert{Gana un Buscaminas en Experto.} mines_five_in_a_row{Gana 5 partidas de Buscaminas seguidas, sin perder entre medio.} mines_no_flags{Gana un Buscaminas sin poner ninguna bandera.} words_ten_themes{Completa sopas de letras de 10 temas distintos.} words_expert_no_hints{Completa una sopa de letras en Experto sin usar pistas.} other{Completa 50 sopas de letras.}}'**
  String achievementDescription(String key);

  /// Estado de un logro conseguido.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueado'**
  String get achievementUnlocked;

  /// Fecha en que se consiguió un logro.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueado el {date}'**
  String achievementUnlockedOn(String date);

  /// Estado de un logro no conseguido.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get achievementLocked;

  /// Avance de un logro.
  ///
  /// In es, this message translates to:
  /// **'{progress} de {target}'**
  String achievementProgress(int progress, int target);

  /// Resumen sobre la grilla.
  ///
  /// In es, this message translates to:
  /// **'{unlocked} de {total} logros'**
  String achievementsCount(int unlocked, int total);

  /// Lector de pantalla: celda de tiempo vacía (—).
  ///
  /// In es, this message translates to:
  /// **'Sin tiempo'**
  String get progressNoTime;

  /// Sección de Ajustes.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get settingsGeneralSection;

  /// Grupo de opciones de tamaño de texto.
  ///
  /// In es, this message translates to:
  /// **'Tamaño del texto'**
  String get settingsTextSize;

  /// Tamaño de texto del sistema.
  ///
  /// In es, this message translates to:
  /// **'Como el sistema'**
  String get textSizeSystem;

  /// Texto un 15 % más grande que el del sistema.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get textSizeLarge;

  /// Texto un 30 % más grande que el del sistema.
  ///
  /// In es, this message translates to:
  /// **'Más grande'**
  String get textSizeLarger;

  /// Interruptor.
  ///
  /// In es, this message translates to:
  /// **'Reducir animaciones'**
  String get settingsReduceMotion;

  /// Descripción del interruptor.
  ///
  /// In es, this message translates to:
  /// **'Quita los efectos de movimiento aunque el sistema los tenga activos'**
  String get settingsReduceMotionHint;

  /// Interruptor.
  ///
  /// In es, this message translates to:
  /// **'Vibración'**
  String get settingsHaptics;

  /// Descripción del interruptor.
  ///
  /// In es, this message translates to:
  /// **'Al tocar, poner banderas y completar un puzzle'**
  String get settingsHapticsHint;

  /// Interruptor.
  ///
  /// In es, this message translates to:
  /// **'Mostrar el temporizador'**
  String get settingsShowTimer;

  /// Descripción del interruptor.
  ///
  /// In es, this message translates to:
  /// **'El tiempo se mide igual para tus estadísticas'**
  String get settingsShowTimerHint;

  /// Sección de Ajustes: ajustes de cada juego.
  ///
  /// In es, this message translates to:
  /// **'Juegos'**
  String get settingsGamesSection;

  /// Sección de Ajustes.
  ///
  /// In es, this message translates to:
  /// **'Datos y privacidad'**
  String get settingsDataSection;

  /// Fila: abre la elección del juego.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar estadísticas'**
  String get settingsResetStats;

  /// Subtítulo de la fila.
  ///
  /// In es, this message translates to:
  /// **'Tu racha, el calendario y los logros no cambian'**
  String get settingsResetStatsHint;

  /// Cuerpo de la hoja.
  ///
  /// In es, this message translates to:
  /// **'Las partidas jugadas, los mejores tiempos y las medias del juego que elijas vuelven a cero.'**
  String get settingsResetStatsBody;

  /// Botón por juego en la hoja.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar {game}'**
  String settingsResetStatsGame(String game);

  /// Aviso tras reiniciar.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas de {game} reiniciadas'**
  String settingsResetStatsDone(String game);

  /// Fila: abre la confirmación.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar todo el progreso'**
  String get settingsResetAll;

  /// Subtítulo de la fila.
  ///
  /// In es, this message translates to:
  /// **'Borra partidas, racha, calendario, logros y estadísticas'**
  String get settingsResetAllHint;

  /// Título de la confirmación.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar todo tu progreso?'**
  String get settingsResetAllTitle;

  /// Explica qué se borra.
  ///
  /// In es, this message translates to:
  /// **'Se borran tus partidas, la racha, el calendario, los logros y las estadísticas. Tus ajustes se conservan. No se puede deshacer.'**
  String get settingsResetAllBody;

  /// Palabra que hay que escribir para confirmar. En mayúsculas.
  ///
  /// In es, this message translates to:
  /// **'BORRAR'**
  String get settingsResetAllWord;

  /// Etiqueta del campo de confirmación.
  ///
  /// In es, this message translates to:
  /// **'Escribe {word} para confirmar'**
  String settingsResetAllPrompt(String word);

  /// Botón que borra el progreso.
  ///
  /// In es, this message translates to:
  /// **'Borrar todo'**
  String get settingsResetAllConfirm;

  /// Aviso tras borrar.
  ///
  /// In es, this message translates to:
  /// **'Se borró tu progreso'**
  String get settingsResetAllDone;

  /// Fila y título de la pantalla del contrato.
  ///
  /// In es, this message translates to:
  /// **'Contrato de anuncios'**
  String get settingsAdsContract;

  /// Introducción del contrato de anuncios.
  ///
  /// In es, this message translates to:
  /// **'Ludixa es gratis gracias a los anuncios. Estas reglas no cambian:'**
  String get adsContractIntro;

  /// Promesa 1.
  ///
  /// In es, this message translates to:
  /// **'Nunca verás un anuncio en mitad de una partida.'**
  String get adsPromiseMidGame;

  /// Promesa 2.
  ///
  /// In es, this message translates to:
  /// **'Nunca verás un anuncio al abrir la app.'**
  String get adsPromiseOnOpen;

  /// Promesa 3.
  ///
  /// In es, this message translates to:
  /// **'Los videos con recompensa son siempre opcionales y siempre te dan lo prometido.'**
  String get adsPromiseRewarded;

  /// Promesa 4.
  ///
  /// In es, this message translates to:
  /// **'Después de un video con recompensa nunca aparece otro anuncio.'**
  String get adsPromiseAfterVideo;

  /// Promesa 5.
  ///
  /// In es, this message translates to:
  /// **'Todos los juegos funcionan sin internet.'**
  String get adsPromiseOffline;

  /// Fila con la versión de la app.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get settingsVersion;

  /// Fila de Ajustes.
  ///
  /// In es, this message translates to:
  /// **'Exportar progreso'**
  String get backupExport;

  /// Subtítulo de la fila.
  ///
  /// In es, this message translates to:
  /// **'Guarda un archivo con tus partidas, racha y logros'**
  String get backupExportHint;

  /// Fila de Ajustes.
  ///
  /// In es, this message translates to:
  /// **'Importar progreso'**
  String get backupImport;

  /// Subtítulo de la fila.
  ///
  /// In es, this message translates to:
  /// **'Reemplaza tu progreso por el de un archivo exportado'**
  String get backupImportHint;

  /// Aviso tras guardar el archivo.
  ///
  /// In es, this message translates to:
  /// **'Progreso exportado'**
  String get backupExported;

  /// Error al guardar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el archivo. Prueba en otra carpeta.'**
  String get backupSaveFailed;

  /// Error al abrir.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el archivo.'**
  String get backupOpenFailed;

  /// Título de la confirmación.
  ///
  /// In es, this message translates to:
  /// **'¿Reemplazar tu progreso?'**
  String get backupImportTitle;

  /// Resumen del archivo antes de importar.
  ///
  /// In es, this message translates to:
  /// **'El respaldo del {date} tiene {sessions, plural, =1{1 partida} other{{sessions} partidas}} ({completed, plural, =1{1 completada} other{{completed} completadas}}) y una racha máxima de {best, plural, =1{1 día} other{{best} días}}. Reemplaza todo tu progreso actual; tus ajustes no cambian.'**
  String backupImportBody(String date, int sessions, int completed, int best);

  /// Confirma la importación.
  ///
  /// In es, this message translates to:
  /// **'Reemplazar'**
  String get backupImportConfirm;

  /// Aviso tras importar.
  ///
  /// In es, this message translates to:
  /// **'Progreso importado'**
  String get backupImported;

  /// Título del error al importar.
  ///
  /// In es, this message translates to:
  /// **'No se puede importar'**
  String get backupProblemTitle;

  /// Archivo que no es un respaldo.
  ///
  /// In es, this message translates to:
  /// **'Ese archivo no es un respaldo de Ludixa. Elige el archivo .json que exportaste desde Ajustes.'**
  String get backupNotLudixa;

  /// Respaldo de una versión más nueva.
  ///
  /// In es, this message translates to:
  /// **'Ese respaldo es de una versión más nueva de Ludixa. Actualiza la app para importarlo.'**
  String get backupNewerVersion;

  /// Respaldo dañado.
  ///
  /// In es, this message translates to:
  /// **'El respaldo está dañado o incompleto. No se cambió nada.'**
  String get backupCorrupt;

  /// Cierra el aviso de error.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get backupProblemOk;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'XA':
            return AppLocalizationsEnXa();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
