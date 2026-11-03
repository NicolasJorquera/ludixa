import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../../app/router.dart';
import '../../l10n/generated/app_localizations.dart';
import 'challenge_rows.dart';
import 'daily_data.dart';

String _dayTitle(BuildContext context, LocalDay day) {
  final s = DateFormat.MMMMEEEEd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(DateTime.utc(day.year, day.month, day.day));
  return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Archivo: los retos de los últimos 30 días. No suman a la racha, pero
/// completan el calendario con una marca hueca.
class ArchivePage extends ConsumerWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final days = ref.watch(archiveDaysProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.archiveTitle)),
      body: ListView(
        padding: LudixaLayout.page(context),
        children: [
          Text(l10n.archiveHint, style: text.bodyMedium),
          const SizedBox(height: 12),
          for (final (day, record) in days)
            LudixaListRow(
              title: _dayTitle(context, day),
              value: l10n.archiveMarks({...?record?.completed, ...?record?.archiveCompleted}.length),
              onTap: () => context.go(AppRoutes.dailyDay(day)),
            ),
        ],
      ),
    );
  }
}

/// Detalle de un día: sus 3 retos, jugables desde el archivo.
class DayPage extends ConsumerWidget {
  const DayPage({super.key, required this.day});

  final LocalDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayProvider);
    final status = ref.watch(dayStatusProvider(day)).value;
    final available = DailyArchive.isAvailable(day, today);
    return Scaffold(
      appBar: AppBar(title: Text(_dayTitle(context, day))),
      body: ListView(
        padding: LudixaLayout.page(context),
        children: [
          if (!available)
            Text(l10n.archiveOutside)
          else ...[
            Text(l10n.archiveHint, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            if (status != null) ChallengeRows(status: status, isToday: false),
          ],
        ],
      ),
    );
  }
}
