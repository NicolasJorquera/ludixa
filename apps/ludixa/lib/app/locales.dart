import 'dart:ui';

import 'environment.dart';

/// Idiomas publicados.
const releaseLocales = [Locale('es'), Locale('en')];

/// Inglés pseudolocalizado (textos acentuados y más largos). Solo en desarrollo.
const pseudoLocale = Locale('en', 'XA');

/// Idioma de respaldo cuando el del sistema no está soportado.
const fallbackLocale = Locale('en');

List<Locale> supportedLocalesFor(AppEnvironment environment) => [
  ...releaseLocales,
  if (!environment.isProduction) pseudoLocale,
];

/// Elige el idioma de la app a partir de los preferidos del sistema (o del
/// elegido en Ajustes): primero una coincidencia exacta, luego por idioma
/// ignorando la región (es-CL → es), y si no hay ninguna, inglés.
Locale resolveLocale(List<Locale>? preferred, Iterable<Locale> supported) {
  for (final locale in preferred ?? const <Locale>[]) {
    for (final candidate in supported) {
      if (candidate.languageCode == locale.languageCode && candidate.countryCode == locale.countryCode) {
        return candidate;
      }
    }
    for (final candidate in supported) {
      if (candidate.languageCode == locale.languageCode && candidate.countryCode == null) return candidate;
    }
  }
  return fallbackLocale;
}
