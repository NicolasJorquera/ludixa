// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mines_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class MinesLocalizationsEs extends MinesLocalizations {
  MinesLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get gameName => 'Buscaminas';

  @override
  String get levelBeginner => 'Principiante';

  @override
  String get levelIntermediate => 'Intermedio';

  @override
  String get levelExpert => 'Experto';

  @override
  String get levelDaily => 'Intermedio reducido';

  @override
  String get levelBeginnerDescription => '9×9 · 10 minas · cabe sin zoom';

  @override
  String get levelIntermediateDescription => '16×16 · 40 minas · zoom opcional';

  @override
  String get levelExpertDescription => '16×30 · 99 minas · con zoom';

  @override
  String get back => 'Volver';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get pausedBoard => 'Tablero oculto en pausa';

  @override
  String elapsed(String time) {
    return 'Tiempo $time';
  }

  @override
  String minesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Quedan $count minas', one: 'Queda 1 mina');
    return '$_temp0';
  }

  @override
  String get modeReveal => 'Revelar';

  @override
  String get modeFlag => 'Bandera';

  @override
  String get undo => 'Deshacer';

  @override
  String get hint => 'Pista';

  @override
  String hintsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'quedan $count gratis',
      one: 'queda 1 gratis',
      zero: 'sin pistas gratis',
    );
    return '$_temp0';
  }

  @override
  String get noMoreHints => 'Sin más pistas en este tablero';

  @override
  String get zoomIn => 'Acercar';

  @override
  String get zoomOut => 'Ajustar al ancho';

  @override
  String get tapToStart => 'Toca cualquier celda para empezar';

  @override
  String get startHere => 'Empieza aquí: la celda marcada abre una zona';

  @override
  String get generating => 'Preparando el tablero';

  @override
  String longPressTip(String action) {
    return 'Mantén pulsada una celda para $action';
  }

  @override
  String get longPressTipFlag => 'poner bandera';

  @override
  String get longPressTipReveal => 'revelarla';

  @override
  String boardLabel(int columns, int rows) {
    return 'Tablero de Buscaminas, $columns por $rows';
  }

  @override
  String cellLabel(int row, int column, String content) {
    return 'Fila $row, columna $column, $content';
  }

  @override
  String get cellHidden => 'cerrada';

  @override
  String get cellFlagged => 'con bandera';

  @override
  String get cellEmpty => 'vacía';

  @override
  String cellNumber(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minas vecinas',
      one: '1 mina vecina',
    );
    return '$_temp0';
  }

  @override
  String get cellMine => 'mina';

  @override
  String get cellFatal => 'mina que terminó la partida';

  @override
  String get cellWrongFlag => 'bandera equivocada';

  @override
  String get cellStart => 'inicio sugerido';

  @override
  String get cellHint => 'señalada por la pista';

  @override
  String get altActionFlag => 'Poner o quitar bandera';

  @override
  String get altActionReveal => 'Revelar';

  @override
  String get won => '¡Despejado!';

  @override
  String get lostTitle => 'Esta vez explotó una mina';

  @override
  String lostWhere(int row, int column) {
    return 'La mina estaba en la fila $row, columna $column.';
  }

  @override
  String get retryBoard => 'Reintentar este tablero';

  @override
  String get newBoard => 'Tablero nuevo';

  @override
  String get rescue => 'Deshacer el último toque con un video';

  @override
  String get rescueRule => 'Una vez por partida. El video es opcional.';

  @override
  String get rescueUnavailable => 'Ahora no hay videos disponibles.';

  @override
  String get showBoard => 'Ver el tablero';

  @override
  String get showOptions => 'Ver opciones';

  @override
  String get hintTitle => 'Pista';

  @override
  String get hintSafe => 'La celda marcada es segura.';

  @override
  String get hintMine => 'La celda marcada es una mina.';

  @override
  String get hintWrongFlag => 'Esta bandera no tiene mina debajo.';

  @override
  String hintReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'numberSatisfied': 'Este número ya tiene todas sus minas marcadas: el resto de sus vecinas son seguras.',
      'numberNeedsAll': 'A este número le faltan tantas minas como vecinas cerradas tiene: todas son minas.',
      'twoNumbers': 'Comparando estos dos números vecinos se deduce la celda.',
      'mineCount': 'Por el conteo de minas que quedan.',
      'wrongFlag': 'Quítala: la celda es segura.',
      'other': 'No hay una deducción simple desde aquí: te mostramos una celda segura.',
    });
    return '$_temp0';
  }

  @override
  String get hintTryMyself => 'Lo intento yo';

  @override
  String get hintApplyReveal => 'Revelarla';

  @override
  String get hintApplyFlag => 'Ponerle bandera';

  @override
  String get hintApplyUnflag => 'Quitar la bandera';

  @override
  String get tutorialSkip => 'Saltar tutorial';

  @override
  String tutorialStep(int step) {
    return 'Paso $step de 3';
  }

  @override
  String get tutorialRuleNumber => 'Un número dice cuántas minas tiene entre sus 8 vecinas.';

  @override
  String get tutorialTaskNumber => 'Este 1 ya tiene su mina marcada. Toca otra vecina: es segura.';

  @override
  String get tutorialRuleFlag => 'Si un número tiene tantas vecinas cerradas como minas, todas son minas.';

  @override
  String get tutorialTaskFlag => 'Ponle bandera a la mina: mantén pulsada la celda o usa el modo Bandera.';

  @override
  String get tutorialRuleChord => 'Si un número ya tiene todas sus banderas, tocarlo abre sus otras vecinas.';

  @override
  String get tutorialTaskChord => 'Toca el 1 para abrir de una vez todas sus vecinas.';

  @override
  String get tutorialWrongFlagged => 'Esa celda tiene la bandera del 1: ahí está su mina.';

  @override
  String get tutorialWrongMine => 'Cuidado: ahí está la mina. Márcala con bandera.';

  @override
  String get tutorialWrongChord => 'También vale, pero tocar el 1 las abre todas de una vez.';

  @override
  String get tutorialRight => '¡Bien hecho!';

  @override
  String get tutorialNext => 'Siguiente';

  @override
  String get tutorialStart => 'Empezar a jugar';

  @override
  String get tutorialBoardLabel => 'Tablero de práctica de 5 por 5';

  @override
  String get settingsTapMode => 'Al tocar una celda';

  @override
  String get settingsTapModeHelp => 'La pulsación larga hace lo contrario.';

  @override
  String get settingsLongPress => 'Duración de la pulsación larga';

  @override
  String get settingsLongPressShort => 'Corta';

  @override
  String get settingsLongPressNormal => 'Normal';

  @override
  String get settingsLongPressLong => 'Larga';

  @override
  String get settingsChord => 'Abrir vecinas tocando un número';

  @override
  String get settingsChordHelp => 'Solo si el número ya tiene todas sus banderas.';

  @override
  String get settingsTutorial => 'Cómo se juega';
}
