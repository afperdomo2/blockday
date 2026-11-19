import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/build_info/build_info.dart';
import '../../core/build_info/build_info_provider.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

Future<void> showBlockdayAboutDialog(BuildContext context) {
  final reduceMotion = AppMotion.reduceMotion(context);
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cerrar',
    barrierColor: Colors.black54,
    transitionDuration: reduceMotion ? Duration.zero : AppMotion.fast,
    pageBuilder: (context, _, _) => const BlockdayAboutDialog(),
    transitionBuilder: (context, animation, _, child) {
      if (reduceMotion) return child;
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: AppMotion.enter),
        child: child,
      );
    },
  );
}

class BlockdayAboutDialog extends ConsumerWidget {
  const BlockdayAboutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final info = ref.watch(buildInfoProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: AppSpacing.jumbo,
                    height: AppSpacing.jumbo,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: AppRadius.lgAll,
                    ),
                    child: Icon(
                      Icons.calendar_month,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blockday',
                          style: ts.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Calendario de bloques de tiempo',
                          style: ts.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              info.when(
                data: (value) => _InfoTable(info: value),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => _InfoTable(info: BuildInfo.unknown()),
              ),
              const SizedBox(height: AppSpacing.xl),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTable extends StatelessWidget {
  const _InfoTable({required this.info});

  final BuildInfo info;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _InfoRow(label: 'Versión', value: info.versionLabel),
        _InfoRow(label: 'Commit', value: info.commitLabel),
        _InfoRow(label: 'Compilado', value: info.buildDateLabel),
        _InfoRow(label: 'Plataforma', value: info.platform),
        _InfoRow(label: 'Canal', value: info.channel),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: ts.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
