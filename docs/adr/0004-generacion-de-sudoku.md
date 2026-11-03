# ADR 0004: Generación y calificación de Sudoku (H3-03 y H3-04)

- Estado: aceptada
- Fecha: 2026-11-02

## Enfoque

1. **Grilla completa al azar.** `BitSolver.randomSolution` hace una búsqueda con máscaras de bits que elige primero la celda con menos candidatos y prueba los dígitos en orden aleatorio, con PCG32.
2. **Remoción simétrica.** Se quitan pares de celdas con simetría central mientras la solución siga siendo **única** (`countSolutions(limit: 2)`), el **solver humano resuelva el puzzle sin pasarse del nivel pedido** y no se baje del piso de pistas del nivel.
3. **Calificación.** `HumanSolver` aplica siempre la técnica más simple que sirve. El nivel es la técnica más difícil que hizo falta:

   | Nivel | Técnicas |
   |---|---|
   | Fácil | single desnudo, single oculto |
   | Medio | + pointing, claiming |
   | Difícil | + pares y tríos desnudos y ocultos |
   | Experto | + X-Wing, XY-Wing, Swordfish |

   El puzzle se acepta solo si su nivel coincide **exactamente** con el pedido. Si no, se reintenta (hasta 40 veces).

## Cambio respecto del PRD: pistas por nivel

El PRD daba rangos de pistas orientativos (Medio 32–37, etc.). Con esos pisos, casi todos los Medios salían calificados como Fácil (78% de fallos). Como el PRD define la dificultad por la técnica exigida, los pisos quedan así:

| Nivel | Piso de pistas | Pistas resultantes (p50) |
|---|---|---|
| Fácil | 38–45 | 42 |
| Medio | 26–30 | 28 |
| Difícil | 24–28 | 28 |
| Experto | 22–26 | 28 |

## Resultados

Benchmark AOT (`tool/benchmark.dart`), 1.000 puzzles por nivel, Apple M4. El tiempo corresponde a los puzzles aceptados.

| Nivel | p50 | p95 | máx | Sin puzzle tras 40 intentos |
|---|---|---|---|---|
| Fácil | 0,3 ms | 0,6 ms | 1,3 ms | 0% |
| Medio | 6,0 ms | 20,0 ms | 75 ms | 7,2% |
| Difícil | 12,7 ms | 36,0 ms | 95 ms | 23,2% |
| Experto | 11,2 ms | 32,9 ms | 57 ms | 10,1% |

Un fallo cuesta unos 30 ms en el M4. En un teléfono de gama baja, que estimo entre 10 y 20 veces más lento, un Difícil puede tardar medio segundo o más.

## Decisiones

1. **Partida libre:** se genera en un isolate, con un presupuesto de tiempo, y se pregenera el siguiente puzzle mientras se juega. Si se agota el presupuesto o hay `SudokuGenerationFailed`, se usa el **banco pregenerado** (H3-07).
2. **Reto diario: sale del banco pregenerado**, elegido por la semilla del día. Generarlo en el teléfono con un presupuesto de tiempo daría puzzles distintos según la velocidad del dispositivo. El banco es instantáneo e idéntico para todos. Se concreta en H3-07 y H3-08.
3. **Pistas:** `SudokuHinter` señala primero un número equivocado. Si no hay, razona desde lo colocado hasta la primera celda que se puede llenar e informa la técnica decisiva (la más difícil de ese tramo), su patrón y sus unidades.
4. **Versión del generador:** `SudokuGenerator.version = 1`.

## Pendiente

- La distinción "Medio alto" del reto de viernes y sábado (mitad superior del rango de Medio) necesita un puntaje dentro del nivel. Se define en H3-08.
- Medir en un teléfono real (H7-03).
