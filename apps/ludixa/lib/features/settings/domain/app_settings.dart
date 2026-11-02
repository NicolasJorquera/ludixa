import 'dart:ui';

/// Tema elegido por el jugador.
enum ThemePreference { system, light, dark }

/// Preferencias generales de la app.
final class AppSettings {
  const AppSettings({this.theme = ThemePreference.system, this.locale});

  final ThemePreference theme;

  /// Idioma elegido, o `null` para seguir al sistema.
  final Locale? locale;

  AppSettings copyWith({ThemePreference? theme, Locale? Function()? locale}) =>
      AppSettings(theme: theme ?? this.theme, locale: locale != null ? locale() : this.locale);

  @override
  bool operator ==(Object other) => other is AppSettings && other.theme == theme && other.locale == locale;

  @override
  int get hashCode => Object.hash(theme, locale);
}
