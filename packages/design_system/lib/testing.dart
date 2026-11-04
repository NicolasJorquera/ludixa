/// Ayudas de prueba compartidas por la app y los juegos.
library;

import 'dart:io';

/// Los goldens se comparan solo en Linux: es donde corre la CI y donde los
/// genera `tool/goldens.sh`. En macOS las fuentes se renderizan distinto.
final String? goldensSkip = Platform.isLinux ? null : 'goldens solo en Linux: bash tool/goldens.sh';
