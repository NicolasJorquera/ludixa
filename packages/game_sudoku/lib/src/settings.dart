import 'package:flutter/foundation.dart';

/// Cómo se ingresan los números.
enum SudokuInputMode {
  /// Se toca una celda y luego un número (por defecto).
  cellFirst,

  /// Se elige un número y luego se tocan celdas.
  numberFirst,
}

/// Cómo se señalan los errores (PRD). No hay límite de errores.
enum SudokuErrorMode {
  /// Solo números repetidos en su fila, columna o caja (por defecto).
  conflicts,

  /// Números que no coinciden con la solución.
  solution,

  /// Sin indicación.
  none,
}

/// Preferencias del Sudoku. Las propias del juego se editan en
/// [SudokuSettingsView]; [showTimer] y [haptics] vienen de los ajustes
/// generales de la app (H4-09).
@immutable
final class SudokuSettings {
  const SudokuSettings({
    this.inputMode = SudokuInputMode.cellFirst,
    this.errorMode = SudokuErrorMode.conflicts,
    this.removeNotesOnPlace = true,
    this.highlightSameNumber = true,
    this.showTimer = true,
    this.haptics = true,
  });

  final SudokuInputMode inputMode;
  final SudokuErrorMode errorMode;
  final bool removeNotesOnPlace;
  final bool highlightSameNumber;
  final bool showTimer;
  final bool haptics;

  SudokuSettings copyWith({
    SudokuInputMode? inputMode,
    SudokuErrorMode? errorMode,
    bool? removeNotesOnPlace,
    bool? highlightSameNumber,
    bool? showTimer,
    bool? haptics,
  }) => SudokuSettings(
    inputMode: inputMode ?? this.inputMode,
    errorMode: errorMode ?? this.errorMode,
    removeNotesOnPlace: removeNotesOnPlace ?? this.removeNotesOnPlace,
    highlightSameNumber: highlightSameNumber ?? this.highlightSameNumber,
    showTimer: showTimer ?? this.showTimer,
    haptics: haptics ?? this.haptics,
  );

  Map<String, Object?> toJson() => {
    'inputMode': inputMode.name,
    'errorMode': errorMode.name,
    'removeNotesOnPlace': removeNotesOnPlace,
    'highlightSameNumber': highlightSameNumber,
  };

  /// Valores desconocidos (de una versión futura) vuelven al predeterminado.
  factory SudokuSettings.fromJson(Map<String, Object?> json) {
    T byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    return SudokuSettings(
      inputMode: byName(SudokuInputMode.values, json['inputMode'], SudokuInputMode.cellFirst),
      errorMode: byName(SudokuErrorMode.values, json['errorMode'], SudokuErrorMode.conflicts),
      removeNotesOnPlace: json['removeNotesOnPlace'] as bool? ?? true,
      highlightSameNumber: json['highlightSameNumber'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SudokuSettings &&
      other.inputMode == inputMode &&
      other.errorMode == errorMode &&
      other.removeNotesOnPlace == removeNotesOnPlace &&
      other.highlightSameNumber == highlightSameNumber &&
      other.showTimer == showTimer &&
      other.haptics == haptics;

  @override
  int get hashCode => Object.hash(inputMode, errorMode, removeNotesOnPlace, highlightSameNumber, showTimer, haptics);
}

/// Dónde se guardan los ajustes del Sudoku. La app lo implementa con sus
/// preferencias; las pruebas usan [InMemorySudokuSettingsStore].
abstract interface class SudokuSettingsStore {
  /// Síncrona: los ajustes se necesitan al abrir la partida.
  SudokuSettings load();

  Future<void> save(SudokuSettings settings);
}

final class InMemorySudokuSettingsStore implements SudokuSettingsStore {
  InMemorySudokuSettingsStore([this._settings = const SudokuSettings()]);

  SudokuSettings _settings;

  @override
  SudokuSettings load() => _settings;

  @override
  Future<void> save(SudokuSettings settings) async => _settings = settings;
}
