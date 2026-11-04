# Rendimiento y tamaño (H7-03)

Metas:
- arranque en frío en menos de 2 s en un teléfono de gama media;
- 60 fps en las grillas;
- generación con p95 dentro del PRD (Buscaminas: < 1 s; Sudoku libre: 2 s de presupuesto, si no, el banco);
- descarga de menos de 25 MB.

**Medido aquí:** emulador Ludixa_API36 (Android 16, arm64, 4 núcleos) sobre un Mac con Apple Silicon. Un emulador no reemplaza al teléfono de gama media: es más rápido en CPU y su GPU es OpenGL ES emulado. Las cifras del teléfono quedan pendientes (ver el final).

## Resumen

| Meta | Resultado | Estado |
|---|---|---|
| Descarga < 25 MB | **≤ 13,1 MB** (arm64, estimado) | ✅ Con margen. La cifra oficial la da la consola de Play al subir el App Bundle (H8-01) |
| Arranque < 2 s | 0,84–0,93 s hasta el primer frame en el emulador (antes 0,97–1,62 s) | 🟡 En el teléfono, pendiente |
| p95 de generación | Buscaminas Experto 13–16 ms (máx. 57 ms); Sudoku libre ≤ 47 ms; Sopa Experto ≤ 4 ms | ✅ Muy por debajo de los límites, incluso con el Mac cargado |
| 60 fps | Corrida 1: 99,4 % / 96,9 % / 99,8 % de frames a tiempo. Corrida 2, con el Mac cargado: 27 % / 57 % / 92 % | 🟡 El emulador no es concluyente; en el teléfono, pendiente |

## Tamaño

El APK release de arm64 pesa 29 MB, pero ese es el tamaño **instalado**: Android guarda las librerías nativas sin comprimir. Play comprime cada archivo para la descarga y solo envía la arquitectura del teléfono.

Cálculo: cada archivo de la división arm64 comprimido con deflate nivel 9. Play usa brotli, que comprime un poco más, así que el resultado es una cota superior.

| Parte | Instalado | Descarga |
|---|---:|---:|
| `libflutter.so` (motor de Flutter) | 11,32 MB | 5,30 MB |
| `libapp.so` (código Dart AOT; Flutter ocupa 3,2 MB) | 8,52 MB | 3,48 MB |
| `classes.dex` (SDK de anuncios y UMP) | 5,43 MB | 2,59 MB |
| `libsqlite3.so` | 1,73 MB | 0,86 MB |
| Fuentes y recursos | 1,1 MB | 0,4 MB |
| **Total arm64** | **28,8 MB** | **≤ 13,1 MB** |

- El APK incluye `libsqlite3.so` de las otras dos arquitecturas (3,4 MB), porque el build hook de sqlite3 no respeta `--target-platform`. En el App Bundle, Play las separa por arquitectura y no llegan al teléfono.
- No hizo falta recortar nada. Si en el futuro hiciera falta, Bricolage Grotesque (0,4 MB, solo títulos) se puede reducir a los caracteres que se usan.

## Arranque en frío

- **Hasta el primer frame de Flutter** (`flutter run --profile --trace-startup`, 4 corridas): 0,84–0,93 s.
- **Ventana visible para Android** (`am start -S -W`, release, 10 corridas tras la primera): mediana 660 ms, máximo 763 ms ([datos](evidencia/rendimiento/arranque_am_start_emulador.txt)).
- **Corrección:** antes de `runApp` se abrían las preferencias seis veces seguidas, cada una con su viaje al lado nativo. Ahora van en paralelo, junto con el bloqueo de orientación (`bootstrap.dart`). El primer frame bajó de 0,97–1,62 s a 0,84–0,93 s.
- **En qué se va el resto, según la traza:**
  - La app aporta poco: unos 30 ms construyendo widgets y 65 ms de mensajes de Dart.
  - Lo que más pesa en el emulador es el enlace de shaders de Impeller sobre OpenGL ES (`LinkProgram`, 356 ms), un costo del motor en la GPU emulada.
  - En un teléfono con Vulkan, ese tramo es distinto: hay que medirlo allí.

