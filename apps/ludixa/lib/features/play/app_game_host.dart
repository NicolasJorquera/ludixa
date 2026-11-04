import 'dart:async';
import 'dart:math' as math;

import 'package:game_api/game_api.dart';
import 'package:monetization/monetization.dart';
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

/// Lo que se le ofrece al jugador cuando se acabaron las pistas gratis.
final class HintOffer {
  const HintOffer({required this.videoReady, required this.videosLeft, required this.courtesyAvailable});

  final bool videoReady;

  /// Pistas con video que quedan en este puzzle.
  final int videosLeft;

  /// Sin video, queda la pista de cortesía del día.
  final bool courtesyAvailable;
}

enum HintOfferChoice { video, courtesy, cancel }

/// Videos y cortesía para el host: los da la app (anuncios y la hoja que
/// pregunta al jugador). Las pruebas usan uno falso.
abstract interface class RewardedHints {
  bool get videoReady;
  Future<RewardedOutcome> showVideo();
  bool get courtesyAvailable;
  void useCourtesy();
  Future<HintOfferChoice> offerHint(HintOffer offer);
}

/// Servicios de la app para una partida: pistas, guardado en el progreso,
/// pausa y otra partida.
///
/// Economía de pistas (PRD, H6-04): 2 gratis por puzzle; después, hasta 3
/// más viendo un video completo. Sin video disponible, 1 pista de cortesía
/// al día. El rescate del Buscaminas es siempre con video (el botón lo dice).
///
/// Guardado (H5-03): los juegos mandan una instantánea en cada jugada. El
/// host escribe la última cada [saveDelay] y de inmediato en segundo plano,
/// donde el sistema puede matar la app en cualquier momento. Las escrituras
/// van en cola, y el resultado espera a la última para que una instantánea
/// atrasada nunca pise una partida ya terminada.
class AppGameHost implements GameHost {
  AppGameHost({
    required this.service,
    required SessionRecord session,
    required this.onShowPause,
    required this.onWon,
    required this.onPlayAgain,
    this.onChanged,
    this.onPlayed,
    this.onCompleted,
    this.rewards,
    this.freeHintsPerPuzzle = freeHints,
    this.rewardedHintsPerPuzzle = videoHints,
    this.saveDelay = const Duration(milliseconds: 300),
  }) : _session = session,
       _lastElapsed = session.elapsed,
       _countedPlay = session.elapsed,
       // Al retomar, las pistas ya usadas no vuelven.
       _free = math.max(0, freeHintsPerPuzzle - session.freeHints),
       _rewardedUsed = session.rewardedHints;

  final ProgressService service;
  final Future<PauseChoice> Function() onShowPause;
  final void Function(FinishedGame finished) onWon;
  final void Function() onPlayAgain;

  /// Después de guardar o registrar algo en el progreso.
  final void Function()? onChanged;

  /// Tiempo jugado desde el último aviso (para la política de anuncios):
  /// al terminar y al cerrar la partida, también si se abandona.
  final void Function(Duration played)? onPlayed;

  /// Puzzle ganado, con su tiempo.
  final void Function(Duration elapsed)? onCompleted;

  /// Límites del PRD por puzzle.
  static const freeHints = 2;
  static const videoHints = 3;

  /// Sin [rewards] (tutorial, pruebas) no hay videos ni cortesía.
  final RewardedHints? rewards;

  Duration _lastElapsed;
  Duration _countedPlay;
  final int freeHintsPerPuzzle;
  final int rewardedHintsPerPuzzle;
  final Duration saveDelay;

  SessionRecord _session;
  int _free;

  /// Pistas con video o de cortesía usadas en este puzzle.
  int _rewardedUsed;

  SessionSnapshot? _pending;
  Timer? _saveTimer;
  Future<void> _writes = Future.value();
  bool _background = false;
  bool _reported = false;

  SessionRecord get session => _session;

  @override
  int get freeHintsLeft => _free;

  @override
  bool get rewardedAvailable => rewards?.videoReady ?? false;

