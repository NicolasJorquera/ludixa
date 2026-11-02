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
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_today_outlined),
                selectedIcon: const Icon(Icons.calendar_today),
                label: l10n.navDaily,
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: l10n.navProgress,
              ),
              NavigationDestination(
                icon: const Icon(Icons.tune_outlined),
                selectedIcon: const Icon(Icons.tune),
                label: l10n.navSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
