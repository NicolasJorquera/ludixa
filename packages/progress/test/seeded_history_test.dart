import 'dart:math';

import 'package:drift/native.dart';
import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

import 'support.dart';

const _levels = {
  GameId.sudoku: ['easy', 'medium', 'hard', 'expert'],
  GameId.minesweeper: ['beginner', 'intermediate', 'expert'],
  GameId.wordSearch: ['easy', 'medium', 'hard', 'expert'],
};

/// 100 días de juego deterministas: retos diarios (con días sin jugar),
/// partidas libres, derrotas del Buscaminas, abandonos, pistas, banderas y
/// temas de la sopa. En orden cronológico, como los juega una persona.
List<SessionRecord> _history(int seed) {
  final random = Random(seed);
  final sessions = <SessionRecord>[];
  var id = 0;
  final start = LocalDay(2026, 8, 25);
  for (var d = 0; d < 100; d++) {
    final day = start.addDays(d);
    if (random.nextInt(10) < 2) continue; // días sin jugar: la racha se rompe o la cubre un comodín
    var hour = 8;
    SessionRecord play(GameId game, String level, PuzzleMode mode) {
      final startedAt = at(day.toIso8601(), hour: hour++, minute: random.nextInt(50));
      final lost = game == GameId.minesweeper && random.nextInt(4) == 0;
      final abandoned = !lost && random.nextInt(25) == 0;
      final elapsed = Duration(seconds: 40 + random.nextInt(900));
      return SessionRecord(
        id: 'h${id++}',
        game: game,
        difficulty: Difficulty(level),
        mode: mode,
        startedAt: startedAt,
        challengeDay: mode == PuzzleMode.free ? null : day,
        themeIds: game == GameId.wordSearch ? ['tema${random.nextInt(14)}'] : const [],
      ).finish(
        status: lost
            ? SessionStatus.lost
            : abandoned
            ? SessionStatus.abandoned
            : SessionStatus.won,
        elapsed: elapsed,
        completedAt: startedAt.utc.add(elapsed),
        freeHints: random.nextInt(5) == 0 ? 1 + random.nextInt(3) : 0,
        flagsPlaced: game == GameId.minesweeper ? (random.nextInt(3) == 0 ? 0 : 1 + random.nextInt(10)) : null,
      );
    }

    for (final game in dailyGames) {
      if (random.nextInt(4) > 0) sessions.add(play(game, _levels[game]!.first, PuzzleMode.daily));
    }
    for (var i = random.nextInt(4); i > 0; i--) {
      final game = dailyGames[random.nextInt(3)];
      final levels = _levels[game]!;
      sessions.add(play(game, levels[random.nextInt(levels.length)], PuzzleMode.free));
    }
  }
  return sessions;
}

/// Cálculo independiente de las cifras de un nivel, directo de las partidas.
({int started, int won, int lost, Duration? best, Duration? mean}) _expected(
  List<SessionRecord> all,
  GameId game,
  String level,
) {
  final mine = all.where((s) => s.game == game && s.difficulty.value == level).toList();
  final wins = [
    for (final s in mine)
      if (s.status == SessionStatus.won) s.elapsed.inMicroseconds,
  ];
  return (
    started: mine.length,
    won: wins.length,
    lost: mine.where((s) => s.status == SessionStatus.lost).length,
    best: wins.isEmpty ? null : Duration(microseconds: wins.reduce(min)),
    mean: wins.isEmpty ? null : Duration(microseconds: wins.reduce((a, b) => a + b) ~/ wins.length),
  );
}

