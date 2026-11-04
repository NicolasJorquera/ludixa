import 'package:puzzle_core/puzzle_core.dart';

/// Límites del PRD para los intersticiales. Cambiar un límite es cambiar una
/// constante, con su prueba.
final class AdLimits {
  const AdLimits({
    this.minPuzzlesTotal = 3,
    this.puzzlesBetween = 2,
    this.minActivePlay = const Duration(minutes: 4),
    this.shortGame = const Duration(seconds: 60),
    this.dailyCap = 8,
  });

  /// Puzzles completados en total antes del primer intersticial.
  final int minPuzzlesTotal;

  /// Como máximo 1 intersticial cada [puzzlesBetween] puzzles completados.
  final int puzzlesBetween;

  /// Juego activo mínimo desde el último intersticial o desde que se abrió
  /// la app.
  final Duration minActivePlay;

  /// Las partidas más cortas suman tiempo, pero no cuentan como puzzle para
  /// habilitar un intersticial.
  final Duration shortGame;

  /// Intersticiales como máximo por día local.
  final int dailyCap;
}

/// Desde dónde se pregunta. El intersticial solo se considera al salir de la
/// pantalla de Resultado; el tutorial y las partidas abandonadas nunca.
enum AdExit { result, tutorial, abandoned }

/// Por qué no se muestra un intersticial (o que sí se puede).
enum AdDecision {
  show,
  firstSession,
  tooFewPuzzles,
  tooFewPuzzlesSinceLast,
  tooLittlePlay,
  dailyCap,
  afterRewarded,
  tutorial,
  abandoned,
}

/// Contadores de la política. Se guardan en las preferencias del
/// dispositivo y no se exportan con el progreso.
final class AdPolicyState {
  const AdPolicyState({
    this.sessions = 0,
    this.puzzlesTotal = 0,
    this.puzzlesSinceLast = 0,
    this.activePlaySinceLast = Duration.zero,
    this.shownToday = 0,
    this.day,
    this.rewardedThisPuzzle = false,
    this.courtesyDay,
  });

  /// Veces que se abrió la app (la primera sesión es la 1).
  final int sessions;
  final int puzzlesTotal;
  final int puzzlesSinceLast;

  /// Juego activo desde el último intersticial o desde que se abrió la app.
  final Duration activePlaySinceLast;
  final int shownToday;

  /// Día local al que corresponde [shownToday].
  final LocalDay? day;

  /// Hubo un video con recompensa en el puzzle en curso.
  final bool rewardedThisPuzzle;

  /// Día local en que se usó la pista de cortesía (1 al día).
  final LocalDay? courtesyDay;

  AdPolicyState copyWith({
    int? sessions,
    int? puzzlesTotal,
    int? puzzlesSinceLast,
    Duration? activePlaySinceLast,
    int? shownToday,
    LocalDay? day,
    bool? rewardedThisPuzzle,
    LocalDay? courtesyDay,
  }) => AdPolicyState(
    sessions: sessions ?? this.sessions,
    puzzlesTotal: puzzlesTotal ?? this.puzzlesTotal,
    puzzlesSinceLast: puzzlesSinceLast ?? this.puzzlesSinceLast,
    activePlaySinceLast: activePlaySinceLast ?? this.activePlaySinceLast,
    shownToday: shownToday ?? this.shownToday,
    day: day ?? this.day,
    rewardedThisPuzzle: rewardedThisPuzzle ?? this.rewardedThisPuzzle,
    courtesyDay: courtesyDay ?? this.courtesyDay,
  );

  Map<String, Object?> toJson() => {
    'sessions': sessions,
    'puzzlesTotal': puzzlesTotal,
    'puzzlesSinceLast': puzzlesSinceLast,
    'activePlayMs': activePlaySinceLast.inMilliseconds,
    'shownToday': shownToday,
    'day': day?.toIso8601(),
    'rewardedThisPuzzle': rewardedThisPuzzle,
    'courtesyDay': courtesyDay?.toIso8601(),
  };

