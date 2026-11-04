# ADR 0007: Esquema Drift v1 (H5-01)

- Estado: aceptada
- Fecha: 2026-11-03

## Contexto

H5 cambia el progreso en memoria por SQLite con Drift (ADR 0006). H5-01 fija el esquema v1, sus DAOs y el volcado que permite probar las migraciones futuras. El repositorio que usa estas tablas en la app llega en H5-02.

## Decisiones

1. **La base vive en `packages/progress`** (`lib/src/data/drift/`). Drift es Dart puro: el paquete sigue sin depender de Flutter. La conexión la pone quien abre la base: un archivo en la app (H5-02) y `NativeDatabase.memory()` en las pruebas.
2. **Cinco tablas** (`sessions`, `daily_days`, `streak`, `achievements` y `stats_resets`), con nombres de columna en snake_case:

   | Tabla | Clave | Contenido |
   |---|---|---|
   | `sessions` | `id` | Partida: juego, nivel, modo, inicio (ms UTC y desfase), día del reto, semilla, versión del generador, idioma, puzzle y estado en JSON, estado, tiempo, pistas, rescate, fin, temas y banderas |
   | `daily_days` | `local_date` | Día del reto: desfase, juegos completados ese día y desde el archivo, comodín |
   | `streak` | `id` = 1 (CHECK) | Racha actual, máxima, comodines, último día contado, desfase y racha anterior |
   | `achievements` | `id` | Logro desbloqueado y su fecha; un logro no se desbloquea dos veces |
   | `stats_resets` | `game_id`, `difficulty` | Reinicio de estadísticas; `difficulty` vacío es el juego entero |

   Índices en `sessions`: juego y nivel, día del reto y estado. Las consultas de estadísticas y del calendario los usan.
3. **Valores guardados explícitos**: modo (`free`, `daily`, `archive`), estado (`in_progress`, `won`, `lost`, `abandoned`), fechas `AAAA-MM-DD` e instantes en milisegundos UTC. Nunca el nombre de un enum de Dart, para que renombrar código no rompa datos.
4. **Volcado del esquema en `drift_schemas/progress/`** con `drift_dev make-migrations`. La prueba de migración comprueba que el esquema actual coincide con el volcado de su versión. Si la versión sube sin volcado nuevo, falla.
5. **La CI regenera** el código de Drift y los volcados, y falla si difieren de lo guardado.

## Cambios respecto de la arquitectura

| Arquitectura | v1 | Por qué |
|---|---|---|
| `completed_mask` (bits por juego) | Listas de ids (`completed_games`, `archive_games`) | Sumar juegos en la v1.1 (Nonograma, 2048) no exige reasignar bits ni migrar. El calendario lee pocos días, así que no hace falta filtrar por bits en SQL. |
| `perfect` en `daily_days` | Se calcula (los 3 juegos completados) | Evita guardar un dato que puede contradecir a las listas. |
| `achievements.progress` | Se calcula desde las partidas | Igual que las estadísticas: sin datos duplicados (ADR 0006). |
| `schema_meta` | No está en v1 | Drift guarda la versión del esquema en `user_version`. La fecha de exportación llega con H5-05, con su migración. |

## Consecuencias

- Cambiar una tabla exige subir `ProgressDatabase.currentSchemaVersion`, escribir la migración y correr `make-migrations`, que genera el volcado nuevo y las pruebas de paso entre versiones.
- `drift` queda fijo en 2.34.0, la misma versión que `drift_dev`: con 2.34.4, `make-migrations` no compila.
- `sqlite3` 3.x incluye SQLite en la app mediante un *build hook*: descarga los binarios oficiales durante la compilación y verifica cada uno con un hash fijado en el paquete. El APK suma unos 1,7 MB por arquitectura. Compilar sin red necesita la caché del hook.

## H5-02: la base en la app

- `DriftProgressRepository` implementa `ProgressRepository` sobre los DAOs. `transaction` es una transacción real de SQLite: si la acción lanza, no queda nada escrito. Las 29 reglas del servicio se prueban contra los dos repositorios, el de memoria y el de Drift.
- La app abre `progress.sqlite` con `drift_flutter` en el arranque, en otro isolate. Sin esa base, `progressRepositoryProvider` falla: no hay progreso en memoria de reserva. Las pruebas de la app ponen uno en memoria a propósito.
