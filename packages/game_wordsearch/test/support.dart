import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_api/game_api.dart';
import 'package:game_wordsearch/game_wordsearch.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

class FakeHost implements GameHost {
  FakeHost({this.free = 3});

  int free;
  final snapshots = <SessionSnapshot>[];
  final results = <GameResult>[];

  @override
  int get freeHintsLeft => free;

  @override
  Future<HintGrant> requestHint() async {
    if (free == 0) return const HintDenied(HintDenial.limitReached);
    free--;
    return const HintGranted(HintSource.free);
  }

  @override
  Future<RescueOutcome> requestRescue() async => RescueOutcome.unavailable;

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async => snapshots.add(snapshot);

  @override
  Future<void> reportResult(GameResult result) async => results.add(result);
}

const accentedFruits = ['limón', 'piña', 'melón', 'sandía', 'pera', 'uva'];

WordSearchController controllerFor({
  WordSearchDifficulty level = WordSearchDifficulty.easy,
  FakeHost? host,
  WordSearchSettings settings = const WordSearchSettings(),
}) {
  final puzzle = const WordSearchGenerator().generate(
    themeWords: level == WordSearchDifficulty.easy ? accentedFruits : WordBanks.theme('es', 'frutas').words,
    language: WordLanguage.spanish,
    difficulty: level,
    random: PuzzleSeed.fromKey('prueba-sopa').createRandom(),
  );
  return WordSearchController(
    game: WordSearchGame(puzzle),
    host: host ?? FakeHost(),
    themeNames: const ['Frutas'],
    settings: settings,
  );
}

Widget wrap(Widget child, {Brightness brightness = Brightness.light, Locale locale = const Locale('es')}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLudixaTheme(brightness: brightness),
      locale: locale,
      supportedLocales: WordsLocalizations.supportedLocales,
      localizationsDelegates: const [
        WordsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );

Future<WordSearchController> pumpGame(
  WidgetTester tester, {
  WordSearchController? controller,
  Brightness brightness = Brightness.light,
  Size size = const Size(390, 844),
  bool accessibleNavigation = false,
  VoidCallback? onWon,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final c = controller ?? controllerFor();
  Widget page = WordSearchPage(controller: c, onWon: onWon);
  if (accessibleNavigation) {
    page = Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(accessibleNavigation: true),
        child: WordSearchPage(controller: c, onWon: onWon),
      ),
    );
  }
  await tester.pumpWidget(wrap(page, brightness: brightness));
  await tester.pump();
  return c;
}

Finder cellFinder(WordSearchController c, int i) =>
    find.bySemanticsLabel(RegExp('^Fila ${i ~/ c.size + 1}, columna ${i % c.size + 1}, '));

/// Arrastra de la primera a la última letra de una palabra.
Future<void> dragWord(WidgetTester tester, WordSearchController c, int from, int to) async {
  final start = tester.getCenter(cellFinder(c, from));
  final end = tester.getCenter(cellFinder(c, to));
  final gesture = await tester.startGesture(start);
  for (var k = 1; k <= 8; k++) {
    await gesture.moveTo(Offset.lerp(start, end, k / 8)!);
    await tester.pump();
  }
  await gesture.up();
  await tester.pump();
}
