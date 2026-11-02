# ADR 0002: Generación de Buscaminas sin adivinar (prueba técnica H3-01)

- Estado: aceptada
- Fecha: 2026-11-02

## Pregunta

¿Se pueden generar en el dispositivo, a tiempo, tableros que se resuelvan siempre sin adivinar, incluido el nivel Experto (16×30, 99 minas) en teléfonos de gama baja?

## Enfoque probado

1. Se colocan las minas al azar, con PCG32 y una semilla, fuera de la zona de 3×3 de la celda de inicio. El primer toque siempre abre una zona.
2. Un **solver por reglas** (`RuleSolver`) simula a un jugador que solo deduce: regla de un número, regla de dos números (cotas sobre la intersección) y conteo global.
3. Si despeja el tablero completo, se acepta. Si no, se vuelven a colocar las minas.
4. Un **verificador exacto independiente** (`ExactSolver`) enumera todas las configuraciones compatibles por componente de la frontera y las combina con el conteo global. Es la deducción más fuerte posible. Se usa en pruebas y herramientas, no en el dispositivo.

Ambos solvers trabajan sobre `SolveState`, que lanza `UnsoundDeduction` si alguno revela una mina o marca una celda libre. Así, cualquier deducción incorrecta hace fallar la prueba.

## Resultados

Benchmark AOT (`tool/benchmark.dart`), 20.000 tableros por nivel con semilla y celda de inicio distintas, en un Apple M4:

| Nivel | p50 | p95 | p99 | máx | Intentos (media / p95 / máx) | Verificador exacto |
|---|---|---|---|---|---|---|
| Principiante 9×9/10 | 0,0 ms | 0,0 ms | 0,1 ms | 4,6 ms | 1,2 / 2 / 7 | 20.000 resueltos |
| Intermedio 16×16/40 | 0,1 ms | 0,3 ms | 0,5 ms | 9,8 ms | 1,6 / 4 / 11 | 20.000 resueltos |
| Experto 16×30/99 | 2,0 ms | 8,5 ms | 13,6 ms | 55,2 ms | 10,2 / 30 / 106 | 20.000 resueltos |

0 fallos de generación y 0 tableros que exijan adivinar en 60.000.

**Estimación en gama baja:** un teléfono Android de entrada rinde entre 10 y 20 veces menos que un M4 en un solo núcleo (estimación, no medida). Eso daría un p95 de Experto de unos 85 a 170 ms y un máximo cercano a 1 s en el peor caso. El criterio (p95 < 1 s) se cumple con margen, pero **debe confirmarse en un teléfono real en H7-03**.

## Decisiones

1. **Se mantiene el enfoque simple de reintentar.** No hace falta la reubicación incremental de minas (estilo Simon Tatham) ni un banco pregenerado de Buscaminas. Queda como plan B si la medición en el dispositivo no cumple.
2. **La generación igual corre en un `Isolate`** (`Isolate.run`) para no arriesgar fotogramas perdidos en el peor caso.
3. **Reto diario con celda de inicio fija.** Generar después del primer toque haría que cada jugador recibiera un tablero distinto. En el reto diario, la celda de inicio también sale de la semilla (`generateDaily`) y la interfaz la señala ("Empieza aquí"). En partida libre se mantiene el comportamiento clásico: el tablero se genera tras el primer toque, donde sea. Esto agrega un estado a la ficha UX del Buscaminas en el reto diario.
4. **Versión del generador:** `NoGuessGenerator.version = 1`. Cualquier cambio que altere los tableros de una semilla debe subirla.

## Consecuencias

- En CI: 300, 150 y 40 tableros por nivel verificados en cada PR. La corrida de 20.000 queda para el workflow nocturno (H3-09).
- El `RuleSolver` es la base de las pistas de H3-02: cada deducción corresponde a una regla explicable ("este 2 ya tiene sus 2 minas").
