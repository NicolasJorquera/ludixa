# Auditoría de accesibilidad (H7-02)

Criterios: **se puede completar un reto diario solo con TalkBack (Sudoku y Sopa como mínimo)** y **ninguna guía automática falla**.

## Pruebas automáticas

| Prueba | Qué revisa |
|---|---|
| `apps/ludixa/test/a11y_test.dart` | Las 25 pantallas del lienzo en claro, oscuro y texto al 200 %, y las tres partidas con la paleta para daltonismo (81 casos). En cada una, cinco guías:<br>• objetivos táctiles de 48 dp; en las celdas de un tablero, 36 dp<br>• controles con etiqueta<br>• botones habilitados que se pueden activar<br>• contraste del texto |
| `apps/ludixa/test/screen_reader_test.dart` | El reto de Sudoku y el de Sopa de letras se completan de punta a punta solo con acciones de lector de pantalla: lee el tablero de las etiquetas y juega con la acción "tocar", sin coordenadas. En los tres juegos, la pista se anuncia con su nombre y lo que queda. |
| `packages/design_system/test/contrast_test.dart` | Contraste de los tokens en las 4 paletas, ahora con el texto de acento sobre el segmento elegido. |
| `packages/design_system/test/components_test.dart` | Una tarjeta y un chip con etiqueta propia se activan desde el lector de pantalla. |

**Excepción de tamaño:** las celdas de un tablero miden menos de 48 dp, porque 9 columnas no caben a ese tamaño en un teléfono. Se exige al menos 36 dp, la celda cómoda del sistema visual, que es también el tamaño al que lleva el zoom. Supera los 24 px de WCAG 2.2 AA (2.5.8). Con TalkBack, las celdas se recorren deslizando, sin apuntar.

## Lo que encontró la auditoría (corregido)

| Problema | Dónde | Efecto con TalkBack | Corrección |
|---|---|---|---|
| Botones sin acción de tocar | Teclado y herramientas del Sudoku, días del calendario, `LudixaCard` y chips con etiqueta propia (logros, juegos de Inicio) | Se anunciaban como "botón" pero el doble toque no hacía nada: **no se podía jugar el Sudoku** | `Semantics(excludeSemantics: true)` descartaba la acción del `InkWell`; ahora se repite en el `Semantics`. Una guía nueva (`buttonsCanBeActivated`) lo detecta |
| Tres botones "Jugar" iguales | Reto | No se sabía de qué juego era cada uno | `LudixaButton.semanticLabel`: "Jugar Sudoku", "Continuar Sopa de letras" |
| Letra repetida | Celdas de la Sopa | "Fila 1, columna 1, L, L" | `PuzzleGrid` excluye el contenido de la celda: la etiqueta ya la describe entera |
| Pista sin nombre | Buscaminas y Sopa | Se anunciaba "2" o "quedan 2 gratis", sin decir "Pista" | Nombre y valor en un solo nodo ("Pista, quedan 2 gratis"), como en el Sudoku |
| Contraste 3,6:1 | Segmento elegido en oscuro (ajustes de cada juego, Progreso) | Texto de acento poco legible | Fondo sólido `line` en oscuro: 4,6:1 o más |
| Filas de 44 dp | Tabla de Progreso (se mantienen pulsadas para reiniciar) | Objetivo chico | Alto mínimo de 48 dp |

## Emulador (2026-11-04, Ludixa_API36, Android 16)

- **Árbol de accesibilidad de Android** (lo que lee TalkBack, visto con `uiautomator`):
  - las 81 celdas y las 9 teclas del Sudoku son activables;
  - los botones de Reto dicen "Play Sudoku", "Play Minesweeper" y "Play Word search";
  - la pista se anuncia "2 free left, Hint" en los tres juegos.
