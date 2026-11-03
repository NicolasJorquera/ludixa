// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'sudoku_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SudokuLocalizationsEs extends SudokuLocalizations {
  SudokuLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get gameName => 'Sudoku';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelMedium => 'Medio';

  @override
  String get levelHard => 'Difícil';

  @override
  String get levelExpert => 'Experto';

  @override
  String get levelEasyDescription => '3–6 min · el último número posible';

  @override
  String get levelMediumDescription => '6–12 min · intersecciones caja-línea';

  @override
  String get levelHardDescription => '12–20 min · pares y tríos';

  @override
  String get levelExpertDescription => '20–40 min · X-Wing y otras cadenas';

  @override
  String topBarProgress(String level, int percent) {
    return '$level · $percent %';
  }

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
  String get undo => 'Deshacer';

  @override
  String get erase => 'Borrar';

  @override
  String get notes => 'Notas';

  @override
  String notesState(String on) {
    String _temp0 = intl.Intl.selectLogic(on, {'true': 'activadas', 'other': 'desactivadas'});
    return '$_temp0';
  }

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
  String get noMoreHints => 'Sin más pistas en este puzzle';

  @override
  String keyRemaining(int digit, int remaining) {
    String _temp0 = intl.Intl.pluralLogic(
      remaining,
      locale: localeName,
      other: 'quedan $remaining',
      one: 'queda 1',
      zero: 'completo',
    );
    return '$digit, $_temp0';
  }

  @override
  String get boardLabel => 'Tablero de Sudoku, 9 por 9';

  @override
  String cellLabel(int row, int column, String content) {
    return 'Fila $row, columna $column, $content';
  }

  @override
  String get cellEmpty => 'vacía';

  @override
  String cellGiven(int digit) {
    return '$digit, fijo';
  }

  @override
  String cellNotes(String digits) {
    return 'notas $digits';
  }

  @override
  String get cellConflict => 'en conflicto';

  @override
  String get cellSelected => 'seleccionada';

  @override
  String get solved => '¡Resuelto!';

  @override
  String get preparing => 'Preparando el puzzle';

  @override
  String hintStep(int step) {
    return 'Pista · paso $step de 3';
  }

  @override
  String hintZone(String zone) {
    return 'Hay una deducción en $zone.';
  }

  @override
  String get hintZoneDetail => 'Mira dónde puede ir cada número en esa zona.';

  @override
  String hintNumber(int digit, int row, int column) {
    return 'Va un $digit en la fila $row, columna $column.';
  }

  @override
  String get hintNumberRevealed => 'Esta celda se resuelve con una técnica que aún no explicamos.';

  @override
  String get hintErrorTitle => 'Hay un número que no corresponde';

  @override
  String hintErrorDetail(int row, int column) {
    return 'Revisa la fila $row, columna $column. Puedes corregirlo tú o borrarlo.';
  }

  @override
  String get hintTryMyself => 'Lo intento yo';

  @override
  String get hintNextStep => 'Ver la técnica';

  @override
  String get hintShowNumber => 'Mostrar el número';

  @override
  String get hintEraseError => 'Borrar el número';

  @override
  String get hintDone => 'Entendido';

  @override
  String zoneRow(int n) {
    return 'la fila $n';
  }

  @override
  String zoneColumn(int n) {
    return 'la columna $n';
  }

  @override
  String zoneBox(String index) {
    String _temp0 = intl.Intl.selectLogic(index, {
      '0': 'la caja superior izquierda',
      '1': 'la caja superior central',
      '2': 'la caja superior derecha',
      '3': 'la caja central izquierda',
      '4': 'la caja central',
      '5': 'la caja central derecha',
      '6': 'la caja inferior izquierda',
      '7': 'la caja inferior central',
      'other': 'la caja inferior derecha',
    });
    return '$_temp0';
  }

  @override
  String zoneTwo(String a, String b) {
    return '$a y $b';
  }

  @override
  String zoneThree(String a, String b, String c) {
    return '$a, $b y $c';
  }

  @override
  String techniqueName(String technique) {
    String _temp0 = intl.Intl.selectLogic(technique, {
      'nakedSingle': 'Único candidato',
      'hiddenSingle': 'Único lugar',
      'pointing': 'Intersección en la caja',
      'claiming': 'Intersección en la línea',
      'nakedPair': 'Par desnudo',
      'hiddenPair': 'Par oculto',
      'nakedTriple': 'Trío desnudo',
      'hiddenTriple': 'Trío oculto',
      'xWing': 'X-Wing',
      'xyWing': 'XY-Wing',
      'other': 'Swordfish',
    });
    return '$_temp0';
  }

  @override
  String techniqueExplanation(String technique) {
    String _temp0 = intl.Intl.selectLogic(technique, {
      'nakedSingle': 'A esta celda solo le queda un número posible: los demás ya están en su fila, columna o caja.',
      'hiddenSingle': 'En esta zona, ese número solo cabe en una celda.',
      'pointing':
          'Dentro de la caja, el número solo puede ir en una línea; se descarta del resto de esa fila o columna.',
      'claiming': 'En la fila o columna, el número solo cabe dentro de una caja; se descarta del resto de la caja.',
      'nakedPair': 'Dos celdas comparten los mismos dos candidatos; esos números se descartan del resto de la zona.',
      'hiddenPair': 'Dos números solo caben en las mismas dos celdas; ahí se descartan los demás candidatos.',
      'nakedTriple': 'Tres celdas reparten entre sí los mismos tres candidatos; se descartan del resto de la zona.',
      'hiddenTriple': 'Tres números solo caben en las mismas tres celdas; ahí se descartan los demás candidatos.',
      'xWing': 'Un número forma un rectángulo en dos filas y dos columnas; se descarta del resto de esas columnas.',
      'xyWing':
          'Tres celdas de dos candidatos forman una pinza: el número que comparten las puntas se descarta donde ambas lo ven.',
      'other': 'Como el X-Wing, pero con tres filas y tres columnas.',
    });
    return '$_temp0';
  }

  @override
  String get tutorialSkip => 'Saltar tutorial';

  @override
  String tutorialStep(int step) {
    return 'Paso $step de 3';
  }

  @override
  String get tutorialRuleRow => 'Cada fila tiene todos los números, sin repetir.';

  @override
  String get tutorialRuleColumn => 'Cada columna también.';

  @override
  String get tutorialRuleBox => 'Y cada caja.';

  @override
  String get tutorialAsk => '¿Qué número va en la celda marcada?';

  @override
  String tutorialWrongRow(int digit) {
    return 'El $digit ya está en esta fila. Prueba con otro.';
  }

  @override
  String tutorialWrongColumn(int digit) {
    return 'El $digit ya está en esta columna. Prueba con otro.';
  }

  @override
  String tutorialWrongBox(int digit) {
    return 'El $digit ya está en esta caja. Prueba con otro.';
  }

  @override
  String tutorialRight(int digit) {
    return '¡Bien! El $digit es el único que falta.';
  }

  @override
  String get tutorialNext => 'Siguiente';

  @override
  String get tutorialStart => 'Empezar a jugar';

  @override
  String get tutorialBoardLabel => 'Tablero de práctica de 4 por 4';

  @override
  String get settingsInput => 'Forma de ingresar números';

  @override
  String get settingsInputCellFirst => 'Celda primero';

  @override
  String get settingsInputNumberFirst => 'Número primero';

  @override
  String get settingsErrors => 'Errores';

  @override
  String get settingsErrorsConflicts => 'Números repetidos';

  @override
  String get settingsErrorsSolution => 'Contra la solución';

  @override
  String get settingsErrorsNone => 'Sin indicación';

  @override
  String get settingsErrorsHelp => 'No hay límite de errores: solo cambia cómo se señalan.';

  @override
  String get settingsRemoveNotes => 'Borrar notas al colocar un número';

  @override
  String get settingsHighlightSame => 'Resaltar el mismo número';

  @override
  String get settingsTutorial => 'Cómo se juega';
}
