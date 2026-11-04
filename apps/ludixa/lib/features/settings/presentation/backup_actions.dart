import 'dart:convert';
import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:progress/progress.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../play/play_providers.dart';

/// Guardar y abrir el archivo de respaldo con el selector del sistema. Las
/// pruebas ponen una versión en memoria.
abstract interface class BackupFiles {
  /// Devuelve false si la persona cancela.
  Future<bool> save(String fileName, Uint8List bytes);

  /// Contenido del archivo elegido, o null si cancela.
  Future<Uint8List?> open();
}

final class SystemBackupFiles implements BackupFiles {
  const SystemBackupFiles();

  @override
  Future<bool> save(String fileName, Uint8List bytes) async =>
      await FilePicker.saveFile(fileName: fileName, bytes: bytes, mimeType: 'application/json') != null;

  @override
  Future<Uint8List?> open() async {
    final files = await FilePicker.pickFiles();
    return files.isEmpty ? null : files.single.readAsBytes();
  }
}

final backupFilesProvider = Provider<BackupFiles>((ref) => const SystemBackupFiles());

/// Ajustes › Exportar progreso.
Future<void> exportProgress(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final service = ref.read(progressServiceProvider);
  final json = await service.exportBackup();
  final day = service.clock.now().day.toIso8601();
  try {
    final saved = await ref.read(backupFilesProvider).save('ludixa-progreso-$day.json', utf8.encode(json));
    if (saved) messenger.showSnackBar(SnackBar(content: Text(l10n.backupExported)));
  } on Exception {
    messenger.showSnackBar(SnackBar(content: Text(l10n.backupSaveFailed)));
  }
}

/// Ajustes › Importar progreso: valida todo el archivo, muestra qué trae y
/// pide confirmar antes de reemplazar.
Future<void> importProgress(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final Uint8List? bytes;
  try {
    bytes = await ref.read(backupFilesProvider).open();
  } on Exception {
    messenger.showSnackBar(SnackBar(content: Text(l10n.backupOpenFailed)));
    return;
  }
  if (bytes == null || !context.mounted) return;
  final ProgressBackupData data;
  try {
    data = ProgressBackup.parse(utf8.decode(bytes, allowMalformed: true));
  } on BackupException catch (e) {
    await _showProblem(context, e.problem);
    return;
  }
  if (!context.mounted) return;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final locale = Localizations.localeOf(context).toLanguageTag();
      return LudixaSheet(
        title: l10n.backupImportTitle,
        body: Text(
          l10n.backupImportBody(
            DateFormat.yMMMMd(locale).format(data.exportedAt.toLocal()),
            data.sessions.length,
            data.completed,
            data.streak.best,
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          LudixaButton(
            label: l10n.backupImportConfirm,
            onPressed: () => Navigator.pop(context, true),
            variant: LudixaButtonVariant.secondary,
          ),
          LudixaButton(
            label: l10n.pauseCancel,
            onPressed: () => Navigator.pop(context, false),
            variant: LudixaButtonVariant.tertiary,
          ),
        ],
      );
    },
  );
  if (confirmed != true) return;
  await ref.read(progressServiceProvider).importBackup(data);
  ref.read(progressRevisionProvider.notifier).bump();
  messenger.showSnackBar(SnackBar(content: Text(l10n.backupImported)));
}

Future<void> _showProblem(BuildContext context, BackupProblem problem) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (context) => LudixaSheet(
      title: l10n.backupProblemTitle,
      body: Text(switch (problem) {
        BackupProblem.notJson || BackupProblem.notLudixa => l10n.backupNotLudixa,
        BackupProblem.newerVersion => l10n.backupNewerVersion,
        BackupProblem.corrupt => l10n.backupCorrupt,
      }, style: Theme.of(context).textTheme.bodyLarge),
      actions: [LudixaButton(label: l10n.backupProblemOk, onPressed: () => Navigator.pop(context))],
    ),
  );
}
