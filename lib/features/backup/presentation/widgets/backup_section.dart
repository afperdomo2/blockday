import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/section_header.dart';
import '../../../notifications/providers/notifications_providers.dart';
import '../../domain/backup_document.dart';
import '../../providers/backup_providers.dart';

class BackupSection extends ConsumerWidget {
  const BackupSection({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await ref.read(backupRepositoryProvider).exportJson();
      final now = DateTime.now();
      final stamp =
          '${now.year.toString().padLeft(4, '0')}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}'
          '-${now.hour.toString().padLeft(2, '0')}'
          '${now.minute.toString().padLeft(2, '0')}';
      final saved = await ref
          .read(backupFileServiceProvider)
          .saveBackupContent(json, 'blockday-backup-$stamp.json');
      messenger.showSnackBar(
        SnackBar(
          content: Text(saved ? 'Copia exportada' : 'Exportación cancelada'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importar copia de seguridad'),
        content: const Text(
          'Se reemplazarán todos los datos actuales por los del archivo. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final content = await ref
          .read(backupFileServiceProvider)
          .pickBackupContent();
      if (content == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Importación cancelada')),
        );
        return;
      }
      await ref.read(backupRepositoryProvider).importReplaceAll(content);
      await ref.read(remindersControllerProvider).rescheduleAll();
      messenger.showSnackBar(const SnackBar(content: Text('Copia importada')));
    } on BackupFormatException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Archivo no válido: ${e.message}')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error al importar: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Datos'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Exportar copia de seguridad'),
                subtitle: const Text(
                  'Guarda tareas, bloques y sesiones en un archivo JSON',
                ),
                onTap: () => _export(context, ref),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.upload),
                title: const Text('Importar copia de seguridad'),
                subtitle: const Text('Reemplaza todos los datos actuales'),
                onTap: () => _import(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
