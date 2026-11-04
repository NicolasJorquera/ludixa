# ADR 0009: Goldens en Linux y matriz de pantallas (H7-01)

- Estado: aceptada
- Fecha: 2026-11-04

## Contexto

Hasta H6 los goldens se generaban en macOS y la CI (Ubuntu) se los saltaba: el renderizado de fuentes cambia entre sistemas operativos, así que una imagen de macOS nunca coincide con una de Linux. Los goldens no protegían nada en los PR. H7-01 pide una matriz de pantallas × claro/oscuro × es/en/pseudo verificada en la CI, y que ningún color quede fuera de los tokens.

## Decisiones

1. **Los goldens se generan y comparan solo en Linux x86_64.** `goldensSkip` (`package:design_system/testing.dart`) salta el grupo `goldens` fuera de Linux. La CI los compara en cada PR y, si fallan, sube las diferencias como artefacto `goldens-failures`.
2. **`tool/goldens.sh` corre los goldens en Docker** (`ubuntu:24.04`, `linux/amd64`, Flutter 3.41.4), igual que la CI. Trabaja sobre una copia del repositorio para no mezclar `.dart_tool` ni lockfiles de Linux con los de macOS, y copia de vuelta solo `test/goldens` y `test/failures`. El SDK y la caché de pub quedan en volúmenes de Docker.
3. **La matriz** (`apps/ludixa/test/golden_matrix_test.dart`) recorre las pantallas de `test/support/screens.dart`, la misma lista del barrido de diseño adaptable: 25 pantallas × claro/oscuro × es/en/pseudo, a 390 × 844 dp y 1x para que las imágenes pesen poco. Los anchos y el texto al 200 % siguen en `layout_test`.
4. **Los colores solo se definen en los tokens** (`palette.dart`, `game_colors.dart` y su paso al tema en `theme.dart`). `tokens_test` revisa el código de la app y de los paquetes: falla con un color literal o con un color derivado (opacidad o mezcla) fuera de esos archivos. Los derivados fijos que había pasaron a ser tokens: `inkDisabled`, `segmentSelected`, `SudokuColors.hintTarget` (con su prueba de contraste) y `MinesweeperColors.closedFaded`. Quedan tres excepciones calculadas en el momento, listadas con su motivo: la opacidad de `IconTheme` y dos animaciones.

## Lo que encontró la matriz

- **La tabla por nivel de Progreso se cortaba por la derecha** a 390 dp: en el Buscaminas en español y en los tres juegos en inglés y pseudo ("Averag", "12:3"). `Table` con anchos intrínsecos no avisa del desborde y la tarjeta lo recortaba, así que el barrido de layout no lo veía. Ahora la tabla mide sus textos con el idioma y la escala actuales: el nivel y las ganadas pueden partirse entre palabras; si aun así no cabe, se muestra la lista por nivel que ya existía para pantallas angostas. Lo cubre una prueba en `progress_test`.
- **El botón de volver automático** de las pantallas con `AppBar` (como el Archivo) usaba la flecha de Material y no el icono del sistema visual. El tema lo cambia por `LudixaIcons.back`, como en los juegos. Las pruebas no cargan la fuente de Material: un icono de Material que aparezca se ve como una caja en el golden.
- Limitaciones conocidas, solo en desarrollo: los juegos no tienen pseudolocalización (muestran inglés), y Lexend no tiene algunos caracteres del pseudo, que en las pruebas salen como cajas; en el teléfono usan la fuente de respaldo.

## Consecuencias

- Un cambio visual buscado se acompaña de `bash tool/goldens.sh --update` y de una revisión de las imágenes en el PR.
- En macOS `tool/test_all.sh` no compara goldens; para hacerlo, `bash tool/goldens.sh`.
- Docker emula x86_64 en un Mac con Apple Silicon: es lento (unos 8 minutos todo), pero usa el mismo sistema, arquitectura y versión de Flutter que la CI.
