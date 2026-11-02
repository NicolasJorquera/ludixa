import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Entorno de compilación. Coincide con el flavor de Android del mismo nombre.
enum AppEnvironment {
  /// Desarrollo: id de app `.dev`, anuncios de prueba, herramientas internas.
  dev(isProduction: false),

  /// Producción: la versión que se publica en Google Play.
  prod(isProduction: true);

  const AppEnvironment({required this.isProduction});

  final bool isProduction;
}

/// Entorno actual. Se fija en el arranque (ver bootstrap).
final environmentProvider = Provider<AppEnvironment>((ref) => AppEnvironment.dev);