  /// Valores que falten o tengan otro tipo vuelven a cero: perder un contador
  /// solo puede retrasar un anuncio, nunca adelantarlo.
  factory AdPolicyState.fromJson(Map<String, Object?> json) {
    int count(String key) => json[key] is int ? json[key]! as int : 0;
    final day = json['day'];
    final courtesyDay = json['courtesyDay'];
    return AdPolicyState(
      sessions: count('sessions'),
      puzzlesTotal: count('puzzlesTotal'),
      puzzlesSinceLast: count('puzzlesSinceLast'),
      activePlaySinceLast: Duration(milliseconds: count('activePlayMs')),
      shownToday: count('shownToday'),
      day: _dayOf(day),
      rewardedThisPuzzle: json['rewardedThisPuzzle'] == true,
      courtesyDay: _dayOf(courtesyDay),
    );
  }
}

/// Los límites del PRD para los intersticiales (Modelo publicitario):
///
/// - Nunca en la primera sesión ni antes de completar 3 puzzles en total.
/// - Como máximo 1 cada 2 puzzles completados.
/// - Mínimo 4 minutos de juego activo desde el último intersticial o desde
///   que se abrió la app.
/// - Las partidas de menos de 60 s suman tiempo, pero no habilitan un
///   intersticial por sí solas.
/// - Tope de 8 al día.
/// - Nunca después de un video con recompensa, en el tutorial ni al salir de
///   una partida abandonada.
///
/// Dart puro y con el reloj inyectado: se prueba con escenarios. La app
/// guarda [state] en las preferencias después de cada cambio.
final class AdPolicy {
  AdPolicy({required this.now, AdPolicyState state = const AdPolicyState(), this.limits = const AdLimits()})
    : _state = state;

  /// Hora local del dispositivo (para el tope diario).
  final DateTime Function() now;
  final AdLimits limits;
  AdPolicyState _state;

  AdPolicyState get state => _state;

  LocalDay get _today => LocalDay.fromDateTime(now());

  /// Al abrir la app: una sesión más, y el tiempo de juego vuelve a contar
  /// desde cero.
  void appOpened() => _state = _state.copyWith(sessions: _state.sessions + 1, activePlaySinceLast: Duration.zero);

  /// Empieza un puzzle: un video visto en el anterior ya no cuenta.
  void puzzleStarted() => _state = _state.copyWith(rewardedThisPuzzle: false);

  /// Tiempo de juego activo, de cualquier partida (también las abandonadas).
  void addActivePlay(Duration played) =>
      _state = _state.copyWith(activePlaySinceLast: _state.activePlaySinceLast + played);

  /// Un puzzle completado. Los de menos de 60 s no cuentan como puzzle.
  void puzzleCompleted(Duration elapsed) {
    if (elapsed < limits.shortGame) return;
    _state = _state.copyWith(puzzlesTotal: _state.puzzlesTotal + 1, puzzlesSinceLast: _state.puzzlesSinceLast + 1);
  }

  /// Se vio un video con recompensa en el puzzle en curso.
  void rewardedShown() => _state = _state.copyWith(rewardedThisPuzzle: true);

  /// ¿Se puede mostrar un intersticial al salir por [exit]? Si no, el motivo.
  AdDecision decide(AdExit exit) {
    if (exit == AdExit.tutorial) return AdDecision.tutorial;
    if (exit == AdExit.abandoned) return AdDecision.abandoned;
    if (_state.sessions <= 1) return AdDecision.firstSession;
    if (_state.rewardedThisPuzzle) return AdDecision.afterRewarded;
    if (_state.puzzlesTotal < limits.minPuzzlesTotal) return AdDecision.tooFewPuzzles;
    if (_state.puzzlesSinceLast < limits.puzzlesBetween) return AdDecision.tooFewPuzzlesSinceLast;
    if (_state.activePlaySinceLast < limits.minActivePlay) return AdDecision.tooLittlePlay;
    if (_shownToday >= limits.dailyCap) return AdDecision.dailyCap;
    return AdDecision.show;
  }

  int get _shownToday => _state.day == _today ? _state.shownToday : 0;

  /// Pista de cortesía: 1 al día cuando no hay videos (PRD).
  bool get courtesyAvailable => _state.courtesyDay != _today;

  void courtesyUsed() => _state = _state.copyWith(courtesyDay: _today);

  /// Se mostró un intersticial: los contadores vuelven a empezar.
  void interstitialShown() => _state = _state.copyWith(
    puzzlesSinceLast: 0,
    activePlaySinceLast: Duration.zero,
    shownToday: _shownToday + 1,
    day: _today,
  );
}

LocalDay? _dayOf(Object? value) {
  if (value is! String) return null;
  try {
    return LocalDay.parse(value);
  } on FormatException {
    return null;
  }
}
