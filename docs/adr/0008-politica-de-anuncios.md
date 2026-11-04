# ADR 0008: Política de anuncios (H6-01)

- Estado: aceptada
- Fecha: 2026-11-03

## Contexto

El PRD fija cuándo puede aparecer un intersticial, y la arquitectura pide aplicar esas reglas en Dart puro con un reloj inyectable, separadas de AdMob. H6-01 es esa política. El consentimiento (H6-02) y AdMob (H6-03) llegan después y la usan.

## Decisiones

1. **Paquete `packages/monetization`**, como dice la arquitectura. Por ahora es Dart puro y solo contiene `AdPolicy`. Cuando H6-03 sume `google_mobile_ads`, AdMob irá en el mismo paquete y la política seguirá sin depender de Flutter.
2. **`AdPolicy.decide(salida)`** devuelve `show` o el motivo por el que no (`AdDecision`). Los motivos sirven para las pruebas y, más adelante, para la analítica sin datos personales.
3. **Límites en constantes** (`AdLimits`): cambiar uno es cambiar una constante, con su prueba.
4. **Contadores en las preferencias del dispositivo** (`AdPolicyState`, JSON), como dice la arquitectura. No se exportan con el progreso. Un valor dañado vuelve a cero: solo puede retrasar un anuncio, nunca adelantarlo.

## Interpretaciones del PRD

| Regla del PRD | Cómo se aplica |
|---|---|
| Nunca en la primera sesión | Una sesión es cada vez que se abre la app (`appOpened`). En la primera no hay intersticiales, aunque se completen muchos puzzles. |
| Nunca antes de completar 3 puzzles en total | Cuentan los puzzles completados (ganados) de al menos 60 s. Las derrotas y los abandonos no cuentan. |
| Como máximo 1 cada 2 puzzles completados | Contador de puzzles completados desde el último intersticial, con el mismo criterio. |
| Mínimo 4 minutos de juego activo desde el último intersticial o desde que se abrió la app | Se suma el tiempo de juego de todas las partidas, también las abandonadas. Vuelve a cero al mostrar un intersticial y al abrir la app. |
| Las partidas de menos de 60 s suman tiempo, pero no habilitan un intersticial por sí solas | Su tiempo cuenta para los 4 minutos, pero no cuentan como puzzle para las dos reglas anteriores. |
| Tope de 8 al día | Por día local del dispositivo. Al cambiar el día vuelve a haber. |
| Nunca después de un rewarded | Si en el puzzle que se acaba de cerrar hubo un video con recompensa, al salir de su Resultado no hay intersticial. El siguiente puzzle ya no arrastra el video. |
| Nunca en el tutorial ni al salir de una partida abandonada | `decide` recibe desde dónde se sale (`AdExit`). Solo la salida del Resultado puede mostrar uno. |

## Consecuencias

- Con 3 a 5 puzzles de varios minutos al día, salen de 1 a 2 intersticiales, dentro del rango del escenario base del PRD. Una prueba lo comprueba con un día típico.
- La app llamará a `appOpened`, `puzzleStarted`, `addActivePlay`, `puzzleCompleted` y `rewardedShown` desde el host de la partida, y a `decide` e `interstitialShown` al salir del Resultado (H6-03). Guardará el estado en las preferencias después de cada cambio.

## H6-02: consentimiento con UMP

- `monetization` pasa a ser un paquete Flutter con `google_mobile_ads` (Apache 2.0; UMP 4.0 incluido). `AdPolicy` sigue sin importar Flutter.
- **`ConsentService`** (implementación `UmpConsentService`): en cada arranque se pide la información de consentimiento y, si corresponde, el formulario se muestra **encima de la app ya visible**: la app no espera a UMP.
- **`AdsStartup`**: inicia el SDK de anuncios **solo si `canRequestAds()`**. Sin consentimiento resuelto no se inicializa ni se pide nada. Si UMP falla (sin red), la app sigue sin anuncios.
- **Opciones de privacidad** en Ajustes › Datos y privacidad y en el contrato de anuncios, solo cuando UMP dice que hacen falta (`PrivacyOptionsRequirementStatus.required`).
- **ID de aplicación de AdMob por entorno**: dev usa el de prueba público de Google. Prod lo lee de `android/admob.properties` (`appId=...`), que no se sube al repositorio. Sin ese archivo, prod usa el de prueba con un aviso de compilación, como la firma.
- **Probar el formulario del EEE en desarrollo**: `--dart-define=UMP_DEBUG_EEA=true`. El emulador entra como dispositivo de prueba. En un teléfono hace falta además `--dart-define=UMP_TEST_DEVICE=<hash>`, que UMP escribe en logcat. En producción estas opciones se ignoran.
- **Tamaño**: el APK release de arm64 pasa de 22,9 MB a 25,5 MB con el SDK de anuncios (+2,6 MB). El PRD pide una descarga de menos de 25 MB. Play calcula la descarga desde el App Bundle con su propia compresión, así que la cifra que cuenta es la de la consola de Play. Hay que revisarla antes del lanzamiento.

## H6-03: anuncios con AdMob

- **`AdService`** (`monetization`) solo carga y muestra; cuándo lo decide la app con `AdPolicy`. Tiene tres implementaciones:
  - `AdMobAdService`: precarga un intersticial y un video, y vuelve a precargar después de mostrar cada uno.
  - `NoAdsService`: sin consentimiento, sin identificadores de producción o para la futura compra que quita los anuncios.
  - una falsa, en las pruebas de la app.
- **Intersticial**: solo al salir del Resultado (Volver al inicio, Otra partida, Siguiente reto) y solo si `AdPolicy` lo permite. Si no está cargado, no se espera ni se reintenta. Nunca durante una partida, en el tutorial, en la pausa, en Ajustes ni al abrir la app.
- **Video con recompensa** (`showRewarded`): `earned` solo si el SDK confirma que se vio completo; `dismissed` si se cerró antes; `unavailable` si no había video. Si se llegó a mostrar, ese puzzle ya no deja salir con intersticial. Lo ofrece la economía de pistas (H6-04); en dev hay una fila de prueba en Ajustes.
- **Banner** adaptable en línea al final de Inicio, Reto, Progreso (las dos pestañas) y Resultado. Lleva el rótulo "Anuncio" y queda a 24 dp de los controles (`LudixaAdSlot`). Tiene un **alto máximo de 100 dp**: sin ese tope, AdMob entrega banners de unos 300 dp. Sin anuncio no ocupa espacio.
- **`RequestConfiguration`**: clasificación máxima T, sin marca de público infantil.
- **Identificadores**: dev usa siempre los de prueba de Google. Prod los recibe con `--dart-define-from-file` (`ADMOB_BANNER`, `ADMOB_INTERSTITIAL`, `ADMOB_REWARDED`), desde un archivo que no se sube. Sin ellos, prod queda **sin anuncios**, nunca con los de prueba.
- **Sesión**: la política se crea al abrir la app, aunque no se juegue (cuenta para "nunca en la primera sesión").
- **Tiempo de juego**: el host avisa el tiempo jugado al terminar y al salir de una partida, hasta la última jugada guardada.
- **QA a mano**: `--dart-define=ADS_QA=true`, solo en dev, relaja los umbrales de puzzles y de tiempo para ver el intersticial. La regla de la primera sesión se mantiene.
