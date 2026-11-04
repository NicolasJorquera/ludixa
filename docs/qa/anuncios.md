# QA de anuncios (H6-07)

Matriz de casos límite de los anuncios. Criterio: **ningún caso deja la app trabada ni entrega una recompensa sin haberla ganado.**

## Cómo se prueba

- Emulador Ludixa_API36 (Android 16), entorno dev con los **anuncios de prueba de Google**.
- Opciones de QA, que solo existen en dev:
  - `--dart-define=ADS_QA=true`: relaja los umbrales de puzzles y tiempo para ver el intersticial. La regla de la primera sesión se mantiene.
  - `--dart-define=ADS_NO_FILL=true`: bloques de anuncios inexistentes. Cada carga falla, como si AdMob no tuviera inventario.
- En compilaciones de depuración, la decisión de la política al salir del Resultado y la confirmación de la recompensa se ven en logcat (`flutter : Intersticial…`, `flutter : Video…`).
- Sin red: `adb shell cmd connectivity airplane-mode enable|disable`. Rotación: `settings put system user_rotation 1` con la rotación automática apagada. Modo oscuro: `cmd uimode night yes|no`.

Leyenda: ✅ cumple · 🔧 se corrigió en H6-07 · ⬜ por comprobar.

## Matriz

| # | Caso | Pasos | Resultado esperado | Resultado (2026-11-03, emulador) |
|---|---|---|---|---|
| 1 | Sin red al abrir | Modo avión, cerrar y abrir la app. | La app se muestra y se juega; UMP falla sin bloquear; no hay banners. | ✅ Inicio en pantalla; logcat `UserMessagingPlatform: Error making request`; 0 banners. |
| 2 | Sin red: pista extra | Sin red, usar las 2 pistas gratis y pedir otra. | Hoja con la pista de cortesía (1 al día) y, la segunda vez, "ya usaste la de hoy". | ✅ (también en H6-04). |
| 3 | Sin red: derrota del Buscaminas | Sin red, perder un tablero. | Sin "Deshacer con video": quedan las dos opciones gratuitas. | ✅ [captura](evidencia/anuncios/c1_offline_defeat.png) |
| 4 | Vuelve la red durante la sesión | Abrir sin red, reactivar la red, esperar ~1 min y perder un tablero. | Los videos y el intersticial vuelven sin reiniciar la app. | 🔧 Antes, una carga fallida no se reintentaba y la sesión quedaba sin videos ni intersticiales. Ahora se reintenta (30 s, 1 min, 2 min… hasta 5 min) y la derrota volvió a ofrecer "Deshacer el último toque con un video". |
| 5 | Sin inventario | Compilar con `ADS_NO_FILL=true`, ganar un puzzle y salir del Resultado. | No hay banners; la política decide `show`, pero sin anuncio cargado la app sigue de inmediato. | ✅ 0 banners; logcat `…Resultado: show` e Inicio en pantalla en menos de 1,5 s. |
| 6 | Video cerrado antes de terminar | Abrir el video y cerrarlo apenas aparece "Close". | Sin recompensa: no hay pista. | ⬜ No se puede reproducir con anuncios de prueba: Google confirma la recompensa (`onUserEarnedReward`) en cuanto empieza el video, antes de que aparezca "Close" ([captura](evidencia/anuncios/c3_back.png), logcat `Video: el SDK confirmó la recompensa`). La app solo entrega la pista con esa confirmación, y el caso "cerrado antes" lo cubre `ads_test` con un servicio falso. **Repetir con anuncios reales en la prueba cerrada.** |
| 7 | Segundo plano durante un video | Abrir el video, ir a la pantalla de inicio de Android, volver y cerrarlo. | El video sigue; el resultado depende solo de la confirmación del SDK; la app no se traba. | ✅ logcat `Video cerrado; recompensa: true` → `earned`. |
| 8 | Segundo plano durante un intersticial | Salir del Resultado (aparece el intersticial), ir a la pantalla de inicio de Android, volver y cerrarlo. | El intersticial sigue y, al cerrarlo, la app llega a su destino (Inicio). | ✅ [captura](evidencia/anuncios/c5_interstitial_back.png); al cerrar, Inicio. |
| 9 | Rotación durante un intersticial | Con el intersticial abierto, girar a horizontal y volver. | Sin cortes ni bloqueos; al cerrar, Inicio. | ✅ El anuncio se mantiene en vertical; al cerrar, Inicio. |
| 10 | Rotación en un teléfono | Girar el teléfono en Inicio, con el banner cargado. | Vertical en teléfonos (ficha UX); en tablets, libre. | 🔧 La app giraba en teléfonos. Ahora fija la vertical cuando el lado corto mide menos de 600 dp. |
| 11 | Modo oscuro | Banner y hoja "Pista extra" con el tema oscuro. | Rótulo "ANUNCIO" legible, hoja con contraste. | ✅ [captura](evidencia/anuncios/c6_dark.png) |
| 12 | Nunca al abrir ni durante una partida | Abrir la app y jugar. | Ningún intersticial ni banner en la partida. | ✅ Diseño (solo al salir del Resultado) y `ads_test`. |
| 13 | Nunca después de un video | Ver un video en un puzzle y salir de su Resultado. | Sin intersticial. | ✅ `ads_test` y política (H6-01). |

## Correcciones de esta tarea

- **Reintento de carga** (`AdMobAdService`): una carga fallida se reintenta con espera creciente, y preguntar si hay video también empieza a cargar uno (caso 4).
- **Vertical en teléfonos** (`bootstrap.dart`, caso 10).
- En depuración, logcat muestra cuándo el SDK confirma la recompensa y cuándo se cierra el video (casos 6 y 7).

## Pendiente para la prueba cerrada (anuncios reales)

- Caso 6 con un video real: cerrarlo antes de que termine y confirmar que no entrega la pista.
- Repetir la matriz en el teléfono de referencia y anotar el resultado aquí.
