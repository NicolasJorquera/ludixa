import 'package:puzzle_core/puzzle_core.dart';

import 'achievements.dart';
import 'clock.dart';
import 'daily_day.dart';
import 'progress_repository.dart';
import 'session_record.dart';
import 'stats.dart';
import 'streak.dart';

/// Lo que cambió al registrar un resultado, para la pantalla de Resultado.
final class RecordOutcome {
  const RecordOutcome({this.streak, this.newAchievements = const [], this.perfectDay = false});

  /// Si el resultado contó un día de racha.
  final StreakUpdate? streak;
  final List<AchievementId> newAchievements;

  /// Con este resultado el día quedó perfecto.
  final bool perfectDay;
}

/// Casos de uso del progreso.
final class ProgressService {
  ProgressService(this.repository, {this.clock = const SystemClock()});

  final ProgressRepository repository;
  final Clock clock;

  /// Registra una partida terminada en una sola transacción.
  Future<RecordOutcome> recordResult(SessionRecord session) {
    if (!session.finished) throw ArgumentError('La partida ${session.id} no terminó');
    return repository.transaction((store) async {
      if ((await store.session(session.id))?.finished ?? false) {
        throw StateError('La partida ${session.id} ya se registró');
      }
      await store.putSession(session);
      StreakUpdate? streakUpdate;
      var perfectDay = false;
      final challengeDay = session.challengeDay;
      if (session.won && challengeDay != null && session.mode != PuzzleMode.free) {
        final existing =
            await store.day(challengeDay) ??
            DailyDay(day: challengeDay, offsetMinutes: session.startedAt.offsetMinutes);
        // Un reto diario cuenta si se empezó el mismo día local del reto; si
        // no (archivo, o un diario empezado tarde), deja una marca hueca.
        final sameDay = session.mode == PuzzleMode.daily && session.startedAt.day == challengeDay;
        if (sameDay) {
          final wasPlayed = existing.played;
          final updated = existing.copyWith(completed: {...existing.completed, session.game});
          await store.putDay(updated);
          perfectDay = updated.perfect && !existing.perfect;
          if (!wasPlayed) {
            streakUpdate = StreakRules.count(await store.streak(), session.startedAt);
            await store.putStreak(streakUpdate.state);
            for (final saved in streakUpdate.saversUsedOn) {
              final day =
                  await store.day(saved) ?? DailyDay(day: saved, offsetMinutes: session.startedAt.offsetMinutes);
              await store.putDay(day.copyWith(saverUsed: true));
            }
          }
        } else if (!existing.completed.contains(session.game)) {
          await store.putDay(existing.copyWith(archiveCompleted: {...existing.archiveCompleted, session.game}));
        }
      }
      final newAchievements = await _unlockReached(store);
      return RecordOutcome(streak: streakUpdate, newAchievements: newAchievements, perfectDay: perfectDay);
    });
  }

  /// Guarda una partida en curso (instantánea).
  Future<void> saveInProgress(SessionRecord session) {
    if (session.finished) throw ArgumentError('Usa recordResult para una partida terminada');
    return repository.putSession(session);
  }

  Future<StreakStatus> streakStatus() async => StreakRules.status(await repository.streak(), clock.now());

  /// ¿Se puede empezar hoy el reto diario de [game]? No, si ya se completó
  /// (también con el reloj atrasado a un día ya jugado).
  Future<bool> canPlayDaily(GameId game) async {
    final today = clock.now().day;
    final day = await repository.day(today);
    return !(day?.completed.contains(game) ?? false);
  }

  bool isInArchive(LocalDay day) => DailyArchive.isAvailable(day, clock.now().day);

  Future<ProgressSnapshot> snapshot() async => ProgressSnapshot(
    sessions: await repository.sessions(),
    days: await repository.days(),
    streak: await repository.streak(),
  );

  /// Avance de todos los logros y cuándo se desbloqueó cada uno.
  Future<List<({AchievementId id, int progress, DateTime? unlockedAt})>> achievements() async {
    final p = await snapshot();
    final unlocked = await repository.unlocked();
    return [
      for (final id in AchievementId.values) (id: id, progress: Achievements.progress(id, p), unlockedAt: unlocked[id]),
    ];
  }

  /// Estadísticas de un juego por dificultad, desde el último reinicio.
  Future<DifficultyStats> stats(GameId game, Difficulty difficulty) async {
    final since = await repository.statsResetAt(game);
    final sessions = (await repository.sessions()).where(
      (s) => s.game == game && (since == null || !s.startedAt.utc.isBefore(since)),
    );
    return ProgressStats.forDifficulty(sessions, game, difficulty);
  }

  /// Reinicia las estadísticas de un juego. No toca racha, calendario,
  /// maestría ni logros: las partidas siguen guardadas.
  Future<void> resetStats(GameId game) => repository.putStatsResetAt(game, clock.now().utc);

  Future<WeekSummary> week() async => ProgressStats.week(await repository.sessions(), clock.now().day);

  Future<List<AchievementId>> _unlockReached(ProgressStore store) async {
    final p = ProgressSnapshot(
      sessions: await store.sessions(),
      days: await store.days(),
      streak: await store.streak(),
    );
    final unlocked = await store.unlocked();
    final now = clock.now().utc;
    final reached = <AchievementId>[];
    for (final id in AchievementId.values) {
      if (unlocked.containsKey(id) || Achievements.progress(id, p) < id.target) continue;
      await store.unlock(id, now);
      reached.add(id);
    }
    return reached;
  }
}
