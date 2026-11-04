import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:monetization/monetization.dart';

import '../../l10n/generated/app_localizations.dart';
import '../ads/ads_controller.dart';
import 'app_game_host.dart';

/// Videos y cortesía de la app para el host de una partida.
final class AppRewardedHints implements RewardedHints {
  AppRewardedHints({required this.context, required this.ads, required this.freeHintsPerPuzzle});

  final BuildContext context;
  final AdsController ads;
  final int freeHintsPerPuzzle;

  @override
  bool get videoReady => ads.rewardedReady;

  @override
  Future<RewardedOutcome> showVideo() => ads.showRewarded();

  @override
  bool get courtesyAvailable => ads.courtesyAvailable;

  @override
  void useCourtesy() => ads.courtesyUsed();

  @override
  Future<HintOfferChoice> offerHint(HintOffer offer) async {
    if (!context.mounted) return HintOfferChoice.cancel;
    final choice = await showModalBottomSheet<HintOfferChoice>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => HintOfferSheet(offer: offer, freeHintsPerPuzzle: freeHintsPerPuzzle),
    );
    return choice ?? HintOfferChoice.cancel;
  }
}

/// "Pista extra": video si hay, si no la cortesía del día, y si tampoco, por
/// qué. Cada botón dice qué pasa al tocarlo.
class HintOfferSheet extends StatelessWidget {
  const HintOfferSheet({super.key, required this.offer, required this.freeHintsPerPuzzle});

  final HintOffer offer;
  final int freeHintsPerPuzzle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = context.palette;
    void choose(HintOfferChoice choice) => Navigator.pop(context, choice);
    final later = LudixaButton(
      label: l10n.hintOfferLater,
      onPressed: () => choose(HintOfferChoice.cancel),
      variant: LudixaButtonVariant.tertiary,
    );
    if (offer.videoReady) {
      return LudixaSheet(
        leading: LudixaIcon(LudixaIcons.hint, size: 32, color: p.primary),
        title: l10n.hintOfferTitle,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.hintOfferVideoBody(freeHintsPerPuzzle, offer.videosLeft), style: text.bodyLarge),
            const SizedBox(height: 8),
            Text(l10n.hintOfferVideoRule, style: text.bodySmall?.copyWith(color: p.inkMuted)),
          ],
        ),
        actions: [
          LudixaButton(
            label: l10n.hintOfferVideo,
            onPressed: () => choose(HintOfferChoice.video),
            variant: LudixaButtonVariant.rewarded,
          ),
          later,
        ],
      );
    }
    return LudixaSheet(
      leading: LudixaIcon(LudixaIcons.offline, size: 32, color: p.inkMuted),
      title: l10n.hintOfferTitle,
      body: Text(offer.courtesyAvailable ? l10n.hintOfferCourtesyBody : l10n.hintOfferNoneBody, style: text.bodyLarge),
      actions: [
        if (offer.courtesyAvailable)
          LudixaButton(label: l10n.hintOfferCourtesy, onPressed: () => choose(HintOfferChoice.courtesy))
        else
          LudixaButton(label: l10n.backupProblemOk, onPressed: () => choose(HintOfferChoice.cancel)),
        if (offer.courtesyAvailable) later,
      ],
    );
  }
}
