import 'dart:ui';

/// Tema elegido por el jugador.
enum ThemePreference { system, light, dark }

/// Tamaño de texto propio, encima del que pide el sistema.
enum TextSizePreference {
  system(1),
  large(1.15),
  larger(1.3);

  const TextSizePreference(this.factor);

  /// Multiplica la escala del sistema.
  final double factor;
}

/// Preferencias generales de la app.
final class AppSettings {
  const AppSettings({
    this.theme = ThemePreference.system,
    this.locale,
    this.colorblindPalette = false,
    this.textSize = TextSizePreference.system,
    this.reduceMotion = false,
    this.haptics = true,
    this.showTimer = true,
  });

  final ThemePreference theme;

  /// Idioma elegido, o `null` para seguir al sistema.
  final Locale? locale;

  /// Paleta que no depende de distinguir rojo y verde.
  final bool colorblindPalette;

  final TextSizePreference textSize;

  /// Quita animaciones aunque el sistema no lo pida.
  final bool reduceMotion;

  /// Vibración en las partidas.
  final bool haptics;

  /// Temporizador visible en las partidas. El tiempo se mide igual.
  final bool showTimer;

  AppSettings copyWith({
    ThemePreference? theme,
    Locale? Function()? locale,
    bool? colorblindPalette,
    TextSizePreference? textSize,
    bool? reduceMotion,
    bool? haptics,
    bool? showTimer,
  }) => AppSettings(
    theme: theme ?? this.theme,
    locale: locale != null ? locale() : this.locale,
    colorblindPalette: colorblindPalette ?? this.colorblindPalette,
    textSize: textSize ?? this.textSize,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    haptics: haptics ?? this.haptics,
    showTimer: showTimer ?? this.showTimer,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.theme == theme &&
      other.locale == locale &&
      other.colorblindPalette == colorblindPalette &&
      other.textSize == textSize &&
      other.reduceMotion == reduceMotion &&
      other.haptics == haptics &&
      other.showTimer == showTimer;

  @override
  int get hashCode => Object.hash(theme, locale, colorblindPalette, textSize, reduceMotion, haptics, showTimer);
}
