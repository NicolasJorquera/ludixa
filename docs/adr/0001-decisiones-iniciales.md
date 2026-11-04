# ADR 0001: Decisiones iniciales de arquitectura

- Estado: aceptada
- Fecha: 2026-11-02

## Contexto

App Android de juegos de lógica, offline, sin backend, monetizada con AdMob, desarrollada por una persona y con costo recurrente cercano a cero. Debe poder reutilizar un juego en una app independiente sin duplicar su lógica.

## Decisiones

1. **Flutter (Dart)**, solo Android al lanzar. Versión fijada: 3.41.4, la instalada al crear el proyecto. Se actualizará de forma planificada.
2. **Monorepo con pub workspaces.** Los motores de juego son paquetes en Dart puro. Cada juego es un módulo Flutter que implementa `GameModule` y se comunica con la app solo a través de `GameHost`.
3. **Riverpod** para estado e inyección de dependencias, **go_router** para la navegación y **Drift (SQLite)** para la persistencia local. Se agregan en las tareas que los usan.
4. **PRNG propio (PCG32) y semillas por FNV-1a de 64 bits.** Los retos diarios son idénticos en todos los dispositivos sin servidor. La clave de la semilla incluye fecha, juego, versión del generador e idioma de las palabras.
5. **AdMob con UMP**, detrás de `AdService` y `AdPolicy` (H6).
6. **Firebase Analytics mínima**, con interruptor para desactivarla. Fallos con Android vitals; Crashlytics solo si hace falta.
7. **Fuentes incluidas en la app.** No se usa `google_fonts` en tiempo de ejecución.
8. **Identificador de la app:** `io.github.nicolasjorquera.ludixa`. Se puede cambiar hasta la primera subida a Play; después es permanente.
   - **Actualización (4 de noviembre de 2026):** Play Console fijó `com.gonisoma.ludixa` al crear la app, así que el `applicationId` pasó a ese nombre antes de la primera subida. El `namespace` y el paquete del código Kotlin siguen siendo `io.github.nicolasjorquera.ludixa`.
9. **Paquetes bajo demanda:** cada paquete se crea en la tarea que lo implementa, para no dejar carpetas vacías.

## Consecuencias

- Los motores solo funcionan en la VM y en AOT. Dart web no está soportado, porque PCG32 necesita enteros de 64 bits.
- Cambiar la secuencia de PCG32 o el formato de las claves rompe los retos ya publicados. Los goldens de `puzzle_core` lo detectan.