## Generación en el dispositivo

Medida dentro de la app compilada en modo profile (AOT), con `integration_test/perf_test.dart` (corrida 2, con el Mac cargado; [datos](evidencia/rendimiento/emulador_2026-11-04_corrida2.json)):

| Juego · nivel | n | p50 | p95 | máx | Del banco |
|---|---:|---:|---:|---:|---:|
| Buscaminas Principiante | 200 | 0,04 ms | 0,2 ms | 3 ms | — |
| Buscaminas Intermedio | 200 | 0,1 ms | 0,6 ms | 1,7 ms | — |
| Buscaminas Experto | 200 | 3,4 ms | 15,6 ms | 57 ms | — |
| Sudoku Fácil (partida libre) | 20 | 0,5 ms | 2,2 ms | 4,2 ms | 0 |
| Sudoku Medio | 20 | 15,7 ms | 47,3 ms | 50 ms | 2 |
| Sudoku Difícil | 20 | 28,8 ms | 40,4 ms | 41,6 ms | 6 |
| Sudoku Experto | 20 | 17,6 ms | 33,3 ms | 34,9 ms | 0 |
| Sopa Experto | 200 | 0,8 ms | 3,6 ms | 9,6 ms | — |

- **"Del banco"** son las partidas en que el generador no encontró un puzzle del nivel y se usó el banco pregenerado, como prevé el ADR 0004. Nunca se agotó el presupuesto de 2 s.
- **Buscaminas Experto:** p95 de 13–16 ms en las dos corridas, contra 1 s de límite. Si un teléfono de gama baja fuera 20 veces más lento, seguiría por debajo de 0,35 s.

## Fotogramas

Medidos con `watchPerformance` mientras la prueba juega:
- Buscaminas Experto 16×30: revela celdas y desplaza el tablero.
- Sudoku: elige celdas y escribe números.
- Sopa Experto: selecciona arrastrando.

| Grilla | Corrida 1 (frames a tiempo) | Corrida 2, Mac cargado |
|---|---:|---:|
| Buscaminas Experto | 99,4 % (6 de 1.007 lentos) | 27,3 % |
| Sudoku | 96,9 % (5 de 162) | 57,1 % |
| Sopa Experto | 99,8 % (1 de 586) | 92,1 % |

- Entre corridas cambió la carga del Mac (promedio de carga 10, con otro emulador abierto), no el código. El emulador comparte CPU y GPU con el Mac, así que **los fps del emulador no son concluyentes**.
- **Frames lentos de la corrida 1:** aparecen la primera vez que algo se dibuja.
  - Un dígito con un estilo nuevo tardó 23 ms en su `RichText`: es la primera vez que se crea esa variante de la fuente.
  - El resto es compilación de shaders en la GPU emulada.
  - No se repiten en la misma sesión.

## Pendiente en el teléfono de referencia

1. **Fotogramas y generación:**

   ```bash
   cd apps/ludixa
   flutter drive --profile --no-dds --flavor dev -t integration_test/perf_test.dart --driver test_driver/perf_driver.dart -d <teléfono>
   ```

   El resultado queda en `build/perf.json`. Meta: más del 99 % de frames a tiempo después del primer uso.

   La prueba deja partidas libres a medio jugar en la versión dev.
2. **Arranque en frío:** abrir y cerrar la app 10 veces con `adb shell am start -S -W -n com.gonisoma.ludixa.dev/io.github.nicolasjorquera.ludixa.MainActivity` (release) y anotar `TotalTime`. Además, `flutter run --profile --trace-startup` y `timeToFirstFrameRasterizedMicros` en `build/start_up_info.json`.
3. **Descarga:** la cifra de la consola de Play al subir el App Bundle (H8-01). En la prueba interna, el informe previo al lanzamiento (H7-05) y Android vitals agregan arranque y fotogramas de teléfonos reales.

| Fecha | Teléfono | Arranque (mediana) | Frames a tiempo (Buscaminas / Sudoku / Sopa) | Buscaminas Experto p95 | Descarga en Play |
|---|---|---|---|---|---|
|  |  |  |  |  |  |
