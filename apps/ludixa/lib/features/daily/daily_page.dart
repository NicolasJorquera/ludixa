import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:progress/progress.dart';

import '../../app/router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../play/play_providers.dart';
import 'challenge_rows.dart';
import 'daily_data.dart';
import 'month_calendar.dart';

/// Pestaña Reto: la fecha, la racha con sus comodines, los 3 retos del día,
/// el calendario del mes y el archivo. Se refresca sola al cambiar el día
/// con la pantalla abierta. El banner llega con la monetización (H5).
class DailyPage extends ConsumerStatefulWidget {
  const DailyPage({super.key});

  @override
  ConsumerState<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends ConsumerState<DailyPage> {
  Timer? _midnight;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _scheduleMidnight();
    // Al volver a la app puede haber cambiado el día.
    _lifecycle = AppLifecycleListener(onResume: _refreshDay);
  }

  @override
  void dispose() {
    _midnight?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = ref.read(clockProvider).now();
    final local = now.utc.add(Duration(minutes: now.offsetMinutes));
    final next = DateTime.utc(local.year, local.month, local.day + 1);
    _midnight = Timer(next.difference(local) + const Duration(seconds: 1), _refreshDay);
  }

  void _refreshDay() {
    if (!mounted) return;
    ref.invalidate(todayProvider);
    _scheduleMidnight();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final today = ref.watch(todayProvider);
    final status = ref.watch(dayStatusProvider(today)).value;
    final streak = ref.watch(streakStatusProvider).value;
    final month = ref.watch(monthDaysProvider((today.year, today.month))).value ?? const {};
    final date = DateFormat.MMMMEEEEd(locale).format(DateTime.utc(today.year, today.month, today.day));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dailyTitle)),
      body: ListView(
        padding: LudixaLayout.page(context),
        children: [
          Text(_capitalize(date), style: text.titleMedium),
          const SizedBox(height: 12),
          if (streak != null) _StreakBlock(streak: streak),
          const SizedBox(height: 16),
          if (status != null) ...[
            if (status.complete) ...[
              Row(
                children: [
                  Text(l10n.dailyDone, style: text.titleLarge),
                  const SizedBox(width: 8),
                  const LudixaIcon(LudixaIcons.check),
                ],
              ),
              Text(
                l10n.dailyNext(MaterialLocalizations.of(context).formatTimeOfDay(const TimeOfDay(hour: 0, minute: 0))),
                style: text.bodyMedium,
              ),
              const SizedBox(height: 12),
            ],
            ChallengeRows(status: status, isToday: true),
          ],
          const SizedBox(height: 16),
          MonthCalendar(
            year: today.year,
            month: today.month,
            days: month,
            today: today,
            onDayTap: (day) => context.go(AppRoutes.dailyDay(day)),
          ),
          const SizedBox(height: 16),
          LudixaButton(
            label: l10n.dailyArchive,
            onPressed: () => context.go(AppRoutes.archive),
            variant: LudixaButtonVariant.secondary,
          ),
        ],
      ),
    );
  }
}

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Racha, máximo y comodines. Si se rompió, el texto es neutro.
class _StreakBlock extends StatelessWidget {
  const _StreakBlock({required this.streak});

  final StreakStatus streak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    return LudixaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LudixaIcon(LudixaIcons.streak, color: p.minesweeper),
              const SizedBox(width: 8),
              Expanded(child: Text(l10n.dailyStreakDays(streak.current), style: text.titleLarge)),
              Semantics(
                label: l10n.dailySavers(streak.savers),
                excludeSemantics: true,
                child: Row(
                  children: [
                    for (var i = 0; i < StreakRules.maxSavers; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: LudixaIcon(LudixaIcons.saver, color: i < streak.savers ? p.primary : p.line),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (streak.current == 0 && streak.previous > 0)
            Text(l10n.dailyPrevious(streak.previous), style: text.bodyMedium)
          else if (streak.best > 0)
            Text(l10n.dailyBest(streak.best), style: text.bodyMedium?.copyWith(color: p.inkMuted)),
          if (streak.saversNeeded > 0) Text(l10n.dailySaversNeeded(streak.saversNeeded), style: text.bodySmall),
          Text(
            '${l10n.dailySavers(streak.savers)} · ${l10n.dailySaversHelp}',
            style: text.bodySmall?.copyWith(color: p.inkMuted),
          ),
        ],
      ),
    );
  }
}
