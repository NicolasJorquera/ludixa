import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'mines_localizations_en.dart';
import 'mines_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of MinesLocalizations
/// returned by `MinesLocalizations.of(context)`.
///
/// Applications need to include `MinesLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/mines_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: MinesLocalizations.localizationsDelegates,
///   supportedLocales: MinesLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the MinesLocalizations.supportedLocales
/// property.
abstract class MinesLocalizations {
  MinesLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static MinesLocalizations of(BuildContext context) {
    return Localizations.of<MinesLocalizations>(context, MinesLocalizations)!;
  }

  static const LocalizationsDelegate<MinesLocalizations> delegate = _MinesLocalizationsDelegate();

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
  /// **'Buscaminas'**
  String get gameName;

  /// Dificultad.
  ///
  /// In es, this message translates to:
  /// **'Principiante'**
  String get levelBeginner;

  /// Dificultad.
  ///
  /// In es, this message translates to:
  /// **'Intermedio'**
  String get levelIntermediate;

  /// Dificultad.
  ///
  /// In es, this message translates to:
  /// **'Experto'**
  String get levelExpert;

  /// Nivel del tablero reducido del reto diario (12×12).
  ///
  /// In es, this message translates to:
  /// **'Reto'**
  String get levelDaily;

  /// Hoja de dificultad.
  ///
  /// In es, this message translates to:
  /// **'9×9 · 10 minas · cabe sin zoom'**
  String get levelBeginnerDescription;

  /// Hoja de dificultad.
  ///
  /// In es, this message translates to:
  /// **'16×16 · 40 minas · zoom opcional'**
  String get levelIntermediateDescription;

  /// Hoja de dificultad.
  ///
  /// In es, this message translates to:
  /// **'16×30 · 99 minas · con zoom'**
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

