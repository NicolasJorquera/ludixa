import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'words_localizations_en.dart';
import 'words_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of WordsLocalizations
/// returned by `WordsLocalizations.of(context)`.
///
/// Applications need to include `WordsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/words_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: WordsLocalizations.localizationsDelegates,
///   supportedLocales: WordsLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the WordsLocalizations.supportedLocales
/// property.
abstract class WordsLocalizations {
  WordsLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static WordsLocalizations of(BuildContext context) {
    return Localizations.of<WordsLocalizations>(context, WordsLocalizations)!;
  }

  static const LocalizationsDelegate<WordsLocalizations> delegate = _WordsLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('es')];

  /// Nombre del juego.
  ///
  /// In es, this message translates to:
  /// **'Sopa de letras'**
  String get gameName;

  /// Dificultad.
  ///
  /// In es, this message translates to:
  /// **'Fácil'**
  String get levelEasy;

  /// Dificultad.
  ///
  /// In es, this message translates to:
  /// **'Medio'**
  String get levelMedium;

  /// Dificultad.
  ///
  /// In es, this message translates to:
  /// **'Difícil'**
  String get levelHard;

  /// Dificultad.
  ///
  /// In es, this message translates to:
  /// **'Experto'**
  String get levelExpert;

  /// Hoja de dificultad.
  ///
  /// In es, this message translates to:
  /// **'8×8 · 6 palabras · derecha y abajo'**
  String get levelEasyDescription;

  /// Hoja de dificultad.
  ///
  /// In es, this message translates to:
  /// **'10×10 · 9 palabras · también en diagonal'**
  String get levelMediumDescription;

  /// Hoja de dificultad.
  ///
  /// In es, this message translates to:
  /// **'12×12 · 12 palabras · en las 8 direcciones'**
  String get levelHardDescription;

  /// Hoja de dificultad.
  ///
  /// In es, this message translates to:
  /// **'14×14 · 15 palabras · con señuelos'**
  String get levelExpertDescription;

  /// Salir de la partida.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// Pausar.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get pause;

  /// Reanudar.
  ///
  /// In es, this message translates to:
  /// **'Reanudar'**
  String get resume;

  /// Tablero oculto en pausa.
  ///
  /// In es, this message translates to:
  /// **'Tablero oculto en pausa'**
  String get pausedBoard;

  /// Etiqueta accesible del temporizador.
  ///
  /// In es, this message translates to:
  /// **'Tiempo {time}'**
  String elapsed(String time);

  /// Contador de palabras encontradas.
  ///
  /// In es, this message translates to:
  /// **'{found} de {total}'**
  String wordsCount(int found, int total);

  /// Etiqueta accesible del contador.
  ///
  /// In es, this message translates to:
  /// **'{found} de {total} palabras encontradas'**
  String wordsCountLabel(int found, int total);

  /// Despliega la lista en pantallas bajas.
  ///
  /// In es, this message translates to:
  /// **'Ver palabras'**
  String get wordsShow;

  /// Pliega la lista.
  ///
  /// In es, this message translates to:
  /// **'Ocultar palabras'**
  String get wordsHide;

  /// Palabra de la lista ya encontrada.
  ///
  /// In es, this message translates to:
  /// **'{word}, encontrada'**
  String wordFound(String word);

  /// Palabra de la lista pendiente.
  ///
  /// In es, this message translates to:
  /// **'{word}, por encontrar'**
  String wordPending(String word);

  /// Anuncio al encontrar una palabra.
  ///
  /// In es, this message translates to:
  /// **'Encontraste {word}'**
  String announceFound(String word);

  /// Anuncio al terminar.
  ///
  /// In es, this message translates to:
  /// **'¡Encontraste todas las palabras!'**
  String get announceAll;

  /// Herramienta pista.
  ///
  /// In es, this message translates to:
  /// **'Pista'**
  String get hint;

  /// Pistas gratis restantes.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{sin pistas gratis} =1{queda 1 gratis} other{quedan {count} gratis}}'**
  String hintsLeft(int count);

  /// Botón pista desactivado.
  ///
  /// In es, this message translates to:
  /// **'Sin más pistas en esta sopa'**
  String get noMoreHints;

  /// Anuncio de la pista.
  ///
  /// In es, this message translates to:
  /// **'Una palabra empieza en la fila {row}, columna {column}'**
  String hintAnnounce(int row, int column);

  /// Botón de zoom.
  ///
  /// In es, this message translates to:
  /// **'Acercar'**
  String get zoomIn;

  /// Botón de zoom.
  ///
  /// In es, this message translates to:
  /// **'Ajustar al ancho'**
  String get zoomOut;

  /// Modo de toque: esperando la primera letra.
  ///
  /// In es, this message translates to:
  /// **'Toca la letra inicial'**
  String get tapModeStart;

  /// Modo de toque: esperando la última letra.
  ///
  /// In es, this message translates to:
  /// **'Ahora toca la letra final'**
  String get tapModeEnd;

  /// Etiqueta accesible de la grilla.
  ///
  /// In es, this message translates to:
  /// **'Sopa de letras, {size} por {size}'**
  String boardLabel(int size);

  /// Etiqueta de una celda. state empieza con coma o está vacío.
  ///
  /// In es, this message translates to:
  /// **'Fila {row}, columna {column}, {letter}{state}'**
  String cellLabel(int row, int column, String letter, String state);

  /// Estado de la celda.
  ///
  /// In es, this message translates to:
  /// **', en una palabra encontrada'**
  String get cellInWord;

  /// Estado de la celda.
  ///
  /// In es, this message translates to:
  /// **', seleccionada'**
  String get cellSelected;

  /// Estado de la celda.
  ///
  /// In es, this message translates to:
  /// **', inicio de una palabra (pista)'**
  String get cellHint;

  /// Siempre visible.
  ///
  /// In es, this message translates to:
  /// **'Saltar tutorial'**
  String get tutorialSkip;

  /// Indicador de pasos.
  ///
  /// In es, this message translates to:
  /// **'Paso {step} de 3'**
  String tutorialStep(int step);

  /// Regla del paso 1.
  ///
  /// In es, this message translates to:
  /// **'Arrastra el dedo sobre las letras de una palabra.'**
  String get tutorialRuleDrag;

  /// Tarea del paso 1 (palabra de 3 letras).
  ///
  /// In es, this message translates to:
  /// **'Encuentra SOL, de izquierda a derecha.'**
  String get tutorialTaskDrag;

  /// Regla del paso 2.
  ///
  /// In es, this message translates to:
  /// **'Las palabras van en recta: también en diagonal o al revés.'**
  String get tutorialRuleDirections;

  /// Tarea del paso 2.
  ///
  /// In es, this message translates to:
  /// **'Encuentra MAR: está en diagonal.'**
  String get tutorialTaskDirections;

  /// Regla del paso 3.
  ///
  /// In es, this message translates to:
  /// **'La lista dice qué falta. Las encontradas se tachan.'**
  String get tutorialRuleList;

  /// Tarea del paso 3.
  ///
  /// In es, this message translates to:
  /// **'Encuentra la palabra que falta en la lista.'**
  String get tutorialTaskList;

  /// Error explicado, sin castigo.
  ///
  /// In es, this message translates to:
  /// **'Esa no es la palabra. Prueba de nuevo: no pasa nada.'**
  String get tutorialWrong;

  /// Respuesta correcta.
  ///
  /// In es, this message translates to:
  /// **'¡Bien hecho!'**
  String get tutorialRight;

  /// Siguiente paso.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get tutorialNext;

  /// Termina el tutorial.
  ///
  /// In es, this message translates to:
  /// **'Empezar a jugar'**
  String get tutorialStart;

  /// Etiqueta del tablero del tutorial.
  ///
  /// In es, this message translates to:
  /// **'Sopa de práctica de 6 por 6'**
  String get tutorialBoardLabel;

  /// Ajuste de selección.
  ///
  /// In es, this message translates to:
  /// **'Cómo se seleccionan las palabras'**
  String get settingsSelection;

  /// Opción: arrastrar.
  ///
  /// In es, this message translates to:
  /// **'Arrastrar'**
  String get settingsSelectionDrag;

  /// Opción: tocar primera y última letra.
  ///
  /// In es, this message translates to:
  /// **'Tocar inicio y final'**
  String get settingsSelectionTap;

  /// Ayuda del ajuste.
  ///
  /// In es, this message translates to:
  /// **'Con TalkBack se usa siempre tocar inicio y final.'**
  String get settingsSelectionHelp;

  /// Ajuste de idioma de la sopa.
  ///
  /// In es, this message translates to:
  /// **'Idioma de las palabras'**
  String get settingsLanguage;

  /// Opción: seguir el idioma de la app.
  ///
  /// In es, this message translates to:
  /// **'El de la app'**
  String get settingsLanguageApp;

  /// Opción.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// Opción.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get settingsLanguageEnglish;

  /// Abre el tutorial.
  ///
  /// In es, this message translates to:
  /// **'Cómo se juega'**
  String get settingsTutorial;
}

class _WordsLocalizationsDelegate extends LocalizationsDelegate<WordsLocalizations> {
  const _WordsLocalizationsDelegate();

  @override
  Future<WordsLocalizations> load(Locale locale) {
    return SynchronousFuture<WordsLocalizations>(lookupWordsLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_WordsLocalizationsDelegate old) => false;
}

WordsLocalizations lookupWordsLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return WordsLocalizationsEn();
    case 'es':
      return WordsLocalizationsEs();
  }

  throw FlutterError(
    'WordsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
