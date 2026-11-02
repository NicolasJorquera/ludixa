import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../widgets/pending_screen.dart';

/// Estadísticas y logros. Pantalla provisional hasta H4-08.
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) => PendingScreen(title: AppLocalizations.of(context).progressTitle);
}
