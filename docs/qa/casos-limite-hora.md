# Casos límite de fecha y hora (H5-06)

Lista manual para el **teléfono de referencia**. Las reglas ya tienen pruebas automáticas en el dominio; esta lista comprueba que la app real, con el reloj y la zona del sistema, se comporta igual.

## Preparación

- Instalar la versión a probar (release del entorno `dev` o la de la prueba interna de Play).
- Anotar el teléfono y la versión de Android en la tabla del final.
- En **Ajustes › Sistema › Fecha y hora**, desactivar "Fecha y hora automáticas" y "Zona horaria automática". Así se cambian a mano.
- Al terminar, volver a activar las dos opciones automáticas.

Reglas que se comprueban (PRD y ADR 0005/0006):

- Un reto cuenta para el **día local en que se empezó**, aunque se termine después de medianoche.
- La racha se cuenta por días locales del reto. Un viaje entre zonas no la rompe si no faltó un día real.
- Con el reloj atrasado no se puede repetir un reto ya completado, y un día pasado no reescribe la racha.
- El tiempo de una partida se mide jugando, no con el reloj del sistema: cambiar la hora no lo altera.

## Casos

Leyenda: ✅ comprobado · ⬜ por comprobar · — no aplica.

| # | Caso | Pasos | Resultado esperado | Prueba automática | Emulador | Teléfono |
|---|---|---|---|---|---|---|
| 1 | Medianoche durante un reto | Poner la hora a las 23:58. Abrir un reto en Reto y terminarlo después de las 00:00. | El resultado dice "Reto: 1 de 3", con la racha contada para el día anterior. En el calendario, el día anterior tiene su punto. | `progress_service_test`: "empezado 23:55 y terminado 00:05…"; `streak_test`: "medianoche…" | ✅ 2026-11-03 | ⬜ |
| 2 | "Siguiente reto" después de medianoche | Al terminar el caso 1, tocar "Siguiente reto". | Abre el reto del **día nuevo** (su nivel y su tema), no el que quedaba del día anterior. | `play_test`: "medianoche: el reto empezado ayer…" | ✅ 2026-11-03 | ⬜ |
| 3 | Pestaña Reto abierta a medianoche | Dejar la pestaña Reto abierta a las 23:59 y esperar a las 00:00. | La fecha, los 3 retos y "hoy" en el calendario cambian solos, sin cerrar la app. | `daily_test`: "al pasar la medianoche con la pantalla abierta…" | ⬜ | ⬜ |
| 4 | Volver a la app después de medianoche | Con la app en segundo plano, pasar las 00:00 y volver a abrirla. | Inicio y Reto muestran el día nuevo. | — | ⬜ | ⬜ |
| 5 | Viaje al oeste | Completar un reto. Cambiar la zona a una que vuelva al día anterior (por ejemplo, de Santiago a Honolulu pasada la medianoche) y volver a la app. | Muestra el día anterior. Lo completado sigue completado y no se puede repetir. La racha no cambia. | `streak_test`: "viaje al oeste…" | ✅ 2026-11-03 | ⬜ |
| 6 | Viaje al este | Jugar un reto. Cambiar la zona a una que adelante el calendario un día (por ejemplo, de Santiago a Tokio de noche) y jugar el reto del día que aparece. | La racha sigue y suma uno: no faltó un día real. | `streak_test`: "viaje al este…" | ⬜ | ⬜ |
| 7 | Reloj atrasado a un día ya completado | Completar el reto de hoy. Atrasar la fecha un día, volver a hoy y abrir Reto. | Hoy sigue "hecho" y sin botón Jugar en lo completado. | `progress_service_test`: "con el reloj atrasado no se puede volver a jugar…" | ✅ 2026-11-03 (con el caso 5) | ⬜ |
| 8 | Reloj atrasado a un día sin jugar | Atrasar la fecha dos días y jugar ese reto. | Se puede jugar, pero la racha no cambia (por ejemplo, "racha 1 → 1"). | `streak_test`: "reloj atrasado: un día ya pasado no reescribe la racha" | ✅ 2026-11-03 | ⬜ |
| 9 | Cambio de horario | Poner la fecha del cambio de horario de Chile (abril o septiembre) a las 23:30, jugar un reto y otro al día siguiente. | La racha suma los dos días: el día de 23 o 25 horas no afecta. | `streak_test`: "horario de verano…" | — | ⬜ |
| 10 | Cambiar la hora con una partida abierta | Empezar una partida libre, cambiar la hora del sistema 2 horas y volver. | El tiempo de la partida no salta. Si pasó más de 60 s fuera, aparece la pausa. | `game_api`: GameLifecycle | ⬜ | ⬜ |
| 11 | Retomar al día siguiente un reto a medias | Empezar un reto, salir con "Guardar y salir", pasar la medianoche y tocar "Continuar". | Se retoma igual. Al terminarlo cuenta para el día en que se empezó; el día nuevo tiene sus propios retos. | `resume_test`; regla del caso 1 | ⬜ | ⬜ |

## Registro

| Fecha | Teléfono | Android | Versión de Ludixa | Quién | Resultado |
|---|---|---|---|---|---|
| 2026-11-03 | Emulador Ludixa_API36 | 16 | 0.1.0-dev (debug) | Claude | Casos 1, 2, 5, 7 y 8 ✅. Encontró y corrigió el caso 2: "Siguiente reto" abría el reto del día anterior. |
|  |  |  |  |  |  |
