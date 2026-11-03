import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';

/// Estructura con la barra de 4 pestañas.
///
/// Botón atrás de Android: dentro de una pestaña retrocede en su pila; en la
/// raíz de otra pestaña vuelve a Inicio; en la raíz de Inicio sale de la app.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _select(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: Semantics(
          label: l10n.navigationLabel,
          container: true,
          child: NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _select,
            // La pestaña activa se distingue por el indicador y el color, no por el icono.
            destinations: [
              NavigationDestination(icon: const LudixaIcon(LudixaIcons.home), label: l10n.navHome),
              NavigationDestination(icon: const LudixaIcon(LudixaIcons.daily), label: l10n.navDaily),
              NavigationDestination(icon: const LudixaIcon(LudixaIcons.progress), label: l10n.navProgress),
              NavigationDestination(icon: const LudixaIcon(LudixaIcons.settings), label: l10n.navSettings),
            ],
          ),
        ),
      ),
    );
  }
}
