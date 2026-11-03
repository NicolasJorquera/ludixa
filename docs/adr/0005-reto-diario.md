# ADR 0005: Especificación del reto diario (H3-08)

- Estado: aceptada
- Fecha: 2026-11-03

## Contexto

El PRD define tres retos por día, uno por juego, con dificultad que sube de lunes a domingo, generados sin servidor e idénticos para todos los jugadores. Faltaba concretar la semilla, el "Medio alto" del Sudoku, el tema de la sopa y qué pasa con fechas futuras.

## Decisiones

1. **Paquete propio `packages/daily_challenge`**, en Dart puro. Depende de los tres motores. La app lo usará en H4-07. Así los goldens se prueban con `dart test`, sin Flutter.
2. **Calendario** (`DailyLineup.of`), igual que el PRD:

   | Día | Sudoku | Buscaminas | Sopa de letras |
   |---|---|---|---|
   | Lun–Mar | Fácil | Principiante (9×9, 10) | Fácil · tema del día |
   | Mié–Jue | Medio | Intermedio reducido (12×12, 22) | Medio · tema del día |
   | Vie–Sáb | Medio alto | Intermedio (16×16, 40) | Difícil · tema del día |
   | Dom | Difícil | Intermedio (16×16, 40) | Difícil · tema especial |

3. **Semilla**: `daily|AAAA-MM-DD|juego|v<versión>` y, en la sopa, `|<idioma>`. La versión de cada juego vive en `DailyChallenge` (`sudokuVersion`, `minesweeperVersion`, `wordSearchVersion`). Una prueba fija las versiones de los motores y del banco: si una cambia, obliga a revisar la del reto y regenerar los goldens.
4. **Sudoku**: sale del banco pregenerado (ADR 0004) elegido con la semilla del día.
5. **"Medio alto"**: el PRD lo define como un Medio en la mitad superior de su rango. El puntaje elegido es cuántas veces hay que usar técnicas de nivel Medio (pointing o claiming). Medio alto = 2 o más. En el banco v1: 1 vez el 39%, 2 o más el 61%. El puntaje es discreto, así que no se puede cortar justo en el 50%. Se eligió el corte que separa los Medios que piden la técnica una sola vez, los más cercanos a un Fácil. Para elegir, se sacan puzzles del banco con la semilla hasta encontrar uno que cumpla.
6. **Buscaminas**: `NoGuessGenerator.generateDaily`. La celda de inicio también sale de la semilla.
7. **Tema de la sopa**: una ronda fija por los 20 temas, barajada una vez con la clave `daily-themes|v1`. Cada día toma los siguientes temas de la ronda: uno de lunes a sábado y tres el domingo (9 por semana). Ningún tema se repite en 14 días seguidos.
   - El **tema especial del domingo** es la mezcla de esos tres temas. El PRD no lo detallaba.
   - Los dos idiomas usan el mismo tema, pero la grilla es distinta.
8. **Fechas futuras**: pedir el reto de un día posterior a `today` lanza `DailyNotAvailable`. La app calcula `today` con la fecha local del teléfono. Cambiar la hora del teléfono queda fuera de alcance, porque no hay servidor que la valide.
9. **Goldens**: `test/goldens/daily.json` guarda el reto completo de 30 fechas seguidas desde el lunes 2026-11-02: Sudoku, minas e inicio, y sopa en ES y EN. Se regeneran con `dart run tool/update_goldens.dart`, y solo al subir una versión.

## Consecuencias

- Las mismas versiones dan el mismo reto en todos los dispositivos. La aritmética es entera (PCG32, FNV-1a) y no depende de la plataforma Android.
- Cambiar una lista de palabras cambia las sopas de los días con ese tema. Antes del lanzamiento no importa (P-07). Después, hay que subir `wordSearchVersion`.
- El PRD dice que los retos jugados se guardan con el puzzle completo. Así, una versión nueva no altera el historial (H3-10).
