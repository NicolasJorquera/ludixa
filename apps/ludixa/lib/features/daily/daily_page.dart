import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../widgets/pending_screen.dart';

/// Reto diario. Pantalla provisional hasta H4-07.
class DailyPage extends StatelessWidget {
  const DailyPage({super.key});

  @override
  Widget build(BuildContext context) => PendingScreen(title: AppLocalizations.of(context).dailyTitle);
}
