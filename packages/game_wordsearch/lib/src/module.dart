import 'dart:isolate';

import 'package:daily_challenge/daily_challenge.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:game_api/game_api.dart';
import 'package:puzzle_core/puzzle_core.dart';
import 'package:wordsearch_engine/wordsearch_engine.dart';

import '../l10n/generated/words_localizations.dart';
import 'controller.dart';
import 'settings.dart';
import 'ui/settings_view.dart';
import 'ui/tutorial.dart';
import 'ui/wordsearch_page.dart';

/// Sopa de letras como módulo de la colección.
class WordSearchModule implements GameModule {
  WordSearchModule({WordSearchSettingsStore? store}) : store = store ?? InMemoryWordSearchSettingsStore();

  final WordSearchSettingsStore store;

  @override
  GameId get id => GameId.wordSearch;

  @override
  int get generatorVersion => WordSearchGenerator.version;

  @override
  List<LocalizationsDelegate<Object?>> get localizationsDelegates => WordsLocalizations.localizationsDelegates;

  @override
  String displayName(BuildContext context) => WordsLocalizations.of(context).gameName;

  @override
  Widget buildIcon(BuildContext context, {double size = 24}) => LudixaIcon(LudixaIcons.wordSearch, size: size);

  @override
  List<DifficultyOption> difficulties(BuildContext context) {
    final l10n = WordsLocalizations.of(context);
    return [
      for (final level in WordSearchDifficulty.values)
        DifficultyOption(
          id: Difficulty(level.name),
          label: levelLabel(l10n, level),
          description: switch (level) {
            WordSearchDifficulty.easy => l10n.levelEasyDescription,
            WordSearchDifficulty.medium => l10n.levelMediumDescription,
            WordSearchDifficulty.hard => l10n.levelHardDescription,
            WordSearchDifficulty.expert => l10n.levelExpertDescription,
          },
        ),
    ];
  }

  static String levelLabel(WordsLocalizations l10n, WordSearchDifficulty level) => switch (level) {
    WordSearchDifficulty.easy => l10n.levelEasy,
    WordSearchDifficulty.medium => l10n.levelMedium,
    WordSearchDifficulty.hard => l10n.levelHard,
    WordSearchDifficulty.expert => l10n.levelExpert,
  };

  @override
  DailySpec dailySpec(LocalDay day) =>
      DailySpec(difficulty: Difficulty(DailyLineup.of(day).wordSearch.name), usesWordsLanguage: true);

  /// Idioma de las palabras: el del pedido, el elegido en los ajustes o el
  /// de la app (español o, si no, inglés).
  String wordsLanguageFor(BuildContext context, PuzzleRequest? request) =>
      request?.wordsLanguage ??
      store.load().wordsLanguage ??
      (Localizations.localeOf(context).languageCode == 'es' ? 'es' : 'en');

  @override
  Widget buildGame(BuildContext context, PuzzleRequest request, GameHost host) => WordSearchGameLoader(
    request: request,
    host: host,
    settings: store.load(),
    language: wordsLanguageFor(context, request),
  );

  @override
  Widget buildTutorial(BuildContext context, GameHost host) =>
      WordSearchTutorial(language: wordsLanguageFor(context, null), onDone: () => Navigator.maybePop(context));

  @override
  Widget? buildSettings(BuildContext context) => WordSearchSettingsView(store: store);
}

/// Prepara la sopa (retomada, del reto o generada en otro isolate) y abre la
/// partida.
class WordSearchGameLoader extends StatefulWidget {
  const WordSearchGameLoader({
    super.key,
    required this.request,
    required this.host,
    required this.language,
    this.settings = const WordSearchSettings(),
    this.onWon,
  });

  final PuzzleRequest request;
  final GameHost host;
  final String language;
  final WordSearchSettings settings;
  final VoidCallback? onWon;

  @override
  State<WordSearchGameLoader> createState() => _WordSearchGameLoaderState();
}

class _WordSearchGameLoaderState extends State<WordSearchGameLoader> {
  late final Future<WordSearchController> _controller = _load();

  Future<WordSearchController> _load() async {
    final request = widget.request;
    final resume = request.resumeFrom;
    if (resume != null) return WordSearchController.resume(resume, host: widget.host, settings: widget.settings);
    final language = widget.language;
    final WordSearchPuzzle puzzle;
    final List<String> themeIds;
    if (request.mode == PuzzleMode.free) {
      final key = request.seed.key;
      final level = WordSearchDifficulty.values.byName(request.difficulty.value);
      (puzzle, themeIds) = await Isolate.run(() {
        final random = PuzzleSeed.fromKey(key).createRandom();
        final theme = random.pick(WordBanks.themes(language));
        final puzzle = const WordSearchGenerator().generate(
          themeWords: theme.words,
          language: WordLanguage.byCode(language),
          difficulty: level,
          random: random,
          blocklist: WordBanks.blocklist(language),
        );
        return (puzzle, [theme.id]);
      });
    } else {
      final day = request.day!;
      final daily = DailyChallenge.wordSearch(day, language, today: day);
      puzzle = daily.puzzle;
      themeIds = daily.themeIds;
    }
    return WordSearchController(
      game: WordSearchGame(puzzle),
      host: widget.host,
      settings: widget.settings,
      themeNames: [for (final id in themeIds) WordBanks.theme(language, id).name],
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _controller,
    builder: (context, snapshot) {
      final controller = snapshot.data;
      if (controller == null) {
        if (snapshot.hasError) Error.throwWithStackTrace(snapshot.error!, snapshot.stackTrace!);
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return WordSearchPage(controller: controller, onWon: widget.onWon);
    },
  );
}
