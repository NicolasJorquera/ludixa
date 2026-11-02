import 'package:flutter/material.dart';

// Tema provisional generado desde el azul primario del sistema visual.
// H2-01 lo reemplaza por los tokens completos (claro, oscuro y daltonismo).
const _primary = Color(0xFF2B4FD8);

ThemeData buildTheme(Brightness brightness) => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: _primary, brightness: brightness),
  useMaterial3: true,
);
