# Pruebas de punta a punta (H7-04)

Criterio: la prueba pasa en un emulador con la **API mínima (24)** y en otro con la **API 36**.

## Qué recorre

`apps/ludixa/integration_test/e2e_test.dart`, en la app real (flavor dev, anuncios de prueba de Google):

1. **Primer arranque:** sin datos, Inicio invita a "Empieza con el reto de hoy".
2. **Tutorial:** la primera partida libre de Sudoku pasa por el tutorial (fila, columna y caja) y empieza el juego.
3. **Reto completo:** desde Reto, "Jugar Sudoku". El tablero se lee de la semántica y se resuelve con toques reales.
4. **Resultado:** "Reto: 1 de 3".
5. **Intersticial de prueba:** al salir del Resultado aparece el intersticial y la app deja de estar en primer plano.
   - Se siembra una sesión anterior, porque nunca hay intersticial en la primera.
   - `ADS_QA` quita los mínimos de puzzles y de tiempo de juego.
   - El anuncio es una actividad nativa: la prueba termina ahí, sin cerrarlo.

La prueba borra al empezar los datos de la versión dev de ese dispositivo.

```bash
cd apps/ludixa
flutter test integration_test/e2e_test.dart --flavor dev --dart-define=ADS_QA=true -d <dispositivo>
```

## Resultados (2026-11-04)

| Emulador | Android | Resultado | Duración |
|---|---|---|---|
| Ludixa_API24 (pixel_5, arm64, Google APIs) | 7.0 (API 24, la mínima) | ✅ Pasa | 39–46 s |
| Ludixa_API36 | 16 (API 36) | ✅ Pasa | 52–61 s |

En API 24, logcat confirma que se abrió el intersticial (`AdActivity`, mostrado en 908 ms): [registro](evidencia/e2e/api24_intersticial_logcat.txt).

Las pruebas de integración no corren en la CI, porque necesitan un emulador. Se corren a mano antes de cada versión.

## Capturas para la ficha

`integration_test/screenshots_test.dart` genera las capturas en `docs/ficha/capturas/`, en producción (sin la cinta DEV ni anuncios):
- 6 pantallas: Inicio, Reto, Sudoku, Buscaminas, Sopa y Progreso;
- en español e inglés, en claro y oscuro;
- con una semana de retos sembrada (racha de 6).

Son 24 imágenes de 1080 × 1920: Play pide que el lado largo no pase del doble del corto. Qué capturas se suben y con qué textos se decide en H8-02.

```bash
adb -s <dispositivo> shell wm size 1080x1920
flutter drive --flavor prod -t integration_test/screenshots_test.dart \
  --driver test_driver/screenshots_driver.dart -d <dispositivo>
adb -s <dispositivo> shell wm size reset
```
