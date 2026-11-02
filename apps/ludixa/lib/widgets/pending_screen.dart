import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

/// Pantalla de una pestaña que todavía no está construida.
///
/// Lo dice explícitamente para que nadie la confunda con una pantalla
/// terminada. Desaparece cuando cada pestaña tenga su pantalla real (H4).
class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(24),
          child: Text(AppLocalizations.of(context).comingSoon, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
