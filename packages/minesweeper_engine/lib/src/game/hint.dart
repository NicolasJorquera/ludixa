/// Por qué una pista señala una celda. La interfaz traduce cada motivo a una
/// frase ("Este 2 ya tiene sus 2 minas: el resto de sus vecinas son seguras").
enum HintReason {
  /// Una bandera del jugador está en una celda sin mina.
  wrongFlag,

  /// Un número ya tiene todas sus minas marcadas: sus otras vecinas son seguras.
  numberSatisfied,

  /// A un número le faltan tantas minas como vecinas sin revelar: todas son minas.
  numberNeedsAll,

  /// Comparando dos números vecinos se deduce la celda.
  twoNumbers,

  /// Por el conteo de minas restantes.
  mineCount,

  /// Respaldo: no hay deducción con estas reglas desde lo que se ve (no
  /// debería pasar en un tablero sin adivinanzas). Se revela una celda segura.
  safeReveal,
}

/// Pista: una celda que se puede deducir y por qué.
final class MinesweeperHint {
  const MinesweeperHint({required this.cell, required this.isMine, required this.reason, this.sources = const []});

  final int cell;

  /// Si la celda es una mina (poner bandera) o es segura (revelar).
  /// En [HintReason.wrongFlag] es falso: hay que quitar la bandera.
  final bool isMine;

  final HintReason reason;

  /// Números que justifican la deducción, para resaltarlos.
  final List<int> sources;
}