  @override
  Future<HintGrant> requestHint() async {
    if (_free > 0) {
      _free--;
      return const HintGranted(HintSource.free);
    }
    if (_rewardedUsed >= rewardedHintsPerPuzzle) return const HintDenied(HintDenial.limitReached);
    final rewards = this.rewards;
    if (rewards == null) return const HintDenied(HintDenial.unavailable);
    final videoReady = rewards.videoReady;
    final choice = await rewards.offerHint(
      HintOffer(
        videoReady: videoReady,
        videosLeft: rewardedHintsPerPuzzle - _rewardedUsed,
        courtesyAvailable: !videoReady && rewards.courtesyAvailable,
      ),
    );
    switch (choice) {
      case HintOfferChoice.cancel:
        return const HintDenied(HintDenial.declined);
      case HintOfferChoice.courtesy:
        if (videoReady || !rewards.courtesyAvailable) return const HintDenied(HintDenial.unavailable);
        rewards.useCourtesy();
        _rewardedUsed++;
        return const HintGranted(HintSource.courtesy);
      case HintOfferChoice.video:
        // La pista solo se entrega si el video se vio completo.
        final outcome = await rewards.showVideo();
        if (outcome != RewardedOutcome.earned) {
          return HintDenied(outcome == RewardedOutcome.dismissed ? HintDenial.declined : HintDenial.unavailable);
        }
        _rewardedUsed++;
        return const HintGranted(HintSource.rewarded);
    }
  }

  /// El botón "Deshacer con video" ya dice qué pasa: no se pregunta otra vez.
  @override
  Future<RescueOutcome> requestRescue() async {
    final rewards = this.rewards;
    if (rewards == null || !rewards.videoReady) return RescueOutcome.unavailable;
    return switch (await rewards.showVideo()) {
      RewardedOutcome.earned => RescueOutcome.granted,
      RewardedOutcome.dismissed => RescueOutcome.declined,
      RewardedOutcome.unavailable => RescueOutcome.unavailable,
    };
  }

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) {
    if (_reported) return _writes;
    _lastElapsed = snapshot.elapsed;
    _pending = snapshot;
    if (_background) return flush();
    _saveTimer ??= Timer(saveDelay, () => unawaited(flush()));
    return _writes;
  }

  /// La app pasó a segundo plano: se escribe ya y cada instantánea siguiente
  /// también, sin esperar.
  Future<void> enterBackground() {
    _background = true;
    return flush();
  }

  void enterForeground() => _background = false;

  /// Al cerrar la partida sin terminarla: avisa el tiempo jugado.
  void close() {
    if (!_reported) _settlePlay(_lastElapsed);
  }

  void _settlePlay(Duration elapsed) {
    final played = elapsed - _countedPlay;
    _countedPlay = elapsed;
    if (played > Duration.zero) onPlayed?.call(played);
  }

  /// Escribe la última instantánea pendiente, si hay. Se espera junto con
  /// las anteriores, en orden.
  Future<void> flush() {
    _saveTimer?.cancel();
    _saveTimer = null;
    final snapshot = _pending;
    _pending = null;
    if (snapshot == null || _reported) return _writes;
    return _writes = _writes.then((_) async {
      if (_reported) return;
      _session = _session.withState(
        snapshot.state,
        snapshot.elapsed,
        freeHints: snapshot.freeHintsUsed,
        rewardedHints: snapshot.rewardedHintsUsed,
      );
      await service.saveInProgress(_session);
      onChanged?.call();
    });
  }

  @override
  Future<void> reportResult(GameResult result) async {
    if (_reported) return;
    _reported = true;
    _saveTimer?.cancel();
    _pending = null;
    _settlePlay(result.elapsed);
    if (result.outcome == GameOutcome.won) onCompleted?.call(result.elapsed);
    await _writes;
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
      flagsPlaced: result.flagsPlaced,
      themeIds: result.themeIds.isEmpty ? null : result.themeIds,
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
          await service.repository.sessionSummaries(),
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
