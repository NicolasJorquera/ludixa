import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../../l10n/generated/app_localizations.dart';

/// Calendario mensual del reto: de 0 a 3 puntos por día (huecos si vienen del
/// archivo), día perfecto relleno, hoy con borde y un escudo si lo cubrió un
/// comodín. La semana empieza según el idioma (lunes en es, domingo en en-US).
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.days,
    required this.today,
    this.onDayTap,
  });

  final int year;
  final int month;
  final Map<LocalDay, DailyDay> days;
  final LocalDay today;

  /// Al tocar un día (solo los del archivo).
  final ValueChanged<LocalDay>? onDayTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final firstWeekday = MaterialLocalizations.of(context).firstDayOfWeekIndex; // 0 = domingo
    final first = DateTime.utc(year, month, 1);
    final length = DateTime.utc(year, month + 1, 0).day;
    // Columnas vacías antes del día 1 (DateTime.weekday: 1 = lunes … 7 = domingo).
    final leading = (first.weekday % 7 - firstWeekday) % 7;
    final monthName = DateFormat.yMMMM(locale).format(first);
    final dayFormat = DateFormat.MMMMd(locale);

    return Semantics(
      label: l10n.dailyCalendar(monthName),
      container: true,
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ExcludeSemantics(
              child: Text(monthName[0].toUpperCase() + monthName.substring(1), style: text.titleMedium),
            ),
          ),
          const SizedBox(height: 8),
          // Los números del calendario escalan hasta el 130 %, como los de las
          // grillas: 7 columnas no dan para más en un teléfono. Cada día se
          // anuncia completo a TalkBack.
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: Column(
              children: [
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: ExcludeSemantics(
                          child: Text(
                            DateFormat.EEEEE(locale).format(DateTime.utc(2026, 11, 1 + (firstWeekday + i) % 7)),
                            textAlign: TextAlign.center,
                            style: text.labelSmall?.copyWith(color: p.inkMuted),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                for (var week = 0; week * 7 < leading + length; week++)
                  Row(
                    children: [
                      for (var col = 0; col < 7; col++)
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final n = week * 7 + col - leading + 1;
                              if (n < 1 || n > length) return const SizedBox(height: 48);
                              final day = LocalDay(year, month, n);
                              final record = days[day];
                              final done = record?.completed.length ?? 0;
                              final fromArchive =
                                  (record?.archiveCompleted.difference(record.completed) ?? const {}).length;
                              final perfect = record?.perfect ?? false;
                              final isToday = day == today;
                              final tappable = onDayTap != null && DailyArchive.isAvailable(day, today);
                              final suffix = [
                                if (isToday) l10n.dailyDayToday,
                                if (perfect) l10n.dailyDayPerfect,
                                if (record?.saverUsed ?? false) l10n.dailyDaySaver,
                                l10n.dailyDayArchive(fromArchive),
                              ].join();
                              return Semantics(
                                container: true,
                                label: l10n.dailyDayLabel(dayFormat.format(DateTime.utc(year, month, n)), done, suffix),
                                button: tappable,
                                excludeSemantics: true,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: tappable ? () => onDayTap!(day) : null,
                                  child: SizedBox(
                                    height: 48,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: perfect ? p.primary : null,
                                            border: isToday ? Border.all(color: p.primary, width: 2) : null,
                                          ),
                                          child: record?.saverUsed ?? false
                                              ? LudixaIcon(LudixaIcons.saver, size: 16, color: p.inkMuted)
                                              : Text(
                                                  '$n',
                                                  style: text.bodySmall?.copyWith(
                                                    color: perfect
                                                        ? p.onPrimary
                                                        : (day.isAfter(today) ? p.inkMuted : p.ink),
                                                    fontWeight: isToday ? FontWeight.w700 : null,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            for (var k = 0; k < done + fromArchive && k < 3; k++)
                                              Container(
                                                width: 5,
                                                height: 5,
                                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  // Hueco: completado después, desde el archivo.
                                                  color: k < done ? p.primary : null,
                                                  border: k < done ? null : Border.all(color: p.primary),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
