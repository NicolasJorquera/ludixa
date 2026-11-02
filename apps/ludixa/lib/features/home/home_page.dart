import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../widgets/pending_screen.dart';

/// Portada. Pantalla provisional hasta H4-06.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => PendingScreen(title: AppLocalizations.of(context).homeTitle);
}
