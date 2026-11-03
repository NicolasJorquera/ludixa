import 'geometry.dart';
import 'puzzle.dart';

/// Resultado de una selección del jugador.
enum SelectionOutcome {
  /// Encontró una palabra nueva.
  found,

  /// Ya estaba encontrada.
  alreadyFound,

  /// No coincide con ninguna palabra (o no es una línea recta).
  miss,
}

/// Pista: dónde empieza una palabra pendiente y hacia dónde sigue.
final class WordSearchHint {
  const WordSearchHint({required this.wordIndex, required this.startCell, required this.nextCell});

  /// Índice en [WordSearchPuzzle.placements].
  final int wordIndex;

  /// Primera letra (primer toque de pista).
  final int startCell;

  /// Segunda letra: indica la dirección (segundo toque).
  final int nextCell;
}

/// Partida de Sopa de letras: selección, palabras encontradas, pistas y guardado.
final class WordSearchGame {
  WordSearchGame(this.puzzle) : _found = <int>[];

  WordSearchGame._(this.puzzle, this._found);

  final WordSearchPuzzle puzzle;
  final List<int> _found;

  /// Índices de palabras encontradas, en el orden en que se encontraron.
  List<int> get foundOrder => List.unmodifiable(_found);

  bool isFound(int wordIndex) => _found.contains(wordIndex);

  bool get isComplete => _found.length == puzzle.placements.length;

  int get remaining => puzzle.placements.length - _found.length;

  /// Celdas en línea recta entre [from] y [to], incluidas; vacío si no es
  /// horizontal, vertical ni diagonal. La interfaz las usa para pintar la
  /// selección mientras se arrastra.
  List<int> lineBetween(int from, int to) {
    final size = puzzle.size;
    if (from == to) return [from];
    final direction = WordDirection.between(from ~/ size, from % size, to ~/ size, to % size);
    if (direction == null) return const [];
    final steps = ((to ~/ size) - (from ~/ size)).abs() > ((to % size) - (from % size)).abs()
        ? ((to ~/ size) - (from ~/ size)).abs()
        : ((to % size) - (from % size)).abs();
    return [
      for (var k = 0; k <= steps; k++) (from ~/ size + direction.dRow * k) * size + from % size + direction.dColumn * k,
    ];
  }

  /// Valida una selección de [from] a [to]. Una palabra cuenta en cualquiera
  /// de los dos sentidos.
  ({SelectionOutcome outcome, int? wordIndex}) select(int from, int to) {
    final line = lineBetween(from, to);
    if (line.length < 2) return (outcome: SelectionOutcome.miss, wordIndex: null);
    for (var i = 0; i < puzzle.placements.length; i++) {
      final cells = puzzle.placements[i].cells;
      if (cells.length != line.length) continue;
      final forward = _sameCells(cells, line);
      final backward = _sameCells(cells.reversed.toList(), line);
      if (!forward && !backward) continue;
      if (_found.contains(i)) return (outcome: SelectionOutcome.alreadyFound, wordIndex: i);
      _found.add(i);
      return (outcome: SelectionOutcome.found, wordIndex: i);
    }
    return (outcome: SelectionOutcome.miss, wordIndex: null);
  }

  /// Pista para la primera palabra pendiente de la lista.
  WordSearchHint? hint() {
    for (var i = 0; i < puzzle.placements.length; i++) {
      if (_found.contains(i)) continue;
      final p = puzzle.placements[i];
      return WordSearchHint(wordIndex: i, startCell: p.start, nextCell: p.cellAt(1));
    }
    return null;
  }

  static bool _sameCells(List<int> a, List<int> b) {
    for (var k = 0; k < a.length; k++) {
      if (a[k] != b[k]) return false;
    }
    return true;
  }

  static const _version = 1;

  Map<String, Object?> toJson() => {'v': _version, 'puzzle': puzzle.toJson(), 'found': _found};

  factory WordSearchGame.fromJson(Map<String, Object?> json) {
    if (json['v'] != _version) throw FormatException('Versión de guardado no soportada: ${json['v']}');
    final puzzle = WordSearchPuzzle.fromJson((json['puzzle']! as Map).cast<String, Object?>());
    final found = (json['found']! as List).cast<int>().toList();
    if (found.any((i) => i < 0 || i >= puzzle.placements.length)) throw const FormatException('Palabra inválida');
    return WordSearchGame._(puzzle, found);
  }
}
