# Ludixa

Colección de juegos de lógica para Android (Sudoku, Buscaminas sin adivinar y Sopa de letras), offline, sin cuentas y con un contrato de anuncios que nunca interrumpe una partida.

## Requisitos

- Flutter **3.41.4** (Dart 3.11.1), el mismo que usa CI. Al actualizar Flutter, cambia también `.github/workflows/ci.yml`.
- JDK 17 y Android SDK con la plataforma 36.

## Estructura

```
apps/ludixa/                  App (raíz de composición, pantallas transversales)
packages/puzzle_core/         Dart puro: PRNG determinista, semillas, fechas, tipos comunes
packages/game_api/            Contratos GameModule y GameHost
packages/minesweeper_engine/  Dart puro: Buscaminas sin adivinar (generador, solvers, partida, benchmark)
packages/sudoku_engine/       Dart puro: Sudoku (generador, solver humano, calificación, pistas, banco pregenerado, benchmark)
packages/wordsearch_engine/   Dart puro: Sopa de letras (normalización es/en, bancos de palabras, generación validada, partida, benchmark)
packages/daily_challenge/     Dart puro: reto diario (calendario de dificultad, semillas, tema del día, goldens)
packages/game_sudoku/         Módulo de Sudoku: partida, pista, tutorial, ajustes y textos (es/en)
packages/game_minesweeper/    Módulo de Buscaminas: partida, zoom, derrota, pista, tutorial, ajustes y textos (es/en)
packages/game_wordsearch/     Módulo de Sopa de letras: partida, selección, lista, pista, tutorial, ajustes e idioma (es/en)
packages/progress/            Dart puro: progreso (racha con comodines, calendario del reto, logros, maestría, estadísticas)
packages/design_system/       Tokens claro/oscuro/daltonismo, fuentes incluidas (OFL), tema
tool/                         Scripts de desarrollo
docs/adr/                     Decisiones de arquitectura
```

Es un monorepo con [pub workspaces](https://dart.dev/tools/pub/workspaces). Cada paquete se agrega a `pubspec.yaml` (raíz) cuando la tarea que lo implementa lo crea. Los motores de juego nunca dependen de Flutter.

## Comandos

```bash
flutter pub get                                    # una vez, en la raíz
bash tool/test_all.sh                              # pruebas de todos los paquetes
flutter analyze --fatal-infos                      # análisis estático
dart format .                                      # formato (ancho 120, en analysis_options.yaml)
```

Idiomas (desde `apps/ludixa`). Los textos viven en `lib/l10n/app_es.arb` (plantilla, con descripciones) y `app_en.arb`. Tras editarlos:

```bash
dart run tool/pseudo_l10n.dart   # regenera la pseudolocalización en_XA (solo dev)
flutter gen-l10n                 # regenera lib/l10n/generated (se versiona; CI verifica que esté al día)
```

Ejecutar la app (desde `apps/ludixa`):

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor prod -t lib/main_prod.dart
```

`dev` instala `io.github.nicolasjorquera.ludixa.dev` ("Ludixa Dev"), que convive con la de producción.

## Propiedades y benchmarks

Cada motor tiene `tool/benchmark.dart`, que genera puzzles, verifica sus propiedades (`--verify`) e imprime una tabla Markdown con p50/p95/p99. `daily_challenge` tiene `tool/check_days.dart`, que genera el reto de muchos días seguidos. Sale con código 1 ante cualquier violación.

- **En cada PR** (job *Propiedades* de `ci.yml`): 1.000 semillas fijas por nivel y dos años de retos diarios. La tabla queda en el resumen de la ejecución.
- **Cada noche** (`nightly.yml`, también se puede lanzar a mano): 20.000 semillas por nivel, nuevas cada noche (`nightly-AAAA-MM-DD`), y diez años de retos. GitHub avisa por correo si falla.

Para reproducir un fallo, desde el paquete:

```bash
bash ../../tool/properties.sh sudoku_engine 20000 nightly-2026-11-03 0
```

## Firma de versiones

Las versiones release se firman con la clave de carga de Google Play. Ni la clave ni sus contraseñas se suben al repositorio.

1. Crear la clave una sola vez y guardarla fuera del repositorio:
   ```bash
   keytool -genkey -v -keystore ~/keys/ludixa-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Crear `apps/ludixa/android/key.properties`:
   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=/Users/<usuario>/keys/ludixa-upload.jks
   ```
3. `flutter build appbundle --flavor prod -t lib/main_prod.dart`

Sin `key.properties`, la compilación release usa la clave de depuración y Play la rechaza. Sirve solo para pruebas locales.

## Documentación de producto

Discovery, PRD, especificación UX, arquitectura y backlog están en las entregas del proyecto. Las decisiones técnicas que afectan al código se registran en `docs/adr/`.

## Bancos de palabras

Los temas de la Sopa de letras viven en `packages/wordsearch_engine/lib/src/banks/` (`es.dart`, `en.dart`), con 20 temas por idioma que comparten identificador y una lista de palabras bloqueadas. Son un **borrador**: antes de publicar necesitan revisión de una persona hablante nativa de cada idioma (P-07). Al editarlos, `dart test` en ese paquete valida normalización, largo, duplicados, palabras bloqueadas, capacidad por nivel y generación de cada tema. Una palabra bloqueada puede aparecer dentro de una palabra buscada (BASS contiene ASS), pero nunca formada por el relleno o los cruces.

## Banco de Sudokus

El reto diario y el respaldo de la partida libre salen de `packages/sudoku_engine/lib/src/bank/bank_data.dart`, generado (no se edita a mano). Para regenerarlo, desde `packages/sudoku_engine`:

```bash
dart compile exe tool/generate_bank.dart -o build/generate_bank && build/generate_bank --count 300
dart format lib/src/bank/bank_data.dart
```

Cambiar el generador de Sudoku o `SudokuBank.version` cambia el banco y los retos diarios (ver ADR 0004).
