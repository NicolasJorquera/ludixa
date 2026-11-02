import 'package:flutter/material.dart';

/// Contenido estándar de una hoja inferior: título, cuerpo y acciones apiladas.
class LudixaSheet extends StatelessWidget {
  const LudixaSheet({super.key, required this.title, this.body, this.leading, this.actions = const []});

  final String title;
  final Widget? body;

  /// Icono o ilustración sobre el título.
  final Widget? leading;

  /// Botones, de la acción principal a la de menor peso.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(22, 0, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (leading != null) ...[
              Align(alignment: AlignmentDirectional.centerStart, child: leading),
              const SizedBox(height: 12),
            ],
            Semantics(header: true, child: Text(title, style: text.headlineSmall)),
            if (body != null) ...[const SizedBox(height: 10), body!],
            if (actions.isNotEmpty) const SizedBox(height: 20),
            for (var i = 0; i < actions.length; i++) ...[if (i > 0) const SizedBox(height: 10), actions[i]],
          ],
        ),
      ),
    );
  }
}

/// Abre una hoja inferior modal con el estilo de Ludixa.
Future<T?> showLudixaSheet<T>(BuildContext context, {required WidgetBuilder builder, bool dismissible = true}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: dismissible,
    enableDrag: dismissible,
    builder: builder,
  );
}
