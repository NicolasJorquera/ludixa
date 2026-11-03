import 'package:game_api/game_api.dart';
import 'package:progress/progress.dart';

/// Lo que la pantalla de Resultado necesita saber de la partida recién ganada.
final class FinishedGame {
  const FinishedGame({
    required this.session,
    required this.outcome,
    required this.bestBefore,
    required this.bestAfter,
    required this.winsAtLevel,
    required this.streakBefore,
    required this.streakAfter,
    required this.dailyDone,
  });

  final SessionRecord session;
  final RecordOutcome outcome;
  final Duration? bestAfter;

  /// Partidas ganadas en este juego y nivel, contando esta (maestría).
  final int winsAtLevel;
  final int streakBefore;
  final int streakAfter;

  /// Retos de hoy completados (solo en el reto diario).
  final int dailyDone;

  /// Mejor tiempo del nivel antes de esta partida (null si era la primera).
  final Duration? bestBefore;

  bool get isNewRecord => bestBefore != null && session.elapsed < bestBefore!;
}

/// Servicios de la app para una partida: pistas, guardado en el progreso,
/// pausa y otra partida. Los videos con recompensa llegan en H5: por ahora
/// solo hay pistas gratis y el rescate responde "no disponible".
class AppGameHost implements GameHost {
  AppGameHost({
    required this.service,
    required SessionRecord session,
    required this.onShowPause,
    required this.onWon,
    required this.onPlayAgain,
    this.onChanged,
    this.freeHintsPerPuzzle = 3,
  }) : _session = session,
       _free = freeHintsPerPuzzle;

  final ProgressService service;
  final Future<PauseChoice> Function() onShowPause;
  final void Function(FinishedGame finished) onWon;
  final void Function() onPlayAgain;

  /// Después de guardar o registrar algo en el progreso.
  final void Function()? onChanged;
  final int freeHintsPerPuzzle;

  SessionRecord _session;
  int _free;
  bool _reported = false;

  SessionRecord get session => _session;

  @override
  int get freeHintsLeft => _free;

  @override
  Future<HintGrant> requestHint() async {
    if (_free == 0) return const HintDenied(HintDenial.unavailable);
    _free--;
    return const HintGranted(HintSource.free);
  }

  @override
  Future<RescueOutcome> requestRescue() async => RescueOutcome.unavailable;

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async {
    if (_reported) return;
    _session = _session.withState(snapshot.state, snapshot.elapsed);
    await service.saveInProgress(_session);
    onChanged?.call();
  }

  @override
  Future<void> reportResult(GameResult result) async {
    if (_reported) return;
    _reported = true;
    final before = await service.stats(_session.game, _session.difficulty);
    final streakBefore = (await service.streakStatus()).current;
    final finished = _session.finish(
      status: switch (result.outcome) {
        GameOutcome.won => SessionStatus.won,
        GameOutcome.lost => SessionStatus.lost,
        GameOutcome.abandoned => SessionStatus.abandoned,
      },
      elapsed: result.elapsed,
      completedAt: service.clock.now().utc,
      freeHints: result.freeHintsUsed,
      rewardedHints: result.rewardedHintsUsed,
      rescued: result.rescued,
    );
    final outcome = await service.recordResult(finished);
    _session = finished;
    onChanged?.call();
    if (result.outcome != GameOutcome.won) return;
    final after = await service.stats(_session.game, _session.difficulty);
    final day = finished.challengeDay;
    onWon(
      FinishedGame(
        session: finished,
        outcome: outcome,
        bestBefore: before.bestTime,
        bestAfter: after.bestTime,
        winsAtLevel: ProgressStats.wins(
          await service.repository.sessions(),
          game: finished.game,
          difficulty: finished.difficulty,
        ),
        streakBefore: streakBefore,
        streakAfter: outcome.streak?.state.current ?? streakBefore,
        dailyDone: day == null ? 0 : (await service.repository.day(day))?.completed.length ?? 0,
      ),
    );
  }

  @override
  Future<PauseChoice> showPause() => onShowPause();

  @override
  void playAgain() => onPlayAgain();
}
