import 'package:monetization/monetization.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:test/test.dart';

/// Reloj local falso.
final class _Clock {
  DateTime now = DateTime(2026, 11, 3, 10);
}

const _min = Duration(minutes: 1);

/// Un puzzle completo: empieza, se juega [length] y se completa.
void _play(AdPolicy policy, {Duration length = const Duration(minutes: 3)}) {
  policy
    ..puzzleStarted()
    ..addActivePlay(length)
    ..puzzleCompleted(length);
}

/// Alguien que ya pasó la primera sesión, completó puzzles de sobra y acaba
/// de ver un intersticial: los contadores parten de cero.
AdPolicy _veteran(_Clock clock) {
  final policy = AdPolicy(now: () => clock.now)..appOpened();
  for (var i = 0; i < 3; i++) {
    _play(policy);
  }
  policy.appOpened(); // segunda sesión
  _play(policy);
  _play(policy);
  expect(policy.decide(AdExit.result), AdDecision.show);
  return policy..interstitialShown();
}

void main() {
  late _Clock clock;
  setUp(() => clock = _Clock());

  group('una regla del PRD por prueba', () {
    test('nunca en la primera sesión, aunque se completen muchos puzzles', () {
      final policy = AdPolicy(now: () => clock.now)..appOpened();
      for (var i = 0; i < 6; i++) {
        _play(policy);
      }
      expect(policy.decide(AdExit.result), AdDecision.firstSession);
      policy.appOpened();
      _play(policy);
      _play(policy);
      expect(policy.decide(AdExit.result), AdDecision.show);
    });

    test('nunca antes de completar 3 puzzles en total', () {
      final policy = AdPolicy(now: () => clock.now)..appOpened();
      _play(policy);
      policy.appOpened();
      _play(policy);
      expect(policy.decide(AdExit.result), AdDecision.tooFewPuzzles);
      _play(policy);
      expect(policy.state.puzzlesTotal, 3);
      expect(policy.decide(AdExit.result), AdDecision.show);
    });

    test('como máximo 1 cada 2 puzzles completados', () {
      final policy = _veteran(clock);
      _play(policy);
      _play(policy);
      expect(policy.decide(AdExit.result), AdDecision.show);
      policy.interstitialShown();
      _play(policy, length: _min * 10);
      expect(policy.decide(AdExit.result), AdDecision.tooFewPuzzlesSinceLast);
      _play(policy);
      expect(policy.decide(AdExit.result), AdDecision.show);
    });

    test('mínimo 4 minutos de juego activo desde el último intersticial', () {
      final policy = _veteran(clock);
      _play(policy, length: const Duration(seconds: 90));
      _play(policy, length: const Duration(seconds: 90));
      expect(policy.decide(AdExit.result), AdDecision.tooLittlePlay);
      policy.addActivePlay(_min); // 4:00 justos
      expect(policy.decide(AdExit.result), AdDecision.show);
      policy.interstitialShown();
      _play(policy, length: _min * 2);
      _play(policy, length: const Duration(seconds: 61)); // 3:01
      expect(policy.decide(AdExit.result), AdDecision.tooLittlePlay);
    });

    test('mínimo 4 minutos desde que se abrió la app: abrirla de nuevo reinicia el tiempo', () {
      final policy = _veteran(clock);
      _play(policy, length: _min * 5);
      policy.appOpened();
      _play(policy, length: _min * 2);
      _play(policy, length: const Duration(seconds: 61));
      expect(policy.state.puzzlesSinceLast, greaterThanOrEqualTo(2));
      expect(policy.decide(AdExit.result), AdDecision.tooLittlePlay);
    });

    test('las partidas de menos de 60 s suman tiempo pero no habilitan por sí solas', () {
      final policy = _veteran(clock);
      for (var i = 0; i < 10; i++) {
        _play(policy, length: const Duration(seconds: 59));
      }
      expect(policy.state.activePlaySinceLast, greaterThan(_min * 4));
      expect(policy.decide(AdExit.result), AdDecision.tooFewPuzzlesSinceLast);
      _play(policy, length: _min);
      _play(policy, length: _min);
      expect(policy.decide(AdExit.result), AdDecision.show);
    });

    test('las partidas cortas tampoco cuentan para los 3 puzzles iniciales', () {
      final policy = AdPolicy(now: () => clock.now)..appOpened();
      for (var i = 0; i < 5; i++) {
        _play(policy, length: const Duration(seconds: 30));
      }
      policy.appOpened();
      _play(policy);
      _play(policy);
      expect(policy.decide(AdExit.result), AdDecision.tooFewPuzzles);
    });

    test('tope de 8 al día; al día siguiente vuelve a haber', () {
      final policy = _veteran(clock); // ya vio 1 hoy
      while (policy.state.shownToday < 8) {
        _play(policy);
        _play(policy);
        expect(policy.decide(AdExit.result), AdDecision.show, reason: 'intersticial ${policy.state.shownToday + 1}');
        policy.interstitialShown();
      }
      _play(policy);
      _play(policy);
      expect(policy.decide(AdExit.result), AdDecision.dailyCap);
      clock.now = DateTime(2026, 11, 4, 0, 1);
      expect(policy.decide(AdExit.result), AdDecision.show);
      policy.interstitialShown();
      expect(policy.state.shownToday, 1);
      expect(policy.state.day, LocalDay(2026, 11, 4));
    });

    test('nunca después de un video con recompensa en ese puzzle', () {
      final policy = _veteran(clock);
      _play(policy);
      policy
        ..puzzleStarted()
        ..addActivePlay(_min * 3)
        ..rewardedShown()
        ..puzzleCompleted(_min * 3);
      expect(policy.decide(AdExit.result), AdDecision.afterRewarded);
      _play(policy); // el siguiente puzzle ya no arrastra el video
      expect(policy.decide(AdExit.result), AdDecision.show);
    });

    test('nunca en el tutorial ni al salir de una partida abandonada', () {
      final policy = _veteran(clock);
      _play(policy);
      _play(policy);
      expect(policy.decide(AdExit.tutorial), AdDecision.tutorial);
      expect(policy.decide(AdExit.abandoned), AdDecision.abandoned);
      expect(policy.decide(AdExit.result), AdDecision.show);
    });
  });

  group('contadores guardados', () {
    test('ida y vuelta en JSON', () {
      final policy = _veteran(clock);
      _play(policy);
      policy.rewardedShown();
      final restored = AdPolicyState.fromJson(policy.state.toJson());
      expect(restored.toJson(), policy.state.toJson());
    });

    test('un archivo dañado solo puede retrasar un anuncio, nunca adelantarlo', () {
      final state = AdPolicyState.fromJson({'sessions': 'muchas', 'puzzlesTotal': null, 'day': 3});
      expect(AdPolicy(now: () => clock.now, state: state).decide(AdExit.result), AdDecision.firstSession);
    });
  });

  test('un día típico (4 puzzles de unos 4 minutos) muestra 1 o 2 intersticiales', () {
    final policy = _veteran(clock);
    var shown = 0;
    for (final minutes in [4, 3, 5, 4]) {
      _play(policy, length: _min * minutes);
      if (policy.decide(AdExit.result) == AdDecision.show) {
        policy.interstitialShown();
        shown++;
      }
    }
    expect(shown, inInclusiveRange(1, 2));
  });
}
