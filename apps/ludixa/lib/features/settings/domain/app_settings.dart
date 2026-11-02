import 'dart:ui';

/// Tema elegido por el jugador.
enum ThemePreference { system, light, dark }

/// Preferencias generales de la app.
final class AppSettings {
  const AppSettings({this.theme = ThemePreference.system, this.locale, this.colorblindPalette = false});

  final ThemePreference theme;

  /// Idioma elegido, o `null` para seguir al sistema.
  final Locale? locale;

  /// Paleta que no depende de distinguir rojo y verde.
  final bool colorblindPalette;

  AppSettings copyWith({ThemePreference? theme, Locale? Function()? locale, bool? colorblindPalette}) => AppSettings(
    theme: theme ?? this.theme,
    locale: locale != null ? locale() : this.locale,
    colorblindPalette: colorblindPalette ?? this.colorblindPalette,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.theme == theme &&
      other.locale == locale &&
      other.colorblindPalette == colorblindPalette;

  @override
  int get hashCode => Object.hash(theme, locale, colorblindPalette);
}
