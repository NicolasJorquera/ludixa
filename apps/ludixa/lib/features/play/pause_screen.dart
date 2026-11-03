import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:game_api/game_api.dart';

import '../../l10n/generated/app_localizations.dart';

/// Pausa: el tablero queda oculto y el tiempo detenido. "Reanudar" es la
/// acción principal y el gesto atrás equivale a reanudar. Reiniciar pide
/// confirmación dentro de la propia pantalla. Sin anuncios.
class PauseScreen extends StatefulWidget {
  const PauseScreen({super.key, required this.module, required this.host});

  final GameModule module;
  final GameHost host;

  /// Abre la pausa como pantalla completa y devuelve la elección.
  static Future<PauseChoice> show(BuildContext context, GameModule module, GameHost host) async =>
      await Navigator.of(context).push<PauseChoice>(
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (context, _, _) => PauseScreen(module: module, host: host),
          transitionsBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
        ),
      ) ??
      PauseChoice.resume;

  @override
  State<PauseScreen> createState() => _PauseScreenState();
}

class _PauseScreenState extends State<PauseScreen> {
  bool _confirmRestart = false;

  void _close(PauseChoice choice) => Navigator.of(context).pop(choice);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = Theme.of(context).extension<LudixaColors>()!.palette;
    final settings = widget.module.buildSettings(context);
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: Text(l10n.pauseTitle), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: LudixaLayout.page(context, top: 16, bottom: 16),
          children: [
            Semantics(
              liveRegion: true,
              child: Container(
                height: 160,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: p.surfaceMuted, borderRadius: BorderRadius.circular(16)),
                child: Text(l10n.pauseBoardHidden, style: text.titleMedium?.copyWith(color: p.inkMuted)),
              ),
            ),
            const SizedBox(height: 24),
            LudixaButton(label: l10n.pauseResume, onPressed: () => _close(PauseChoice.resume)),
            const SizedBox(height: 16),
            if (_confirmRestart)
              LudixaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.pauseRestartConfirm, style: text.bodyLarge),
                    const SizedBox(height: 12),
                    LudixaButton(
                      label: l10n.pauseRestartYes,
                      onPressed: () => _close(PauseChoice.restart),
                      variant: LudixaButtonVariant.secondary,
                    ),
                    const SizedBox(height: 8),
                    LudixaButton(
                      label: l10n.pauseCancel,
                      onPressed: () => setState(() => _confirmRestart = false),
                      variant: LudixaButtonVariant.tertiary,
                    ),
                  ],
                ),
              )
            else
              LudixaListRow(
                title: l10n.pauseRestart,
                leading: const LudixaIcon(LudixaIcons.restart),
                onTap: () => setState(() => _confirmRestart = true),
              ),
            LudixaListRow(
              title: l10n.pauseHowToPlay,
              leading: const LudixaIcon(LudixaIcons.help),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (context) => widget.module.buildTutorial(context, widget.host))),
            ),
            if (settings != null)
              LudixaListRow(
                title: l10n.pauseGameSettings,
                leading: const LudixaIcon(LudixaIcons.settings),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => Scaffold(
                      appBar: AppBar(title: Text(l10n.pauseGameSettings)),
                      body: SingleChildScrollView(child: widget.module.buildSettings(context)),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            LudixaButton(
              label: l10n.pauseSaveExit,
              onPressed: () => _close(PauseChoice.exit),
              variant: LudixaButtonVariant.secondary,
            ),
            const SizedBox(height: 8),
            Text(l10n.pauseAutosave, style: text.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
