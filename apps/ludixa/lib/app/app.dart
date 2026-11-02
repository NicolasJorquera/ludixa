import 'package:flutter/material.dart';

import 'environment.dart';

/// Raíz de la app.
///
/// Por ahora solo arranca y muestra el entorno. La navegación con 4 pestañas,
/// el tema y los idiomas llegan en H1-06 y H1-07.
class LudixaApp extends StatelessWidget {
  const LudixaApp({super.key, required this.environment});

  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludixa',
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          environment.isProduction ? child! : Banner(message: 'DEV', location: BannerLocation.topEnd, child: child),
      home: const Scaffold(body: Center(child: Text('Ludixa'))),
    );
  }
}