- **TalkBack activado:** no se pudo recorrer con gestos desde adb. El servicio pide permiso de notificaciones en cada arranque, y los toques de adb no cuentan como el doble toque de TalkBack. Queda para el teléfono.
- **Fuente del sistema al 200 %:** sin desbordes.
  - En Reto, el botón Jugar baja bajo el nombre ([captura](evidencia/accesibilidad/f200_daily.png)).
  - La partida limita la grilla y el teclado al 130 % ([captura](evidencia/accesibilidad/f200_sudoku.png)).
- **Paleta para daltonismo:**
  - el conflicto del Sudoku se ve naranja y subrayado ([captura](evidencia/accesibilidad/cb_sudoku.png));
  - los números del Buscaminas tienen color y una marca de puntos ([captura](evidencia/accesibilidad/cb_mines.png)).

## Lista manual para el teléfono de referencia (TalkBack)

Preparación: Ajustes › Accesibilidad › TalkBack activado. Instalar la versión a probar. Al terminar, desactivar TalkBack.

Leyenda: ✅ comprobado · ⬜ por comprobar.

| # | Caso | Pasos | Resultado esperado | Teléfono |
|---|---|---|---|---|
| 1 | Inicio | Recorrer Inicio deslizando a la derecha. | Se escucha el reto de hoy con el estado de cada juego, "Jugar Sudoku", los tres juegos y la barra de pestañas ("Inicio, pestaña 1 de 4"). | ⬜ |
| 2 | Reto | Ir a Reto y recorrer las filas. | Cada botón dice "Jugar" y el nombre del juego. El calendario anuncia cada día con sus retos. | ⬜ |
| 3 | Reto de Sudoku completo | Tocar dos veces "Jugar Sudoku". Elegir celdas deslizando, tocar dos veces y elegir el número en el teclado. Completar el tablero. | Cada celda anuncia "Fila, columna, contenido". Las teclas anuncian "5, quedan 3". Al terminar se llega al Resultado y el reto queda en 1 de 3. | ⬜ |
| 4 | Reto de Sopa completo | Tocar dos veces "Jugar Sopa de letras". Abrir "Ver palabras" si está cerrado. Por cada palabra, tocar dos veces la letra inicial y después la final. | Indica "Toca la letra inicial". Cada letra se anuncia una sola vez. Al marcar una palabra, la lista la anuncia "encontrada". Al terminar, el Resultado. | ⬜ |
| 5 | Buscaminas | Abrir el reto del Buscaminas, revelar una celda y poner una bandera (mantener pulsado o cambiar a "Bandera"). | Las celdas anuncian "cerrada", su número o "bandera". El contador de minas se actualiza. | ⬜ |
| 6 | Pista | En cada juego, enfocar el botón de pista. | "Pista, quedan 2 gratis" (o "Sin más pistas"). Al usarla se anuncia la ayuda. | ⬜ |
| 7 | Pausa y salida | Tocar dos veces "Pausar" y después "Guardar y salir". | La pausa tapa el tablero y anuncia sus opciones. Al volver, "Continuar" retoma la partida. | ⬜ |
| 8 | Progreso y logros | Recorrer estadísticas, cambiar de juego y abrir un logro. | Cada cifra se lee con su nombre ("Partidas: 2"). Un logro se abre con doble toque. | ⬜ |
| 9 | Ajustes | Cambiar el tema y activar la paleta para daltonismo. | Cada opción anuncia si está elegida, y el interruptor, su estado. | ⬜ |
| 10 | Fuente al máximo | Ajustes › Pantalla › Tamaño de fuente al máximo. Recorrer Inicio, Reto, una partida y el Resultado. | No se corta ningún texto. Los botones crecen en alto. | ⬜ |

## Registro

| Fecha | Teléfono | Android | Versión de Ludixa | Quién | Resultado |
|---|---|---|---|---|---|
| 2026-11-04 | Emulador Ludixa_API36 | 16 | 0.1.0-dev (debug) | Claude | Pruebas automáticas, árbol de Android, fuente al 200 % y paleta para daltonismo. TalkBack con gestos: pendiente en el teléfono. |
|  |  |  |  |  |  |
