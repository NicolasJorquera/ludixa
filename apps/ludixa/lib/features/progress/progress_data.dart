import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';

import '../play/play_providers.dart';

/// Los 4 totales de la pestaña Estadísticas. Son de todo el historial: el
/// reinicio de un nivel solo afecta a su fila de la tabla.
final class ProgressTotals {
  const ProgressTotals({
    required this.finished,
    required this.completed,
    required this.totalTime,
    required this.currentStreak,
    required this.bestStreak,
    required this.perfectDays,
  });

  /// Partidas terminadas, ganadas o perdidas.
  final int finished;
  final int completed;
  final Duration totalTime;
  final int currentStreak;
  final int bestStreak;
  final int perfectDays;

  /// Sin partidas terminadas se muestra el estado vacío. Una derrota en el
  /// Buscaminas ya tiene estadísticas que mostrar.
  bool get isEmpty => finished == 0;
}

final progressTotalsProvider = FutureProvider<ProgressTotals>((ref) async {
  ref.watch(progressRevisionProvider);
  final service = ref.watch(progressServiceProvider);
  final snapshot = await service.snapshot();
  final streak = await service.streakStatus();
  return ProgressTotals(
    finished: snapshot.sessions.where((s) => s.finished).length,
    completed: ProgressStats.wins(snapshot.sessions),
    totalTime: ProgressStats.totalTime(snapshot.sessions),
    currentStreak: streak.current,
    bestStreak: streak.best,
    perfectDays: snapshot.days.where((d) => d.perfect).length,
  );
});

/// Estadísticas de cada nivel jugado de un juego, desde su último reinicio.
/// Incluye niveles que no están en el selector (el Buscaminas reducido del
/// reto); la pantalla agrega los que faltan como "Aún sin jugar".
final levelStatsProvider = FutureProvider.family<Map<Difficulty, DifficultyStats>, GameId>((ref, game) async {
  ref.watch(progressRevisionProvider);
  final service = ref.watch(progressServiceProvider);
  final levels = {
    for (final s in await service.repository.sessions())
      if (s.game == game) s.difficulty,
  };
  return {for (final level in levels) level: await service.stats(game, level)};
});

typedef AchievementState = ({AchievementId id, int progress, DateTime? unlockedAt});

final achievementsProvider = FutureProvider<List<AchievementState>>((ref) {
  ref.watch(progressRevisionProvider);
  return ref.watch(progressServiceProvider).achievements();
});
