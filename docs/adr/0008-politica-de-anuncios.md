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
