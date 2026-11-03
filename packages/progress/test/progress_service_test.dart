import 'package:progress/progress.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late InMemoryProgressRepository repo;
  late FakeClock clock;
  late ProgressService service;

  setUp(() {
    repo = InMemoryProgressRepository();
    clock = FakeClock(at('2026-11-02'));
    service = ProgressService(repo, clock: clock);
  });

  group('reto diario', () {
    test('el primer reto del día cuenta la racha; los siguientes no la cuentan otra vez', () async {
      final first = await service.recordResult(session(startedAt: at('2026-11-02', hour: 9)));
      final second = await service.recordResult(
        session(startedAt: at('2026-11-02', hour: 10), game: GameId.minesweeper, difficulty: 'beginner'),
      );
      expect(first.streak?.state.current, 1);
      expect(second.streak, isNull);
      expect((await repo.day(LocalDay(2026, 11, 2)))!.completed, {GameId.sudoku, GameId.minesweeper});
    });

    test('empezado 23:55 y terminado 00:05 cuenta para el día en que se empezó', () async {
      final late = session(startedAt: at('2026-11-02', hour: 23, minute: 55), finishAfter: const Duration(minutes: 10));
      clock.current = at('2026-11-03', hour: 0, minute: 5);
      await service.recordResult(late);
      expect((await repo.day(LocalDay(2026, 11, 2)))!.played, isTrue);
      expect(await repo.day(LocalDay(2026, 11, 3)), isNull);
      expect((await repo.streak()).lastCounted, LocalDay(2026, 11, 2));
    });

    test('los tres retos hacen un día perfecto, una sola vez', () async {
      final day = at('2026-11-02');
      final results = [
        await service.recordResult(session(startedAt: day)),
        await service.recordResult(session(startedAt: day, game: GameId.minesweeper, difficulty: 'beginner')),
        await service.recordResult(session(startedAt: day, game: GameId.wordSearch, themeIds: ['frutas'])),
      ];
      expect([for (final r in results) r.perfectDay], [false, false, true]);
      expect(results.last.newAchievements, containsAll([AchievementId.perfectDay, AchievementId.allThreeGames]));
    });

    test('perder o abandonar no cuenta', () async {
      await service.recordResult(
        session(startedAt: at('2026-11-02'), game: GameId.minesweeper, status: SessionStatus.lost),
      );
      expect(await repo.day(LocalDay(2026, 11, 2)), isNull);
      expect((await repo.streak()).current, 0);
    });

    test('el archivo deja marca hueca y no toca la racha', () async {
      clock.current = at('2026-11-10');
      final outcome = await service.recordResult(
        session(startedAt: at('2026-11-10'), mode: PuzzleMode.archive, challengeDay: LocalDay(2026, 11, 2)),
      );
      final day = (await repo.day(LocalDay(2026, 11, 2)))!;
      expect(outcome.streak, isNull);
      expect((day.played, day.marks), (false, 1));
      expect(day.archiveCompleted, {GameId.sudoku});
      expect((await repo.streak()).current, 0);
    });

    test('el archivo abarca los 30 días anteriores a hoy', () {
      clock.current = at('2026-12-01');
      expect(service.isInArchive(LocalDay(2026, 11, 30)), isTrue);
      expect(service.isInArchive(LocalDay(2026, 11, 1)), isTrue);
      expect(service.isInArchive(LocalDay(2026, 10, 31)), isFalse);
      expect(service.isInArchive(LocalDay(2026, 12, 1)), isFalse);
    });

    test('los días cubiertos por un comodín quedan marcados en el calendario', () async {
      for (var i = 2; i <= 8; i++) {
        await service.recordResult(session(startedAt: at('2026-11-0$i')));
      }
      final outcome = await service.recordResult(session(startedAt: at('2026-11-10')));
      expect(outcome.streak!.state.current, 8);
      expect((await repo.day(LocalDay(2026, 11, 9)))!.saverUsed, isTrue);
    });

    test('con el reloj atrasado no se puede volver a jugar un reto ya completado', () async {
      await service.recordResult(session(startedAt: at('2026-11-03')));
      clock.current = at('2026-11-03', hour: 18);
      expect(await service.canPlayDaily(GameId.sudoku), isFalse);
      expect(await service.canPlayDaily(GameId.minesweeper), isTrue);
    });
  });

  group('transacción', () {
    test('registrar dos veces la misma partida falla y no duplica nada', () async {
      final s = session(startedAt: at('2026-11-02'));
      await service.recordResult(s);
      await expectLater(service.recordResult(s), throwsStateError);
      expect(await repo.sessions(), hasLength(1));
    });

    test('si algo falla a mitad, no queda nada escrito', () async {
      await expectLater(
        repo.transaction((store) async {
          await store.putStreak(const StreakState(current: 9));
          throw StateError('falla');
        }),
        throwsStateError,
      );
      expect((await repo.streak()).current, 0);
    });

    test('una instantánea guarda el estado y el tiempo de la partida en curso', () async {
      final running = SessionRecord(
        id: 'y',
        game: GameId.sudoku,
        difficulty: const Difficulty('easy'),
        mode: PuzzleMode.free,
        startedAt: at('2026-11-02'),
      );
      await service.saveInProgress(running.withState({'v': 1}, const Duration(seconds: 9)));
      final saved = (await repo.session('y'))!;
      expect(saved.state, {'v': 1});
      expect((saved.elapsed, saved.status), (const Duration(seconds: 9), SessionStatus.inProgress));
    });

    test('una partida en curso no se registra como resultado', () async {
      final running = SessionRecord(
        id: 'x',
        game: GameId.sudoku,
        difficulty: const Difficulty('easy'),
        mode: PuzzleMode.free,
        startedAt: at('2026-11-02'),
      );
      expect(() => service.recordResult(running), throwsArgumentError);
      await service.saveInProgress(running);
      expect((await repo.session('x'))!.status, SessionStatus.inProgress);
    });
  });

  group('logros', () {
    test('primer puzzle se desbloquea una vez, con la hora del reloj', () async {
      final first = await service.recordResult(session(startedAt: at('2026-11-02'), mode: PuzzleMode.free));
      final second = await service.recordResult(session(startedAt: at('2026-11-02'), mode: PuzzleMode.free));
      expect(first.newAchievements, [AchievementId.firstPuzzle]);
      expect(second.newAchievements, isEmpty);
      expect((await repo.unlocked())[AchievementId.firstPuzzle], clock.current.utc);
    });

    test('son 18 con ids únicos', () {
      expect(AchievementId.values, hasLength(18));
      expect({for (final a in AchievementId.values) a.key}, hasLength(18));
    });

    test('rachas de 3 y 7 días', () async {
      List<AchievementId> unlocked = [];
      for (var i = 2; i <= 8; i++) {
        unlocked += (await service.recordResult(session(startedAt: at('2026-11-0$i')))).newAchievements;
      }
      expect(unlocked, containsAll([AchievementId.streak3, AchievementId.streak7]));
      expect(unlocked, isNot(contains(AchievementId.streak30)));
    });

    test('Sudoku: Difícil, Experto y Medio en menos de 6 minutos', () async {
      Future<List<AchievementId>> win(String difficulty, int minutes) async => (await service.recordResult(
        session(
          startedAt: at('2026-11-02'),
          mode: PuzzleMode.free,
          difficulty: difficulty,
          elapsed: Duration(minutes: minutes),
        ),
      )).newAchievements;
      expect(await win('medium', 6), isNot(contains(AchievementId.sudokuFastMedium)));
      expect(await win('medium', 5), contains(AchievementId.sudokuFastMedium));
      expect(await win('hard', 20), contains(AchievementId.sudokuFirstHard));
      expect(await win('expert', 30), contains(AchievementId.sudokuFirstExpert));
    });

    test('Buscaminas: 5 seguidas (una derrota reinicia), sin banderas y Experto', () async {
      Future<List<AchievementId>> mines(SessionStatus status, {int flags = 3, String difficulty = 'beginner'}) async =>
          (await service.recordResult(
            session(
              startedAt: at('2026-11-02'),
              mode: PuzzleMode.free,
              game: GameId.minesweeper,
              difficulty: difficulty,
              status: status,
              flagsPlaced: flags,
            ),
          )).newAchievements;
      for (var i = 0; i < 4; i++) {
        await mines(SessionStatus.won);
      }
      await mines(SessionStatus.lost);
      for (var i = 0; i < 4; i++) {
        expect(await mines(SessionStatus.won), isNot(contains(AchievementId.minesFiveInARow)));
      }
      expect(await mines(SessionStatus.won), contains(AchievementId.minesFiveInARow));
      expect(await mines(SessionStatus.won, flags: 0), contains(AchievementId.minesNoFlags));
      expect(await mines(SessionStatus.won, difficulty: 'expert'), contains(AchievementId.minesFirstExpert));
    });

    test('Sopa: 10 temas (el domingo suma tres) y Experto sin pistas', () async {
      Future<List<AchievementId>> words(List<String> themes, {String difficulty = 'easy', int hints = 0}) async =>
          (await service.recordResult(
            session(
              startedAt: at('2026-11-02'),
              mode: PuzzleMode.free,
              game: GameId.wordSearch,
              difficulty: difficulty,
              themeIds: themes,
              freeHints: hints,
            ),
          )).newAchievements;
      await words(['frutas', 'mar', 'aves']);
      for (final t in ['casa', 'ropa', 'clima', 'cuerpo', 'musica', 'granja', 'frutas']) {
        expect(await words([t]), isNot(contains(AchievementId.wordsTenThemes)));
      }
      expect(await words(['colores']), contains(AchievementId.wordsTenThemes));
      expect(await words(['mar'], difficulty: 'expert', hints: 1), isNot(contains(AchievementId.wordsExpertNoHints)));
      expect(await words(['mar'], difficulty: 'expert'), contains(AchievementId.wordsExpertNoHints));
    });

    test('mes completo: 20 días jugados en un mes', () async {
      List<AchievementId> unlocked = [];
      for (var d = 1; d <= 20; d++) {
        unlocked += (await service.recordResult(session(startedAt: at(_iso(2026, 11, d))))).newAchievements;
      }
      expect(unlocked, contains(AchievementId.fullMonth));
    });

    test('10 sin ayuda: las pistas o el rescate no cuentan', () async {
      for (var i = 0; i < 9; i++) {
        await service.recordResult(session(startedAt: at('2026-11-02'), mode: PuzzleMode.free));
      }
      final helped = await service.recordResult(
        session(startedAt: at('2026-11-02'), mode: PuzzleMode.free, freeHints: 1),
      );
      expect(helped.newAchievements, isNot(contains(AchievementId.tenUnassisted)));
      final clean = await service.recordResult(session(startedAt: at('2026-11-02'), mode: PuzzleMode.free));
      expect(clean.newAchievements, contains(AchievementId.tenUnassisted));
    });

    test('el avance se informa para todos, tope en la meta', () async {
      await service.recordResult(session(startedAt: at('2026-11-02'), mode: PuzzleMode.free));
      final list = await service.achievements();
      final byId = {for (final a in list) a.id: a};
      expect(byId[AchievementId.wordsFifty]!.progress, 0);
      expect(byId[AchievementId.firstPuzzle]!.progress, 1);
      expect(byId[AchievementId.firstPuzzle]!.unlockedAt, isNotNull);
      expect(byId[AchievementId.tenUnassisted]!.progress, 1);
    });
  });

  group('maestría, insignias y estadísticas', () {
    test('maestría: Bronce 10, Plata 25, Oro 50 por dificultad', () {
      expect(
        [
          for (final w in [0, 9, 10, 24, 25, 49, 50, 80]) Mastery.forWins(w),
        ],
        [
          Mastery.none,
          Mastery.none,
          Mastery.bronze,
          Mastery.bronze,
          Mastery.silver,
          Mastery.silver,
          Mastery.gold,
          Mastery.gold,
        ],
      );
      expect([Mastery.toNext(0), Mastery.toNext(12), Mastery.toNext(50)], [10, 13, null]);
    });

    test('insignia de mes y dorada con todos los días perfectos', () {
      DailyDay day(int d, {bool perfect = false}) => DailyDay(
        day: LocalDay(2026, 2, d),
        offsetMinutes: -180,
        completed: perfect ? dailyGames.toSet() : {GameId.sudoku},
      );
      expect(ProgressStats.monthBadge([for (var d = 1; d <= 19; d++) day(d)], 2026, 2), MonthBadge.none);
      expect(ProgressStats.monthBadge([for (var d = 1; d <= 20; d++) day(d)], 2026, 2), MonthBadge.earned);
      expect(
        ProgressStats.monthBadge([for (var d = 1; d <= 28; d++) day(d, perfect: true)], 2026, 2),
        MonthBadge.golden,
      );
    });

    test('estadísticas por dificultad: tiempos, % de victorias, rachas y pistas', () async {
      final results = [
        (SessionStatus.won, 5, 0),
        (SessionStatus.won, 3, 1),
        (SessionStatus.lost, 1, 0),
        (SessionStatus.won, 4, 0),
        (SessionStatus.won, 6, 0),
      ];
      for (final (i, (status, minutes, hints)) in results.indexed) {
        await service.recordResult(
          session(
            startedAt: at('2026-11-02', hour: 8 + i),
            mode: PuzzleMode.free,
            game: GameId.minesweeper,
            difficulty: 'intermediate',
            status: status,
            elapsed: Duration(minutes: minutes),
            freeHints: hints,
          ),
        );
      }
      final s = await service.stats(GameId.minesweeper, const Difficulty('intermediate'));
      expect((s.started, s.won, s.lost, s.winRate), (5, 4, 1, 0.8));
      expect((s.bestTime, s.meanTime), (const Duration(minutes: 3), const Duration(minutes: 4, seconds: 30)));
      expect((s.currentWinStreak, s.bestWinStreak, s.unassistedWins, s.hintsUsed), (2, 2, 3, 1));
    });

    test('reiniciar estadísticas de un juego no borra racha, logros ni otros juegos', () async {
      await service.recordResult(session(startedAt: at('2026-11-02', hour: 8)));
      await service.recordResult(
        session(startedAt: at('2026-11-02', hour: 8), game: GameId.minesweeper, difficulty: 'beginner'),
      );
      clock.current = at('2026-11-02', hour: 10);
      await service.resetStats(GameId.sudoku);
      expect((await service.stats(GameId.sudoku, const Difficulty('easy'))).started, 0);
      expect((await service.stats(GameId.minesweeper, const Difficulty('beginner'))).won, 1);
      expect((await repo.streak()).current, 1);
      expect((await repo.unlocked()).containsKey(AchievementId.firstPuzzle), isTrue);
    });

    test('tu semana: los 7 días que terminan hoy', () async {
      for (final (day, minutes) in [('2026-11-01', 9), ('2026-11-02', 4), ('2026-11-08', 3)]) {
        await service.recordResult(
          session(
            startedAt: at(day),
            mode: PuzzleMode.free,
            elapsed: Duration(minutes: minutes),
          ),
        );
      }
      clock.current = at('2026-11-08');
      final week = await service.week();
      expect(week.completedByGame[GameId.sudoku], 2);
      expect(week.time, const Duration(minutes: 7));
      expect(week.bestTimeByGame[GameId.sudoku], const Duration(minutes: 3));
      expect(week.bestTimeByGame.containsKey(GameId.minesweeper), isFalse);
    });

    test('estado de la racha según el reloj', () async {
      await service.recordResult(session(startedAt: at('2026-11-02')));
      clock.current = at('2026-11-05');
      final status = await service.streakStatus();
      expect((status.current, status.previous), (0, 1));
    });
  });
}

String _iso(int y, int m, int d) => DateTime.utc(y, m, d).toIso8601String().substring(0, 10);
