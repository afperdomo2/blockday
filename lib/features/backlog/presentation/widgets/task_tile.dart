import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../domain/task.dart';
import '../../providers/tasks_providers.dart';
import '../task_labels.dart';

class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

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

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(kindIcon(task.kind), color: cs.primary),
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
                              decoration:
                                  progress.status == TaskStatus.completed
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
                              vertical: AppSpacing.xs,
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
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  '${progress.linkedActivitiesCount}',
                                  style: ts.labelSmall?.copyWith(
                                    color: cs.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.estimatedMinutes != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Estimado: ${(task.estimatedMinutes! / 60).toStringAsFixed(1)} h',
                        style: ts.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (progress.linkedActivitiesCount > 0 &&
                        progress.totalPlannedSessions > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppProgressBar(
                        value: progress.completionRatio,
                        minHeight: 4,
                      ),
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
                  color: hasLink
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  kindLabel(task.kind),
                  style: ts.labelSmall?.copyWith(
                    color: hasLink
                        ? cs.onPrimaryContainer
                        : cs.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  progress.status == TaskStatus.completed
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  size: 22,
                  color: progress.status == TaskStatus.completed
                      ? AppColors.success
                      : cs.onSurfaceVariant,
                ),
                tooltip: progress.status == TaskStatus.completed
                    ? 'Reabrir'
                    : 'Marcar hecha',
                onPressed: () {
                  ref
                      .read(tasksRepositoryProvider)
                      .setCompleted(
                        task.id,
                        progress.status != TaskStatus.completed,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
