import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icon_size.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_check_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../domain/task.dart';
import '../../providers/tasks_providers.dart';
import '../task_labels.dart';

class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  void _toggleCompleted(BuildContext context, WidgetRef ref, bool next) {
    ref.read(tasksRepositoryProvider).setCompleted(task.id, next);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(next ? 'Tarea marcada como hecha' : 'Tarea reabierta'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () =>
              ref.read(tasksRepositoryProvider).setCompleted(task.id, !next),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(taskProgressProvider(task.id));
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;

    String subtitle;
    if (progress.status == TaskStatus.completed) {
      subtitle = 'Hecha · ${kindLabel(task.kind)}';
    } else if (progress.isUnscheduled) {
      subtitle = statusLabel(progress.status);
    } else if (progress.totalPlannedSessions > 0) {
      final hPlan = (progress.totalPlannedMinutes / 60).toStringAsFixed(1);
      final hAct = (progress.totalActualMinutes / 60).toStringAsFixed(1);
      if (progress.completedSessions > 0) {
        subtitle =
            '${progress.completedSessions}/${progress.totalPlannedSessions} sesiones · $hAct/$hPlan h';
      } else {
        subtitle =
            '${progress.totalPlannedSessions} sesiones · $hPlan h · ${statusLabel(progress.status)}';
      }
    } else {
      subtitle = '${progress.linkedActivitiesCount} bloques vinculados';
    }

    final hasLink = !progress.isUnscheduled;
    final completed = progress.status == TaskStatus.completed;

    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.7),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(
              kindIcon(task.kind),
              size: AppIconSize.md,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: ts.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasLink)
                      Container(
                        margin: const EdgeInsets.only(left: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.link,
                              size: 12,
                              color: cs.onSecondaryContainer,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Text(
                              '${progress.linkedActivitiesCount}',
                              style: ts.labelSmall?.copyWith(
                                color: cs.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.estimatedMinutes != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Estimado: ${(task.estimatedMinutes! / 60).toStringAsFixed(1)} h',
                    style: ts.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                if (task.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xxs,
                    children: task.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                              border: Border.all(
                                color: cs.outlineVariant.withValues(alpha: 0.8),
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: ts.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (progress.linkedActivitiesCount > 0 &&
                    progress.totalPlannedSessions > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppProgressBar(value: progress.completionRatio, minHeight: 4),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: hasLink ? cs.primaryContainer : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              kindLabel(task.kind),
              style: ts.labelSmall?.copyWith(
                color: hasLink ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          AnimatedCheckButton(
            checked: completed,
            checkedColor: AppColors.success,
            tooltip: completed ? 'Reabrir' : 'Marcar hecha',
            onChanged: (next) => _toggleCompleted(context, ref, next),
          ),
        ],
      ),
    );
  }
}
