import 'package:flutter/foundation.dart';

/// Cómo se seleccionan las palabras.
enum SelectionMode {
  /// Arrastrar sobre las letras (por defecto).
  drag,

  /// Tocar la letra inicial y luego la final. Con TalkBack se usa siempre.
  tap,
}

/// Preferencias de la Sopa. [showTimer] y [haptics] vienen de los ajustes
/// generales de la app (H4-09).
@immutable
final class WordSearchSettings {
  const WordSearchSettings({
    this.selection = SelectionMode.drag,
    this.wordsLanguage,
    this.showTimer = true,
    this.haptics = true,
  });

  final SelectionMode selection;

  /// Idioma de las palabras (`es`, `en`) o null para seguir el de la app.
  final String? wordsLanguage;
  final bool showTimer;
  final bool haptics;

  WordSearchSettings copyWith({
    SelectionMode? selection,
    String? Function()? wordsLanguage,
    bool? showTimer,
    bool? haptics,
  }) => WordSearchSettings(
    selection: selection ?? this.selection,
    wordsLanguage: wordsLanguage == null ? this.wordsLanguage : wordsLanguage(),
    showTimer: showTimer ?? this.showTimer,
    haptics: haptics ?? this.haptics,
  );

  Map<String, Object?> toJson() => {'selection': selection.name, 'wordsLanguage': wordsLanguage};

  /// Valores desconocidos (de una versión futura) vuelven al predeterminado.
  factory WordSearchSettings.fromJson(Map<String, Object?> json) {
    final language = json['wordsLanguage'];
    return WordSearchSettings(
      selection: SelectionMode.values.where((v) => v.name == json['selection']).firstOrNull ?? SelectionMode.drag,
      wordsLanguage: language == 'es' || language == 'en' ? language as String : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WordSearchSettings &&
      other.selection == selection &&
      other.wordsLanguage == wordsLanguage &&
      other.showTimer == showTimer &&
      other.haptics == haptics;

  @override
  int get hashCode => Object.hash(selection, wordsLanguage, showTimer, haptics);
}

/// Dónde se guardan los ajustes de la Sopa.
abstract interface class WordSearchSettingsStore {
  WordSearchSettings load();

  Future<void> save(WordSearchSettings settings);
}

final class InMemoryWordSearchSettingsStore implements WordSearchSettingsStore {
  InMemoryWordSearchSettingsStore([this._settings = const WordSearchSettings()]);

  WordSearchSettings _settings;

  @override
  WordSearchSettings load() => _settings;

  @override
  Future<void> save(WordSearchSettings settings) async => _settings = settings;
}
