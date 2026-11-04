import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Únicos archivos que definen colores: los tokens y su paso al tema.
const _tokenFiles = {
  'packages/design_system/lib/src/palette.dart',
  'packages/design_system/lib/src/game_colors.dart',
  'packages/design_system/lib/src/theme.dart',
};

/// Colores que se calculan en el momento a partir de tokens, con el motivo.
/// Cualquier otro uso nuevo hace fallar la prueba.
const _allowed = {
  'packages/design_system/lib/src/icons.dart': 'opacidad que pide IconTheme',
  'packages/game_sudoku/lib/src/ui/board.dart': 'pulso animado entre dos tokens',
  'packages/game_wordsearch/lib/src/ui/board.dart': 'parpadeo animado de la selección',
};

final _literal = RegExp(r'Color\(0x(?!00000000\))|Color\.from|\bColors\.(?!transparent\b)');
final _derived = RegExp(r'\.withValues\(|\.withOpacity\(|\.withAlpha\(|Color\.lerp\(');

void main() {
  final root = Directory('../..');
  final sources =
      [
            Directory('${root.path}/apps/ludixa/lib'),
            for (final package in Directory('${root.path}/packages').listSync().whereType<Directory>())
              Directory('${package.path}/lib'),
          ]
          .where((dir) => dir.existsSync())
          .expand((dir) => dir.listSync(recursive: true))
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart') && !file.path.contains('/l10n/generated/'));

  test('ningún color queda fuera de los tokens', () {
    final found = <String>[];
    final used = <String>{};
    for (final file in sources) {
      final path = file.path.substring(root.path.length + 1);
      if (_tokenFiles.contains(path)) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (_literal.hasMatch(line)) found.add('$path:${i + 1}: color literal');
        if (_derived.hasMatch(line)) {
          if (_allowed.containsKey(path)) {
            used.add(path);
          } else {
            found.add('$path:${i + 1}: color derivado; definirlo como token');
          }
        }
      }
    }
    expect(found, isEmpty, reason: found.join('\n'));
    expect(used, _allowed.keys.toSet(), reason: 'quitar de la lista las excepciones que ya no se usan');
  });
}
