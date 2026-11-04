import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sitio de Ludixa (`site/`, en Firebase Hosting). Ver `site/README.md`.
const ludixaSite = 'https://ludixa.web.app';

/// Política de privacidad en el idioma de la app: español o, si no, inglés.
Uri privacyPolicyUrl(Locale locale) =>
    Uri.parse('$ludixaSite/${locale.languageCode == 'es' ? 'privacidad' : 'privacy'}');

/// Abre un enlace en el navegador; false si no se pudo (por ejemplo, sin
/// navegador instalado). Las pruebas lo reemplazan.
final openUrlProvider = Provider<Future<bool> Function(Uri url)>(
  (ref) => (url) async {
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  },
);