  /// Contador de minas restantes (minas menos banderas).
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Queda 1 mina} other{Quedan {count} minas}}'**
  String minesLeft(int count);

  /// Modo de toque: revelar.
  ///
  /// In es, this message translates to:
  /// **'Revelar'**
  String get modeReveal;

  /// Modo de toque: poner bandera.
  ///
  /// In es, this message translates to:
  /// **'Bandera'**
  String get modeFlag;

  /// Herramienta deshacer.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get undo;

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
  /// **'Sin más pistas en este tablero'**
  String get noMoreHints;

  /// Botón de zoom (acercar).
  ///
  /// In es, this message translates to:
  /// **'Acercar'**
  String get zoomIn;

  /// Botón de zoom (alejar).
  ///
  /// In es, this message translates to:
  /// **'Ajustar al ancho'**
  String get zoomOut;

  /// Antes del primer toque.
  ///
  /// In es, this message translates to:
  /// **'Toca cualquier celda para empezar'**
  String get tapToStart;

  /// Reto diario: celda de inicio señalada.
  ///
  /// In es, this message translates to:
  /// **'Empieza aquí: la celda marcada abre una zona'**
  String get startHere;

  /// Mientras se genera el tablero tras el primer toque.
  ///
  /// In es, this message translates to:
  /// **'Preparando el tablero'**
  String get generating;

  /// Ayuda de las primeras partidas.
  ///
  /// In es, this message translates to:
  /// **'Mantén pulsada una celda para {action}'**
  String longPressTip(String action);

  /// Acción de la pulsación larga.
  ///
  /// In es, this message translates to:
  /// **'poner bandera'**
  String get longPressTipFlag;

  /// Acción de la pulsación larga.
  ///
  /// In es, this message translates to:
  /// **'revelarla'**
  String get longPressTipReveal;

  /// Etiqueta accesible del tablero.
  ///
  /// In es, this message translates to:
  /// **'Tablero de Buscaminas, {columns} por {rows}'**
  String boardLabel(int columns, int rows);

  /// Etiqueta de una celda.
  ///
  /// In es, this message translates to:
  /// **'Fila {row}, columna {column}, {content}'**
  String cellLabel(int row, int column, String content);

  /// Celda sin revelar.
  ///
  /// In es, this message translates to:
  /// **'cerrada'**
  String get cellHidden;

  /// Celda con bandera.
  ///
  /// In es, this message translates to:
  /// **'con bandera'**
  String get cellFlagged;

  /// Celda revelada sin minas vecinas.
  ///
  /// In es, this message translates to:
  /// **'vacía'**
  String get cellEmpty;

  /// Celda revelada con número.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 mina vecina} other{{count} minas vecinas}}'**
  String cellNumber(int count);

  /// Tras perder: mina.
  ///
  /// In es, this message translates to:
  /// **'mina'**
  String get cellMine;

  /// Tras perder: mina fatal.
  ///
  /// In es, this message translates to:
  /// **'mina que terminó la partida'**
  String get cellFatal;

  /// Tras perder: bandera sin mina.
  ///
  /// In es, this message translates to:
  /// **'bandera equivocada'**
  String get cellWrongFlag;

  /// Celda de inicio del reto diario.
  ///
  /// In es, this message translates to:
  /// **'inicio sugerido'**
  String get cellStart;

  /// Celda de la pista.
  ///
  /// In es, this message translates to:
  /// **'señalada por la pista'**
  String get cellHint;

  /// Acción alternativa en TalkBack.
  ///
  /// In es, this message translates to:
  /// **'Poner o quitar bandera'**
  String get altActionFlag;

  /// Acción alternativa en TalkBack.
  ///
  /// In es, this message translates to:
  /// **'Revelar'**
  String get altActionReveal;

  /// Anuncio al ganar.
  ///
  /// In es, this message translates to:
  /// **'¡Despejado!'**
  String get won;

  /// Título neutro de la derrota.
  ///
  /// In es, this message translates to:
  /// **'Esta vez explotó una mina'**
  String get lostTitle;

  /// Se anuncia la mina fatal.
  ///
  /// In es, this message translates to:
  /// **'La mina estaba en la fila {row}, columna {column}.'**
  String lostWhere(int row, int column);

  /// Derrota: mismas minas desde cero.
  ///
  /// In es, this message translates to:
  /// **'Reintentar este tablero'**
  String get retryBoard;

  /// Derrota: otro tablero.
  ///
  /// In es, this message translates to:
  /// **'Tablero nuevo'**
  String get newBoard;

  /// Derrota: rescate opcional.
  ///
  /// In es, this message translates to:
  /// **'Deshacer el último toque con un video'**
  String get rescue;

  /// Regla del rescate.
  ///
  /// In es, this message translates to:
  /// **'Una vez por partida. El video es opcional.'**
  String get rescueRule;

  /// Rescate sin inventario o sin conexión.
  ///
  /// In es, this message translates to:
  /// **'Ahora no hay videos disponibles.'**
  String get rescueUnavailable;

  /// Baja la hoja de derrota para revisar el tablero.
  ///
  /// In es, this message translates to:
  /// **'Ver el tablero'**
  String get showBoard;

  /// Vuelve a subir la hoja de derrota.
  ///
  /// In es, this message translates to:
  /// **'Ver opciones'**
  String get showOptions;

  /// Encabezado del panel de pista.
  ///
  /// In es, this message translates to:
  /// **'Pista'**
  String get hintTitle;

  /// Pista: celda segura.
  ///
  /// In es, this message translates to:
  /// **'La celda marcada es segura.'**
  String get hintSafe;

  /// Pista: mina.
  ///
  /// In es, this message translates to:
  /// **'La celda marcada es una mina.'**
  String get hintMine;

  /// Pista: bandera equivocada.
  ///
  /// In es, this message translates to:
  /// **'Esta bandera no tiene mina debajo.'**
  String get hintWrongFlag;

  /// Explicación de la pista según el motivo.
  ///
  /// In es, this message translates to:
  /// **'{reason, select, numberSatisfied{Este número ya tiene todas sus minas marcadas: el resto de sus vecinas son seguras.} numberNeedsAll{A este número le faltan tantas minas como vecinas cerradas tiene: todas son minas.} twoNumbers{Comparando estos dos números vecinos se deduce la celda.} mineCount{Por el conteo de minas que quedan.} wrongFlag{Quítala: la celda es segura.} other{No hay una deducción simple desde aquí: te mostramos una celda segura.}}'**
  String hintReason(String reason);

  /// Cierra la pista.
  ///
  /// In es, this message translates to:
  /// **'Lo intento yo'**
  String get hintTryMyself;

  /// Aplica la pista: revelar.
  ///
  /// In es, this message translates to:
  /// **'Revelarla'**
  String get hintApplyReveal;

  /// Aplica la pista: bandera.
  ///
  /// In es, this message translates to:
  /// **'Ponerle bandera'**
  String get hintApplyFlag;

  /// Aplica la pista: quitar bandera.
  ///
  /// In es, this message translates to:
  /// **'Quitar la bandera'**
  String get hintApplyUnflag;

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
  /// **'Un número dice cuántas minas tiene entre sus 8 vecinas.'**
  String get tutorialRuleNumber;

  /// Tarea del paso 1.
  ///
  /// In es, this message translates to:
  /// **'Este 1 ya tiene su mina marcada. Toca otra vecina: es segura.'**
  String get tutorialTaskNumber;

  /// Regla del paso 2.
  ///
  /// In es, this message translates to:
  /// **'Si un número tiene tantas vecinas cerradas como minas, todas son minas.'**
  String get tutorialRuleFlag;

  /// Tarea del paso 2.
  ///
  /// In es, this message translates to:
  /// **'Ponle bandera a la mina: mantén pulsada la celda o usa el modo Bandera.'**
  String get tutorialTaskFlag;

  /// Regla del paso 3.
  ///
  /// In es, this message translates to:
  /// **'Si un número ya tiene todas sus banderas, tocarlo abre sus otras vecinas.'**
  String get tutorialRuleChord;

  /// Tarea del paso 3.
  ///
  /// In es, this message translates to:
  /// **'Toca el 1 para abrir de una vez todas sus vecinas.'**
  String get tutorialTaskChord;

  /// Error explicado, sin castigo.
  ///
  /// In es, this message translates to:
  /// **'Esa celda tiene la bandera del 1: ahí está su mina.'**
  String get tutorialWrongFlagged;

  /// Error explicado, sin castigo.
  ///
  /// In es, this message translates to:
  /// **'Cuidado: ahí está la mina. Márcala con bandera.'**
  String get tutorialWrongMine;

  /// Pista amable en el paso 3.
  ///
  /// In es, this message translates to:
  /// **'También vale, pero tocar el 1 las abre todas de una vez.'**
  String get tutorialWrongChord;

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
  /// **'Tablero de práctica de 5 por 5'**
  String get tutorialBoardLabel;

  /// Ajuste: acción del toque.
  ///
  /// In es, this message translates to:
  /// **'Al tocar una celda'**
  String get settingsTapMode;

  /// Ayuda del ajuste del toque.
  ///
  /// In es, this message translates to:
  /// **'La pulsación larga hace lo contrario.'**
  String get settingsTapModeHelp;

  /// Ajuste de duración.
  ///
  /// In es, this message translates to:
  /// **'Duración de la pulsación larga'**
  String get settingsLongPress;

  /// Duración corta.
  ///
  /// In es, this message translates to:
  /// **'Corta'**
  String get settingsLongPressShort;

  /// Duración normal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get settingsLongPressNormal;

  /// Duración larga.
  ///
  /// In es, this message translates to:
  /// **'Larga'**
  String get settingsLongPressLong;

  /// Ajuste chord.
  ///
  /// In es, this message translates to:
  /// **'Abrir vecinas tocando un número'**
  String get settingsChord;

  /// Ayuda del ajuste chord.
  ///
  /// In es, this message translates to:
  /// **'Solo si el número ya tiene todas sus banderas.'**
  String get settingsChordHelp;

  /// Abre el tutorial.
  ///
  /// In es, this message translates to:
  /// **'Cómo se juega'**
  String get settingsTutorial;
}

class _MinesLocalizationsDelegate extends LocalizationsDelegate<MinesLocalizations> {
  const _MinesLocalizationsDelegate();

  @override
  Future<MinesLocalizations> load(Locale locale) {
    return SynchronousFuture<MinesLocalizations>(lookupMinesLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_MinesLocalizationsDelegate old) => false;
}

MinesLocalizations lookupMinesLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return MinesLocalizationsEn();
    case 'es':
      return MinesLocalizationsEs();
  }

  throw FlutterError(
    'MinesLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
