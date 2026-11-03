import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:puzzle_core/puzzle_core.dart';

/// Host de prueba que registra lo que le pide el módulo.
class _RecordingHost implements GameHost {
  _RecordingHost(this.hintAnswer);

  final HintGrant hintAnswer;
  final snapshots = <SessionSnapshot>[];
  final results = <GameResult>[];
  int hintRequests = 0;

  @override
  Future<HintGrant> requestHint() async {
    hintRequests++;
    return hintAnswer;
  }

  @override
  int get freeHintsLeft => 3;

  int pauses = 0;
  PauseChoice pauseAnswer = PauseChoice.resume;
  int playAgainRequests = 0;

  @override
  Future<PauseChoice> showPause() async {
    pauses++;
    return pauseAnswer;
  }

  @override
  void playAgain() => playAgainRequests++;

  @override
  Future<RescueOutcome> requestRescue() async => RescueOutcome.declined;

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async => snapshots.add(snapshot);

  @override
  Future<void> reportResult(GameResult result) async => results.add(result);
}

/// Módulo mínimo que usa el contrato completo: pide pista, guarda y termina.
class _ProbeModule implements GameModule {
  @override
  GameId get id => const GameId('probe');

  @override
  int get generatorVersion => 1;

  @override
  List<LocalizationsDelegate<Object?>> get localizationsDelegates => const [];

  @override
  String displayName(BuildContext context) => 'Probe';

  @override
  Widget buildIcon(BuildContext context, {double size = 24}) => SizedBox.square(dimension: size);

  @override
  List<DifficultyOption> difficulties(BuildContext context) => const [
    DifficultyOption(id: Difficulty('easy'), label: 'Easy', description: '1 min'),
  ];

  @override
  DailySpec dailySpec(LocalDay day) => const DailySpec(difficulty: Difficulty('easy'));

  @override
  String difficultyLabel(BuildContext context, Difficulty difficulty) => difficulty.value;

  @override
  String? dailyDetail(BuildContext context, LocalDay day) => null;

  @override
  Widget buildGame(BuildContext context, PuzzleRequest request, GameHost host) => _ProbeGame(request, host);

  @override
  Widget buildTutorial(BuildContext context, GameHost host) => const SizedBox.shrink();

  @override
  Widget? buildSettings(BuildContext context) => null;
}

class _ProbeGame extends StatefulWidget {
  const _ProbeGame(this.request, this.host);

  final PuzzleRequest request;
  final GameHost host;

  @override
  State<_ProbeGame> createState() => _ProbeGameState();
}

class _ProbeGameState extends State<_ProbeGame> {
  int _freeHints = 0;
  String _status = 'playing';

  Future<void> _hint() async {
    final grant = await widget.host.requestHint();
    setState(() {
      switch (grant) {
        case HintGranted(source: HintSource.free):
          _freeHints++;
          _status = 'hint:free';
        case HintGranted(:final source):
          _status = 'hint:${source.name}';
        case HintDenied(:final reason):
          _status = 'denied:${reason.name}';
      }
    });
  }

  Future<void> _finish() async {
    await widget.host.saveSnapshot(const SessionSnapshot(state: {'cells': 81}, elapsed: Duration(seconds: 30)));
    await widget.host.reportResult(
      GameResult(outcome: GameOutcome.won, elapsed: const Duration(seconds: 30), freeHintsUsed: _freeHints),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_status),
        TextButton(onPressed: _hint, child: const Text('hint')),
        TextButton(onPressed: _finish, child: const Text('finish')),
      ],
    );
  }
}

void main() {
  final request = PuzzleRequest(
    mode: PuzzleMode.daily,
    difficulty: const Difficulty('easy'),
    seed: PuzzleSeed.daily(day: LocalDay(2026, 11, 2), game: const GameId('probe'), generatorVersion: 1),
    day: LocalDay(2026, 11, 2),
  );

  Future<void> pumpGame(WidgetTester tester, GameHost host) {
    final module = _ProbeModule();
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Builder(builder: (context) => module.buildGame(context, request, host))),
      ),
    );
  }

  testWidgets('un módulo pide pista, guarda e informa el resultado a través del host', (tester) async {
    final host = _RecordingHost(const HintGranted(HintSource.free));
    await pumpGame(tester, host);

    await tester.tap(find.text('hint'));
    await tester.pump();
    expect(find.text('hint:free'), findsOneWidget);

    await tester.tap(find.text('finish'));
    await tester.pump();

    expect(host.hintRequests, 1);
    expect(host.snapshots.single.state, {'cells': 81});
    expect(host.results.single.outcome, GameOutcome.won);
    expect(host.results.single.assisted, isTrue);
  });

  testWidgets('el módulo reacciona a una pista denegada', (tester) async {
    final host = _RecordingHost(const HintDenied(HintDenial.declined));
    await pumpGame(tester, host);

    await tester.tap(find.text('hint'));
    await tester.pump();
    expect(find.text('denied:declined'), findsOneWidget);
  });

  group('GameResult.assisted', () {
    test('es falso solo sin pistas ni rescate', () {
      expect(const GameResult(outcome: GameOutcome.won, elapsed: Duration.zero).assisted, isFalse);
      expect(const GameResult(outcome: GameOutcome.won, elapsed: Duration.zero, rewardedHintsUsed: 1).assisted, isTrue);
      expect(const GameResult(outcome: GameOutcome.won, elapsed: Duration.zero, rescued: true).assisted, isTrue);
    });
  });

  test('un reto exige su día', () {
    expect(
      () => PuzzleRequest(mode: PuzzleMode.daily, difficulty: const Difficulty('easy'), seed: PuzzleSeed.fromKey('x')),
      throwsAssertionError,
    );
  });
}
