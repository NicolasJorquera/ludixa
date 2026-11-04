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
packages/progress/            Progreso (racha con comodines, calendario del reto, logros, maestría, estadísticas) y su base Drift
packages/monetization/        Dart puro por ahora: AdPolicy (límites de anuncios del PRD); AdMob y UMP llegan en H6
packages/design_system/       Tokens claro/oscuro/daltonismo, fuentes incluidas (OFL), tema
tool/                         Scripts de desarrollo
docs/adr/                     Decisiones de arquitectura
docs/qa/                      Listas de verificación manual
```

Es un monorepo con [pub workspaces](https://dart.dev/tools/pub/workspaces). Cada paquete se agrega a `pubspec.yaml` (raíz) cuando la tarea que lo implementa lo crea. Los motores de juego nunca dependen de Flutter.

## Comandos

```bash
flutter pub get                                    # una vez, en la raíz
bash tool/test_all.sh                              # pruebas de todos los paquetes
flutter analyze --fatal-infos                      # análisis estático
dart format .                                      # formato (ancho 120, en analysis_options.yaml)
```

Goldens (capturas de referencia). Se generan y comparan solo en Linux, como en la CI; en macOS se saltan. Con Docker:

```bash
bash tool/goldens.sh            # compara; las diferencias quedan en <paquete>/test/failures
bash tool/goldens.sh --update   # regenera tras un cambio visual buscado (revisar las imágenes antes de subirlas)
```

La matriz de `apps/ludixa/test/golden_matrix_test.dart` cubre cada pantalla en claro/oscuro y es/en/pseudo. Ver ADR 0009.

Rendimiento en un dispositivo (desde `apps/ludixa`, modo profile): fotogramas de las grillas y tiempos de generación en `build/perf.json`. Ver `docs/qa/rendimiento.md`.

```bash
flutter drive --profile --no-dds --flavor dev -t integration_test/perf_test.dart --driver test_driver/perf_driver.dart -d <dispositivo>
```

Pruebas de punta a punta y capturas para la ficha de Play (desde `apps/ludixa`, en un dispositivo): ver `docs/qa/punta-a-punta.md`.

```bash
flutter test integration_test/e2e_test.dart --flavor dev --dart-define=ADS_QA=true -d <dispositivo>
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
3. Compilar con `bash tool/release.sh` (ver abajo).

Sin `key.properties`, la compilación release usa la clave de depuración y Play la rechaza. Sirve solo para pruebas locales.

En Play Console se usa **Firma de apps de Google Play**: Google guarda la clave con la que se firma la app publicada, y esta es solo la clave de carga. Si se pierde, se pide un reemplazo desde la consola.

### Compilar una versión para Play

```bash
bash tool/release.sh          # exige key.properties, admob.properties y admob_prod.json
bash tool/release.sh --local  # sin esos archivos: solo para revisar el paquete
```

- **Versión:** sale de `version:` en `apps/ludixa/pubspec.yaml` (`<nombre>+<versionCode>`). Play rechaza un versionCode repetido: subir el número después del `+` antes de cada subida. El script se niega a compilar dos veces la misma versión.
- **Resultado en `build/release/<versión>/`:**
  - `ludixa-<versión>.aab`, para subir a Play.
  - `mapping.txt`, el mapa de R8. También va dentro del `.aab` y Play lo usa solo.
  - `simbolos-dart/`: el código Dart va ofuscado (`--obfuscate`), y sin estos símbolos no se pueden leer sus errores. Hay que guardar la carpeta fuera del repositorio, una por versión.
- **Símbolos nativos:** el `.aab` incluye la tabla de símbolos de las librerías nativas (`debugSymbolLevel`), así Android vitals muestra los fallos nativos con nombres de función.
- **Leer un error de Dart de una versión publicada:**

  ```bash
  flutter symbolize -i <traza.txt> -d build/release/<versión>/simbolos-dart/app.android-arm64.symbols
  ```

## Ficha de Google Play

`docs/ficha/` tiene los textos de la ficha en español e inglés (`ficha.md`), el icono de 512 px, el gráfico destacado y las capturas. `bash tool/ficha_imagenes.sh` regenera las imágenes y el icono de Android 7 desde `docs/ficha/fuente/` (necesita Google Chrome). El icono adaptable de Android 8+ está en `android/app/src/main/res/drawable/ic_launcher_foreground.xml`.

## Documentación de producto

Discovery, PRD, especificación UX, arquitectura y backlog están en las entregas del proyecto. Las decisiones técnicas que afectan al código se registran en `docs/adr/`. Las listas de verificación manual para el teléfono de referencia están en `docs/qa/`.

## Jugar en desarrollo

La portada (Inicio) abre el reto de hoy, la partida en curso ("Continuar") y cada juego. En la versión dev, además, Ajustes > *Probar juegos* abre los tres juegos con el flujo real: hoja de dificultad (recuerda el último nivel), partida, pausa (`GameHost.showPause`, también automática al volver tras más de 60 s fuera) y resultado. El progreso se guarda en SQLite (Drift, ADR 0007) y se puede exportar e importar desde Ajustes.

## Anuncios y consentimiento

En desarrollo, AdMob usa los identificadores de prueba de Google. Para ver el formulario de consentimiento del EEE:

```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define=UMP_DEBUG_EEA=true
```

Para ver el intersticial sin jugar varios puzzles largos, en dev se suma `--dart-define=ADS_QA=true` (sigue sin haber anuncios en la primera sesión). Para simular que AdMob no tiene inventario, `--dart-define=ADS_NO_FILL=true`; los casos límite están en `docs/qa/anuncios.md`. En un teléfono físico se suma `--dart-define=UMP_TEST_DEVICE=<hash>`, con el hash que UMP escribe en logcat. El ID de AdMob de producción va en `apps/ludixa/android/admob.properties` (`appId=ca-app-pub-...~...`), que no se sube al repositorio. Los bloques de producción se pasan con `--dart-define-from-file=admob_prod.json` (`ADMOB_BANNER`, `ADMOB_INTERSTITIAL`, `ADMOB_REWARDED`); sin ellos, prod no muestra anuncios. Ver ADR 0008.

## Bancos de palabras

Los temas de la Sopa de letras viven en `packages/wordsearch_engine/lib/src/banks/` (`es.dart`, `en.dart`), con 20 temas por idioma que comparten identificador y una lista de palabras bloqueadas. Son un **borrador**: antes de publicar necesitan revisión de una persona hablante nativa de cada idioma (P-07). Al editarlos, `dart test` en ese paquete valida normalización, largo, duplicados, palabras bloqueadas, capacidad por nivel y generación de cada tema. Una palabra bloqueada puede aparecer dentro de una palabra buscada (BASS contiene ASS), pero nunca formada por el relleno o los cruces.

## Banco de Sudokus

El reto diario y el respaldo de la partida libre salen de `packages/sudoku_engine/lib/src/bank/bank_data.dart`, generado (no se edita a mano). Para regenerarlo, desde `packages/sudoku_engine`:

```bash
dart compile exe tool/generate_bank.dart -o build/generate_bank && build/generate_bank --count 300
dart format lib/src/bank/bank_data.dart
```

Cambiar el generador de Sudoku o `SudokuBank.version` cambia el banco y los retos diarios (ver ADR 0004).
