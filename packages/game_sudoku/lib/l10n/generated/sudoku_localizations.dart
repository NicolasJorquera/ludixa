import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'sudoku_localizations_en.dart';
import 'sudoku_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SudokuLocalizations
/// returned by `SudokuLocalizations.of(context)`.
///
/// Applications need to include `SudokuLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/sudoku_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SudokuLocalizations.localizationsDelegates,
///   supportedLocales: SudokuLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the SudokuLocalizations.supportedLocales
/// property.
abstract class SudokuLocalizations {
  SudokuLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SudokuLocalizations of(BuildContext context) {
    return Localizations.of<SudokuLocalizations>(context, SudokuLocalizations)!;
  }

  static const LocalizationsDelegate<SudokuLocalizations> delegate = _SudokuLocalizationsDelegate();

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
  /// **'Sudoku'**
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

  /// Tiempo estimado y técnica del nivel, en la hoja de dificultad.
  ///
  /// In es, this message translates to:
  /// **'3–6 min · el último número posible'**
  String get levelEasyDescription;

  /// Tiempo estimado y técnica del nivel.
  ///
  /// In es, this message translates to:
  /// **'6–12 min · intersecciones caja-línea'**
  String get levelMediumDescription;

  /// Tiempo estimado y técnica del nivel.
  ///
  /// In es, this message translates to:
  /// **'12–20 min · pares y tríos'**
  String get levelHardDescription;

  /// Tiempo estimado y técnica del nivel.
  ///
  /// In es, this message translates to:
  /// **'20–40 min · X-Wing y otras cadenas'**
  String get levelExpertDescription;

  /// Título de la partida: nivel y porcentaje de celdas llenas.
  ///
  /// In es, this message translates to:
  /// **'{level} · {percent} %'**
  String topBarProgress(String level, int percent);

  /// Botón para salir de la partida.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// Botón para pausar.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get pause;

  /// Botón para reanudar desde la pausa.
  ///
  /// In es, this message translates to:
  /// **'Reanudar'**
  String get resume;

  /// Texto sobre el tablero oculto mientras la partida está en pausa.
  ///
  /// In es, this message translates to:
  /// **'Tablero oculto en pausa'**
  String get pausedBoard;

  /// Etiqueta accesible del temporizador.
  ///
  /// In es, this message translates to:
  /// **'Tiempo {time}'**
  String elapsed(String time);

  /// Herramienta: deshacer el último cambio.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get undo;

  /// Herramienta: borrar la celda.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get erase;

  /// Herramienta: alternar el modo de notas.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get notes;

  /// Estado del modo de notas para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'{on, select, true{activadas} other{desactivadas}}'**
  String notesState(String on);

  /// Herramienta: pedir una pista.
  ///
  /// In es, this message translates to:
  /// **'Pista'**
  String get hint;

  /// Pistas gratis que quedan, para el lector de pantalla.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{sin pistas gratis} =1{queda 1 gratis} other{quedan {count} gratis}}'**
  String hintsLeft(int count);

  /// Explicación cuando el botón de pista queda desactivado.
  ///
  /// In es, this message translates to:
  /// **'Sin más pistas en este puzzle'**
  String get noMoreHints;

  /// Etiqueta accesible de una tecla del teclado numérico.
  ///
  /// In es, this message translates to:
  /// **'{digit}, {remaining, plural, =0{completo} =1{queda 1} other{quedan {remaining}}}'**
  String keyRemaining(int digit, int remaining);

  /// Etiqueta accesible de la grilla completa.
  ///
  /// In es, this message translates to:
  /// **'Tablero de Sudoku, 9 por 9'**
  String get boardLabel;

  /// Etiqueta accesible de una celda. content es el contenido ya descrito.
  ///
  /// In es, this message translates to:
  /// **'Fila {row}, columna {column}, {content}'**
  String cellLabel(int row, int column, String content);

  /// Contenido de una celda vacía.
  ///
  /// In es, this message translates to:
  /// **'vacía'**
  String get cellEmpty;

  /// Contenido de una celda con un número inicial.
  ///
  /// In es, this message translates to:
  /// **'{digit}, fijo'**
  String cellGiven(int digit);

  /// Notas de una celda vacía, por ejemplo 'notas 1, 5, 9'.
  ///
  /// In es, this message translates to:
  /// **'notas {digits}'**
  String cellNotes(String digits);

  /// Estado de una celda con un número repetido o incorrecto.
  ///
  /// In es, this message translates to:
  /// **'en conflicto'**
  String get cellConflict;

  /// Estado de la celda seleccionada.
  ///
  /// In es, this message translates to:
  /// **'seleccionada'**
  String get cellSelected;

  /// Anuncio al resolver el puzzle.
  ///
  /// In es, this message translates to:
  /// **'¡Resuelto!'**
  String get solved;

  /// Mientras se genera el puzzle.
  ///
  /// In es, this message translates to:
  /// **'Preparando el puzzle'**
  String get preparing;
}

class _SudokuLocalizationsDelegate extends LocalizationsDelegate<SudokuLocalizations> {
  const _SudokuLocalizationsDelegate();

  @override
  Future<SudokuLocalizations> load(Locale locale) {
    return SynchronousFuture<SudokuLocalizations>(lookupSudokuLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SudokuLocalizationsDelegate old) => false;
}

SudokuLocalizations lookupSudokuLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SudokuLocalizationsEn();
    case 'es':
      return SudokuLocalizationsEs();
  }

  throw FlutterError(
    'SudokuLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
