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
packages/sudoku_engine/       Dart puro: Sudoku (generador, solver humano, calificación, pistas, benchmark)
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
