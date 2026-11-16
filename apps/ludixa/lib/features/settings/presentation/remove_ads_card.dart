import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../ads/remove_ads.dart';

/// Tarjeta «Sin anuncios» de Ajustes: qué incluye, comprar con el precio que
/// informa Google Play, restaurar y el estado de la compra.
class RemoveAdsCard extends ConsumerStatefulWidget {
  const RemoveAdsCard({super.key});

  @override
  ConsumerState<RemoveAdsCard> createState() => _RemoveAdsCardState();
}

class _RemoveAdsCardState extends ConsumerState<RemoveAdsCard> {
  @override
  void initState() {
    super.initState();
    // El precio se consulta al abrir Ajustes, no al abrir la app.
    unawaited(ref.read(removeAdsProvider).loadProduct());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    final s = ref.watch(removeAdsStateProvider);
    final billing = ref.read(removeAdsProvider);
    final busy = s.flow == PurchaseFlow.busy;
    final status = switch (s.flow) {
      PurchaseFlow.restored when s.owned => l10n.removeAdsRestored,
      _ when s.owned => l10n.removeAdsOwned,
      PurchaseFlow.pending => l10n.removeAdsPending,
      PurchaseFlow.canceled => l10n.removeAdsCanceled,
      PurchaseFlow.error => l10n.removeAdsError,
      PurchaseFlow.unavailable => l10n.removeAdsUnavailable,
      PurchaseFlow.nothingToRestore => l10n.removeAdsNothing,
      _ => null,
    };
    final price = s.price;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LudixaCard(
        key: const Key('remove-ads-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!s.owned) ...[
              Text(l10n.removeAdsTitle, style: text.titleMedium),
              const SizedBox(height: 4),
              Text(l10n.removeAdsBody, style: text.bodyMedium?.copyWith(color: p.inkMuted)),
            ],
            if (status != null) ...[
              if (!s.owned) const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (s.owned) ...[LudixaIcon(LudixaIcons.check, color: p.success), const SizedBox(width: 12)],
                    Expanded(
                      child: Text(status, key: const Key('remove-ads-status'), style: text.bodyLarge),
                    ),
                  ],
                ),
              ),
            ],
            if (!s.owned) ...[
              const SizedBox(height: 16),
              LudixaButton(
                key: const Key('remove-ads-buy'),
                label: price == null ? l10n.removeAdsBuyNoPrice : l10n.removeAdsBuy(price),
                onPressed: busy || s.flow == PurchaseFlow.pending ? null : () => unawaited(billing.buy()),
              ),
              const SizedBox(height: 8),
              LudixaButton(
                key: const Key('remove-ads-restore'),
                label: l10n.removeAdsRestore,
                variant: LudixaButtonVariant.tertiary,
                onPressed: busy ? null : () => unawaited(billing.restore()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
