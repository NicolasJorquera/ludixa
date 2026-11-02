/// Entorno de compilación. Coincide con el flavor de Android del mismo nombre.
enum AppEnvironment {
  /// Desarrollo: id de app `.dev`, anuncios de prueba, herramientas internas.
  dev(isProduction: false),

  /// Producción: la versión que se publica en Google Play.
  prod(isProduction: true);

  const AppEnvironment({required this.isProduction});

  final bool isProduction;
}
