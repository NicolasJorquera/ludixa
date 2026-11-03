// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'words_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class WordsLocalizationsEs extends WordsLocalizations {
  WordsLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get gameName => 'Sopa de letras';

  @override
  String get levelEasy => 'Fácil';

  @override
  String get levelMedium => 'Medio';

  @override
  String get levelHard => 'Difícil';

  @override
  String get levelExpert => 'Experto';

  @override
  String get levelEasyDescription => '8×8 · 6 palabras · derecha y abajo';

  @override
  String get levelMediumDescription => '10×10 · 9 palabras · también en diagonal';

  @override
  String get levelHardDescription => '12×12 · 12 palabras · en las 8 direcciones';

  @override
  String get levelExpertDescription => '14×14 · 15 palabras · con señuelos';

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
  String wordsCount(int found, int total) {
    return '$found de $total';
  }

  @override
  String wordsCountLabel(int found, int total) {
    return '$found de $total palabras encontradas';
  }

  @override
  String get wordsShow => 'Ver palabras';

  @override
  String get wordsHide => 'Ocultar palabras';

  @override
  String wordFound(String word) {
    return '$word, encontrada';
  }

  @override
  String wordPending(String word) {
    return '$word, por encontrar';
  }

  @override
  String announceFound(String word) {
    return 'Encontraste $word';
  }

  @override
  String get announceAll => '¡Encontraste todas las palabras!';

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
  String get noMoreHints => 'Sin más pistas en esta sopa';

  @override
  String hintAnnounce(int row, int column) {
    return 'Una palabra empieza en la fila $row, columna $column';
  }

  @override
  String get zoomIn => 'Acercar';

  @override
  String get zoomOut => 'Ajustar al ancho';

  @override
  String get tapModeStart => 'Toca la letra inicial';

  @override
  String get tapModeEnd => 'Ahora toca la letra final';

  @override
  String boardLabel(int size) {
    return 'Sopa de letras, $size por $size';
  }

  @override
  String cellLabel(int row, int column, String letter, String state) {
    return 'Fila $row, columna $column, $letter$state';
  }

  @override
  String get cellInWord => ', en una palabra encontrada';

  @override
  String get cellSelected => ', seleccionada';

  @override
  String get cellHint => ', inicio de una palabra (pista)';

  @override
  String get tutorialSkip => 'Saltar tutorial';

  @override
  String tutorialStep(int step) {
    return 'Paso $step de 3';
  }

  @override
  String get tutorialRuleDrag => 'Arrastra el dedo sobre las letras de una palabra.';

  @override
  String get tutorialTaskDrag => 'Encuentra SOL, de izquierda a derecha.';

  @override
  String get tutorialRuleDirections => 'Las palabras van en recta: también en diagonal o al revés.';

  @override
  String get tutorialTaskDirections => 'Encuentra MAR: está en diagonal.';

  @override
  String get tutorialRuleList => 'La lista dice qué falta. Las encontradas se tachan.';

  @override
  String get tutorialTaskList => 'Encuentra la palabra que falta en la lista.';

  @override
  String get tutorialWrong => 'Esa no es la palabra. Prueba de nuevo: no pasa nada.';

  @override
  String get tutorialRight => '¡Bien hecho!';

  @override
  String get tutorialNext => 'Siguiente';

  @override
  String get tutorialStart => 'Empezar a jugar';

  @override
  String get tutorialBoardLabel => 'Sopa de práctica de 6 por 6';

  @override
  String get settingsSelection => 'Cómo se seleccionan las palabras';

  @override
  String get settingsSelectionDrag => 'Arrastrar';

  @override
  String get settingsSelectionTap => 'Tocar inicio y final';

  @override
  String get settingsSelectionHelp => 'Con TalkBack se usa siempre tocar inicio y final.';

  @override
  String get settingsLanguage => 'Idioma de las palabras';

  @override
  String get settingsLanguageApp => 'El de la app';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsTutorial => 'Cómo se juega';
}
