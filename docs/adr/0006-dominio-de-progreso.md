# ADR 0006: Dominio de progreso (H3-10)

- Estado: aceptada
- Fecha: 2026-11-03

## Contexto

El PRD define la racha con comodines, el calendario del reto, el archivo, 18 logros, la maestría y las estadísticas. La arquitectura pide un paquete `progress` en Dart puro con su dominio y, en H5-02, el almacenamiento en Drift. H4 necesita un dominio real antes de esa fecha.

## Decisiones

1. **Paquete `packages/progress`**, con `domain/` (puro) y `data/`. Tiene un repositorio en memoria para las pruebas y para H4. H5-02 implementa `ProgressRepository` con Drift sin tocar el dominio.
2. **Las estadísticas no tienen tablas**: se calculan desde las partidas (`SessionRecord`), como dice la arquitectura. Lo que sí se guarda es el calendario (`DailyDay`), la racha (`StreakState`) y los logros desbloqueados.
3. **Registrar un resultado es una sola transacción**: partida, día del reto, racha y logros. Si algo falla, no queda nada escrito. Registrar dos veces la misma partida es un error.
4. **La hora llega por `Clock`** (instante UTC más el desfase de la zona). Las pruebas usan un reloj falso.

## Interpretaciones del PRD

| Regla | Decisión |
|---|---|
| Un día cuenta si se completa al menos un reto con la fecha local en que se empezó | Cuenta solo un reto en modo diario empezado el mismo día local del reto. Si se empieza a las 23:55 y se termina a las 00:05, cuenta para el día del inicio. |
| Comodines | Se gana 1 al llegar a cada múltiplo de 7 días, hasta 2. Se gastan solos al volver. Un día cubierto con comodín **no suma** al largo de la racha, pero queda marcado en el calendario. Si los días sin jugar superan los comodines, la racha se rompe y **los comodines se conservan**. |
| Viajes entre zonas | Los días sin jugar se miden con el reloj de la zona actual y con el de la zona del último día jugado, y se usa el menor. Un salto al este no rompe la racha. Si el día se repite o retrocede (viaje al oeste), no cambia nada. |
| Horario de verano | No requiere lógica: los días se cuentan como fechas, no como horas. |
| Reloj atrasado | Un día anterior al último contado no modifica la racha. Un reto diario ya completado no se puede volver a empezar (`canPlayDaily`). No hay protección antitrampas. |
| Archivo | Los 30 días anteriores a hoy. Completar un reto desde el archivo, o un diario empezado otro día, deja una marca hueca y no cuenta para la racha. |
| Mensaje de racha rota | Se guarda el largo de la racha anterior (`previous`) para el texto "Racha anterior: N días". |
| Logros | "Primer Difícil" y "Primer Experto" exigen esa dificultad exacta. "5 victorias seguidas" cuenta en cualquier dificultad del Buscaminas, y una derrota o un abandono la reinicia. "Mes completo" es la insignia de mes: 20 días jugados. "Explorar 10 temas" suma los tres temas del domingo. "Sin ayuda" excluye pistas gratis, pistas por video y el rescate. |
| Maestría | Bronce, Plata y Oro con 10, 25 y 50 partidas **ganadas** por juego y dificultad. |
| Reiniciar estadísticas | Se guarda la fecha del reinicio y las estadísticas ignoran las partidas anteriores. No se borran partidas, racha, calendario, maestría ni logros. |

## Consecuencias

- Los logros y la maestría se recalculan con todo el historial en cada resultado. Con miles de partidas sigue siendo instantáneo. Si en H5 deja de serlo, se cachea.
- `GameResult` (game_api) todavía no informa temas ni banderas. H4 los agrega al conectar los juegos con `SessionRecord`.
