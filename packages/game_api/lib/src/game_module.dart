import 'package:flutter/widgets.dart';
import 'package:puzzle_core/puzzle_core.dart';

import 'game_host.dart';
import 'session.dart';

/// Una dificultad tal como se muestra en la hoja de selección.
final class DifficultyOption {
  const DifficultyOption({required this.id, required this.label, required this.description});

  final Difficulty id;

  /// Nombre traducido ("Medio", "Medium").
  final String label;

  /// Tiempo estimado y técnica, traducidos.
  final String description;
}

/// Cómo se arma el reto diario de un juego en un día dado.
final class DailySpec {
  const DailySpec({required this.difficulty, this.usesWordsLanguage = false});

  final Difficulty difficulty;

  /// El reto depende del idioma de las palabras (Sopa de letras).
  final bool usesWordsLanguage;
}

/// Un juego que se puede enchufar a la colección o a una app satélite.
abstract interface class GameModule {
  GameId get id;

  /// Versión del generador. Forma parte de la semilla del reto diario: si un
  /// cambio altera los puzzles generados, esta versión debe subir.
  int get generatorVersion;

  /// Textos propios del juego.
  List<LocalizationsDelegate<Object?>> get localizationsDelegates;

  /// Nombre visible en el idioma activo.
  String displayName(BuildContext context);

  Widget buildIcon(BuildContext context, {double size = 24});

  List<DifficultyOption> difficulties(BuildContext context);

  DailySpec dailySpec(LocalDay day);

  /// Pantalla de partida.
  Widget buildGame(BuildContext context, PuzzleRequest request, GameHost host);

  /// Tutorial jugable de la primera vez.
  Widget buildTutorial(BuildContext context, GameHost host);

  /// Ajustes propios del juego, o `null` si no tiene.
  Widget? buildSettings(BuildContext context);
}
