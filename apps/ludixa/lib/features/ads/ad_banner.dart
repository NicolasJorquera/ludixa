import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';

import '../../l10n/generated/app_localizations.dart';
import 'ads_controller.dart';

/// Banner adaptable en línea, al final del contenido de Inicio, Reto,
/// Progreso y Resultado (mapa de anuncios de la ficha UX). Lleva el rótulo
/// "Anuncio" y queda a 24 dp de cualquier control; sin anuncio no ocupa
/// espacio.
class AdBanner extends ConsumerStatefulWidget {
  const AdBanner({super.key});

  @override
  ConsumerState<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends ConsumerState<AdBanner> {
  LoadedBanner? _banner;
  AdService? _loadedFor;
  double? _width;

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  Future<void> _load(AdService service, double width) async {
    _loadedFor = service;
    _width = width;
    final banner = await service.loadBanner(width);
    if (!mounted || _loadedFor != service) {
      banner?.dispose();
      return;
    }
    setState(() {
      _banner?.dispose();
      _banner = banner;
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(adServiceProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.floorToDouble();
        if (service != _loadedFor || width != _width) {
          // Fuera del build: cargar es asíncrono y avisa con setState.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && (service != _loadedFor || width != _width)) _load(service, width);
          });
        }
        return LudixaAdSlot(label: AppLocalizations.of(context).adLabel, ad: _banner?.widget);
      },
    );
  }
}
