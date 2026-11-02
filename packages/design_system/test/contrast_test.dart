import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifica WCAG AA para cada par de colores que la interfaz usa como
/// texto/fondo o icono/fondo, en claro y oscuro, con y sin daltonismo.
void main() {
  test('contrastRatio cumple los extremos de WCAG', () {
    expect(contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)), closeTo(21, 0.01));
    expect(contrastRatio(const Color(0xFF777777), const Color(0xFF777777)), closeTo(1, 0.001));
  });

  for (final brightness in Brightness.values) {
    for (final variant in PaletteVariant.values) {
      group('${brightness.name} · ${variant.name}', () {
        final p = LudixaPalette.of(brightness, variant);
        final sudoku = SudokuColors.from(p);
        final mines = MinesweeperColors.from(p, variant);
        final words = WordSearchColors.from(p);

        void pair(String name, Color fg, Color bg, double min) {
          test(name, () {
            final ratio = contrastRatio(fg, bg);
            expect(ratio, greaterThanOrEqualTo(min), reason: '$name: ${ratio.toStringAsFixed(2)} < $min');
          });
        }

        // Texto general.
        pair('texto sobre fondo', p.ink, p.background, ContrastLevel.text);
        pair('texto sobre superficie', p.ink, p.surface, ContrastLevel.text);
        pair('texto secundario sobre fondo', p.inkMuted, p.background, ContrastLevel.text);
        pair('texto secundario sobre superficie', p.inkMuted, p.surface, ContrastLevel.text);
        pair('texto secundario sobre superficie apagada', p.inkMuted, p.surfaceMuted, ContrastLevel.text);
        pair('enlace primario sobre superficie', p.primary, p.surface, ContrastLevel.text);
        pair('texto de botón primario', p.onPrimary, p.primary, ContrastLevel.text);
        pair('texto sobre tinte primario', p.ink, p.primarySoft, ContrastLevel.text);
        pair('texto sobre zona de pista', p.ink, p.hintSoft, ContrastLevel.text);
        pair('éxito sobre superficie', p.success, p.surface, ContrastLevel.text);
        pair('texto de éxito sobre su tinte', p.successInk, p.successSoft, ContrastLevel.text);
        pair('texto de error sobre su tinte', p.dangerInk, p.dangerSoft, ContrastLevel.text);

        // Bordes de controles e iconos de juego.
        pair('borde de control sobre superficie', p.outline, p.surface, ContrastLevel.large);
        for (final (name, accent, soft) in [
          ('Sudoku', p.sudoku, p.sudokuSoft),
          ('Buscaminas', p.minesweeper, p.minesweeperSoft),
          ('Sopa', p.wordSearch, p.wordSearchSoft),
        ]) {
          pair('icono de $name sobre superficie', accent, p.surface, ContrastLevel.large);
          pair('icono de $name sobre su tinte', accent, soft, ContrastLevel.large);
          pair('texto sobre el tinte de $name', p.ink, soft, ContrastLevel.text);
        }

        // Sudoku: dígitos fijos (500, 23 px: texto normal) y del jugador (600: grande).
        for (final (name, bg) in [
          ('celda', sudoku.cell),
          ('zona', sudoku.zone),
          ('mismo número', sudoku.sameNumber),
          ('seleccionada', sudoku.selected),
        ]) {
          pair('Sudoku: fijo sobre $name', sudoku.given, bg, ContrastLevel.text);
          pair('Sudoku: del jugador sobre $name', sudoku.entered, bg, ContrastLevel.large);
        }
        // Las notas en la celda seleccionada usan el color de los fijos.
        for (final (name, bg) in [('celda', sudoku.cell), ('zona', sudoku.zone), ('mismo número', sudoku.sameNumber)]) {
          pair('Sudoku: nota sobre $name', sudoku.note, bg, ContrastLevel.text);
        }
        pair('Sudoku: conflicto', sudoku.conflictInk, sudoku.conflict, ContrastLevel.large);
        pair('Sudoku: línea gruesa sobre celda', sudoku.thickLine, sudoku.cell, ContrastLevel.large);

        // Buscaminas: números (19 px, 600: grande) y banderas.
        for (var n = 1; n <= 8; n++) {
          pair('Buscaminas: número $n', mines.number(n), mines.open, ContrastLevel.large);
        }
        pair('Buscaminas: bandera sobre celda cerrada', mines.flag, mines.closed, ContrastLevel.large);
        pair('Buscaminas: icono sobre mina fatal', mines.onFatal, mines.fatal, ContrastLevel.large);

        // Sopa de letras.
        pair('Sopa: letra', words.letter, p.surface, ContrastLevel.text);
        pair('Sopa: letra encontrada', words.foundInk, words.found, ContrastLevel.text);
        pair('Sopa: letra en selección', words.onSelecting, words.selecting, ContrastLevel.text);
      });
    }
  }

  test('la variante para daltonismo no usa el verde de éxito ni el rojo de conflicto', () {
    for (final brightness in Brightness.values) {
      final standard = LudixaPalette.of(brightness, PaletteVariant.standard);
      final colorblind = LudixaPalette.of(brightness, PaletteVariant.colorblind);
      expect(colorblind.success, isNot(standard.success));
      expect(colorblind.danger, isNot(standard.danger));
    }
  });
}
