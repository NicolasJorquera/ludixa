# ADR 0003: Zoom del tablero con botón, no con doble toque

- Estado: aceptada
- Fecha: 2026-11-02

## Contexto

La especificación UX (ficha del Buscaminas) proponía que el doble toque alternara entre "ajustar al ancho" y 1,6× en el nivel Experto.

En Flutter, un reconocedor de doble toque sobre el tablero obliga a que cada toque simple espere el tiempo de detección del doble (~300 ms) antes de confirmarse. En el Buscaminas, revelar celdas se sentiría lento justo en la acción más frecuente.

## Decisión

- `ZoomableBoard` admite pellizcar y arrastrar siempre, y expone `toggleZoom()`. La pantalla de juego (H4-03) lo conecta a un **botón de zoom** junto al contador de minas.
- El zoom deja las celdas en al menos 36 px (y nunca menos de 1,6×), centrado en el área visible.
- El doble toque queda como opción (`enableDoubleTapZoom`) para tableros donde el toque simple no sea una acción de juego. Viene desactivado.

## Consecuencias

- Hay que actualizar la ficha UX del Buscaminas: botón de zoom en lugar de doble toque.
- Las celdas del Sudoku (unos 39 dp en un teléfono de 390 dp) y las del Buscaminas Experto sin zoom (unos 20 dp) quedan por debajo de los 48 dp de la guía de Android. Es una decisión de diseño compartida con todo el género. Se compensa con el zoom, el resaltado de la celda seleccionada y la navegación por celdas con TalkBack. Se revisa en la auditoría de H7-02.
