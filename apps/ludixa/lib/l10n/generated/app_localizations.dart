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

  /// Aviso provisional en pantallas que aún no están construidas.
  ///
  /// In es, this message translates to:
  /// **'Esta pantalla llega en una próxima versión de desarrollo.'**
  String get comingSoon;

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

  /// Marca del nivel recordado.
  ///
  /// In es, this message translates to:
  /// **'La última que jugaste'**
  String get difficultyLast;

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
