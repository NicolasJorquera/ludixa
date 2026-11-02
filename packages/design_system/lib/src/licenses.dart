import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Registra las licencias OFL de las fuentes incluidas para que aparezcan en
/// la pantalla de licencias. Se llama una vez al arrancar.
void registerDesignSystemLicenses() {
  LicenseRegistry.addLicense(() async* {
    const fonts = [('Lexend', 'OFL-Lexend.txt'), ('Bricolage Grotesque', 'OFL-BricolageGrotesque.txt')];
    for (final (name, file) in fonts) {
      final text = await rootBundle.loadString('packages/design_system/assets/fonts/$file');
      yield LicenseEntryWithLineBreaks([name], text);
    }
  });
}