void main() {
  final suites = {
    'en memoria': InMemoryProgressRepository.new,
    'Drift': () => DriftProgressRepository(ProgressDatabase(NativeDatabase.memory())),
  };
  for (final MapEntry(key: name, value: create) in suites.entries) {
    group(name, () {
      late ProgressRepository repo;
      late List<SessionRecord> history;
      late List<(DateTime, List<AchievementId>)> unlockedEach;
      late ProgressService service;

      setUpAll(() async {
        repo = create();
        history = _history(2026);
        final clock = FakeClock(at('2026-08-25'));
        service = ProgressService(repo, clock: clock);
        unlockedEach = [];
        for (final s in history) {
          clock.current = LocalNow(utc: s.completedAt!, offsetMinutes: s.startedAt.offsetMinutes);
          final outcome = await service.recordResult(s);
          unlockedEach.add((s.completedAt!, outcome.newAchievements));
        }
      });
      tearDownAll(() async {
        if (repo case DriftProgressRepository(:final db)) await db.close();
      });

      test('el historial es variado: cientos de partidas, derrotas, abandonos y los tres juegos', () {
        expect(history.length, greaterThan(250));
        expect(history.where((s) => s.status == SessionStatus.lost), isNotEmpty);
        expect(history.where((s) => s.status == SessionStatus.abandoned), isNotEmpty);
        expect({for (final s in history) s.game}, dailyGames.toSet());
      });

      test('las cifras de cada nivel coinciden con las partidas', () async {
        for (final game in dailyGames) {
          final byLevel = await service.statsByLevel(game);
          for (final level in _levels[game]!) {
            final want = _expected(history, game, level);
            final got = byLevel[Difficulty(level)];
            if (want.started == 0) {
              expect(got, isNull, reason: '$game $level');
              continue;
            }
            expect(
              (got!.started, got.won, got.lost, got.bestTime, got.meanTime),
              (want.started, want.won, want.lost, want.best, want.mean),
              reason: '$game $level',
            );
          }
        }
      });

      test('los totales de Progreso coinciden con las partidas', () async {
        final summaries = await repo.sessionSummaries();
        expect(summaries.length, history.length);
        expect(ProgressStats.wins(summaries), history.where((s) => s.won).length);
        expect(ProgressStats.totalTime(summaries), history.fold(Duration.zero, (sum, s) => sum + s.elapsed));
        final perfect = await repo.days();
        final perfectDays = {
          for (final s in history)
            if (s.won && s.mode == PuzzleMode.daily) s.challengeDay!: <GameId>{},
        };
        for (final s in history.where((s) => s.won && s.mode == PuzzleMode.daily)) {
          perfectDays[s.challengeDay!]!.add(s.game);
        }
        expect(perfect.where((d) => d.perfect).length, perfectDays.values.where((games) => games.length == 3).length);
      });

      test('un logro nunca se desbloquea dos veces y queda con la fecha en que se ganó', () async {
        final reported = [for (final (_, ids) in unlockedEach) ...ids];
        expect(reported.toSet().length, reported.length, reason: 'algún logro se anunció dos veces');
        final unlocked = await repo.unlocked();
        expect(unlocked.keys.toSet(), reported.toSet());
        for (final (time, ids) in unlockedEach) {
          for (final id in ids) {
            expect(unlocked[id], time, reason: id.key);
          }
        }
        // Ganar otra vez no vuelve a anunciar nada ya desbloqueado.
        final again = await service.recordResult(session(startedAt: at('2026-11-10', hour: 9), mode: PuzzleMode.free));
        expect(again.newAchievements.toSet().intersection(unlocked.keys.toSet()), isEmpty);
      });

      test('los logros de banderas y temas se calculan desde lo que guardan las partidas', () async {
        final unlocked = (await repo.unlocked()).keys.toSet();
        final wonMines = history.where((s) => s.won && s.game == GameId.minesweeper);
        expect(unlocked.contains(AchievementId.minesNoFlags), wonMines.any((s) => s.flagsPlaced == 0));
        final themes = {
          for (final s in history)
            if (s.won && s.game == GameId.wordSearch) ...s.themeIds,
        };
        expect(unlocked.contains(AchievementId.wordsTenThemes), themes.length >= 10);
        final unassisted = history.where((s) => s.won && s.freeHints == 0).length;
        expect(unlocked.contains(AchievementId.tenUnassisted), unassisted >= 10);
        expect(unlocked.contains(AchievementId.allThreeGames), isTrue);
      });
    });
  }
}
