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

  /// Encabezado de la hoja de pista.
  ///
  /// In es, this message translates to:
  /// **'Pista · paso {step} de 3'**
  String hintStep(int step);

  /// Paso 1: señala la zona.
  ///
  /// In es, this message translates to:
  /// **'Hay una deducción en {zone}.'**
  String hintZone(String zone);

  /// Paso 1: ayuda breve.
  ///
  /// In es, this message translates to:
  /// **'Mira dónde puede ir cada número en esa zona.'**
  String get hintZoneDetail;

  /// Paso 3: coloca el número.
  ///
  /// In es, this message translates to:
  /// **'Va un {digit} en la fila {row}, columna {column}.'**
  String hintNumber(int digit, int row, int column);

  /// Cuando la técnica no está implementada y se revela la celda.
  ///
  /// In es, this message translates to:
  /// **'Esta celda se resuelve con una técnica que aún no explicamos.'**
  String get hintNumberRevealed;

  /// Pista que señala un error del jugador.
  ///
  /// In es, this message translates to:
  /// **'Hay un número que no corresponde'**
  String get hintErrorTitle;

  /// Detalle de la pista de error.
  ///
  /// In es, this message translates to:
  /// **'Revisa la fila {row}, columna {column}. Puedes corregirlo tú o borrarlo.'**
  String hintErrorDetail(int row, int column);

  /// Cierra la pista sin avanzar.
  ///
  /// In es, this message translates to:
  /// **'Lo intento yo'**
  String get hintTryMyself;

  /// Avanza del paso 1 al 2.
  ///
  /// In es, this message translates to:
  /// **'Ver la técnica'**
  String get hintNextStep;

  /// Avanza del paso 2 al 3.
  ///
  /// In es, this message translates to:
  /// **'Mostrar el número'**
  String get hintShowNumber;

  /// Borra el número equivocado.
  ///
  /// In es, this message translates to:
  /// **'Borrar el número'**
  String get hintEraseError;

  /// Cierra la pista al terminar.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get hintDone;

  /// Zona: una fila.
  ///
  /// In es, this message translates to:
  /// **'la fila {n}'**
  String zoneRow(int n);

  /// Zona: una columna.
  ///
  /// In es, this message translates to:
  /// **'la columna {n}'**
  String zoneColumn(int n);

  /// Zona: una caja, por posición (0 arriba a la izquierda, 8 abajo a la derecha).
  ///
  /// In es, this message translates to:
  /// **'{index, select, 0{la caja superior izquierda} 1{la caja superior central} 2{la caja superior derecha} 3{la caja central izquierda} 4{la caja central} 5{la caja central derecha} 6{la caja inferior izquierda} 7{la caja inferior central} other{la caja inferior derecha}}'**
  String zoneBox(String index);

  /// Dos zonas.
  ///
  /// In es, this message translates to:
  /// **'{a} y {b}'**
  String zoneTwo(String a, String b);

  /// Tres zonas.
  ///
  /// In es, this message translates to:
  /// **'{a}, {b} y {c}'**
  String zoneThree(String a, String b, String c);

  /// Nombre de la técnica, por id interno.
  ///
  /// In es, this message translates to:
  /// **'{technique, select, nakedSingle{Único candidato} hiddenSingle{Único lugar} pointing{Intersección en la caja} claiming{Intersección en la línea} nakedPair{Par desnudo} hiddenPair{Par oculto} nakedTriple{Trío desnudo} hiddenTriple{Trío oculto} xWing{X-Wing} xyWing{XY-Wing} other{Swordfish}}'**
  String techniqueName(String technique);

  /// Explicación de 1 o 2 líneas de la técnica.
  ///
  /// In es, this message translates to:
  /// **'{technique, select, nakedSingle{A esta celda solo le queda un número posible: los demás ya están en su fila, columna o caja.} hiddenSingle{En esta zona, ese número solo cabe en una celda.} pointing{Dentro de la caja, el número solo puede ir en una línea; se descarta del resto de esa fila o columna.} claiming{En la fila o columna, el número solo cabe dentro de una caja; se descarta del resto de la caja.} nakedPair{Dos celdas comparten los mismos dos candidatos; esos números se descartan del resto de la zona.} hiddenPair{Dos números solo caben en las mismas dos celdas; ahí se descartan los demás candidatos.} nakedTriple{Tres celdas reparten entre sí los mismos tres candidatos; se descartan del resto de la zona.} hiddenTriple{Tres números solo caben en las mismas tres celdas; ahí se descartan los demás candidatos.} xWing{Un número forma un rectángulo en dos filas y dos columnas; se descarta del resto de esas columnas.} xyWing{Tres celdas de dos candidatos forman una pinza: el número que comparten las puntas se descarta donde ambas lo ven.} other{Como el X-Wing, pero con tres filas y tres columnas.}}'**
  String techniqueExplanation(String technique);

  /// Botón siempre visible para salir del tutorial.
  ///
  /// In es, this message translates to:
  /// **'Saltar tutorial'**
  String get tutorialSkip;

  /// Indicador de pasos del tutorial.
  ///
  /// In es, this message translates to:
  /// **'Paso {step} de 3'**
  String tutorialStep(int step);

  /// Regla del paso 1 (tablero de 4×4: números del 1 al 4).
  ///
  /// In es, this message translates to:
  /// **'Cada fila tiene todos los números, sin repetir.'**
  String get tutorialRuleRow;

  /// Regla del paso 2.
  ///
  /// In es, this message translates to:
  /// **'Cada columna también.'**
  String get tutorialRuleColumn;

  /// Regla del paso 3.
  ///
  /// In es, this message translates to:
  /// **'Y cada caja.'**
  String get tutorialRuleBox;

  /// Pregunta del tutorial.
  ///
  /// In es, this message translates to:
  /// **'¿Qué número va en la celda marcada?'**
  String get tutorialAsk;

  /// Error explicado, sin castigo.
  ///
  /// In es, this message translates to:
  /// **'El {digit} ya está en esta fila. Prueba con otro.'**
  String tutorialWrongRow(int digit);

  /// Error explicado, sin castigo.
  ///
  /// In es, this message translates to:
  /// **'El {digit} ya está en esta columna. Prueba con otro.'**
  String tutorialWrongColumn(int digit);

  /// Error explicado, sin castigo.
  ///
  /// In es, this message translates to:
  /// **'El {digit} ya está en esta caja. Prueba con otro.'**
  String tutorialWrongBox(int digit);

  /// Respuesta correcta.
  ///
  /// In es, this message translates to:
  /// **'¡Bien! El {digit} es el único que falta.'**
  String tutorialRight(int digit);

  /// Avanza al siguiente paso.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get tutorialNext;

  /// Cierra el tutorial al final.
  ///
  /// In es, this message translates to:
  /// **'Empezar a jugar'**
  String get tutorialStart;

  /// Etiqueta accesible del tablero del tutorial.
  ///
  /// In es, this message translates to:
  /// **'Tablero de práctica de 4 por 4'**
  String get tutorialBoardLabel;

  /// Título del ajuste de entrada.
  ///
  /// In es, this message translates to:
  /// **'Forma de ingresar números'**
  String get settingsInput;

  /// Opción: tocar celda y luego número.
  ///
  /// In es, this message translates to:
  /// **'Celda primero'**
  String get settingsInputCellFirst;

  /// Opción: elegir número y luego celdas.
  ///
  /// In es, this message translates to:
  /// **'Número primero'**
  String get settingsInputNumberFirst;

  /// Título del ajuste de errores.
  ///
  /// In es, this message translates to:
  /// **'Errores'**
  String get settingsErrors;

  /// Opción: marcar solo conflictos de regla.
  ///
  /// In es, this message translates to:
  /// **'Números repetidos'**
  String get settingsErrorsConflicts;

  /// Opción: marcar números que no coinciden con la solución.
  ///
  /// In es, this message translates to:
  /// **'Contra la solución'**
  String get settingsErrorsSolution;

  /// Opción: no marcar errores.
  ///
  /// In es, this message translates to:
  /// **'Sin indicación'**
  String get settingsErrorsNone;

  /// Ayuda bajo el ajuste de errores.
  ///
  /// In es, this message translates to:
  /// **'No hay límite de errores: solo cambia cómo se señalan.'**
  String get settingsErrorsHelp;

  /// Ajuste: borra el candidato en la fila, columna y caja.
  ///
  /// In es, this message translates to:
  /// **'Borrar notas al colocar un número'**
  String get settingsRemoveNotes;

  /// Ajuste: resaltar todas las apariciones.
  ///
  /// In es, this message translates to:
  /// **'Resaltar el mismo número'**
  String get settingsHighlightSame;

  /// Abre el tutorial.
  ///
  /// In es, this message translates to:
  /// **'Cómo se juega'**
  String get settingsTutorial;
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
