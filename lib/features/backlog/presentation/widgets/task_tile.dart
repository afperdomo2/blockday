import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/task.dart';
import '../../providers/tasks_providers.dart';

String _kindLabel(TaskKind kind) {
  switch (kind) {
    case TaskKind.task:
      return 'Tarea';
    case TaskKind.learning:
      return 'Aprendizaje';
    case TaskKind.note:
      return 'Nota';
    case TaskKind.project:
      return 'Proyecto';
  }
}

String _statusLabel(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return 'Sin programar';
    case TaskStatus.scheduled:
      return 'Programada';
    case TaskStatus.inProgress:
      return 'En progreso';
    case TaskStatus.completed:
      return 'Hecha';
  }
}

IconData _kindIcon(TaskKind kind) {
  switch (kind) {
    case TaskKind.task:
      return Icons.check_circle_outline;
    case TaskKind.learning:
      return Icons.school_outlined;
    case TaskKind.note:
      return Icons.note_outlined;
    case TaskKind.project:
      return Icons.folder_outlined;
  }
}

class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(taskProgressProvider(task.id));
    final cs = Theme.of(context).colorScheme;

    String subtitle;
    if (progress.status == TaskStatus.completed) {
      subtitle = 'Hecha · ${_kindLabel(task.kind)}';
    } else if (progress.isUnscheduled) {
      subtitle = _statusLabel(progress.status);
    } else if (progress.totalPlannedSessions > 0) {
      final hPlan = (progress.totalPlannedMinutes / 60).toStringAsFixed(1);
      final hAct = (progress.totalActualMinutes / 60).toStringAsFixed(1);
      if (progress.completedSessions > 0) {
        subtitle =
            '${progress.completedSessions}/${progress.totalPlannedSessions} sesiones · $hAct/$hPlan h';
      } else {
        subtitle =
            '${progress.totalPlannedSessions} sesiones · $hPlan h · ${_statusLabel(progress.status)}';
      }
    } else {
      subtitle = '${progress.linkedActivitiesCount} bloques vinculados';
    }

    final hasLink = !progress.isUnscheduled;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(_kindIcon(task.kind), color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
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
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 12,
                                  color: cs.onSecondaryContainer,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${progress.linkedActivitiesCount}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.estimatedMinutes != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Estimado: ${(task.estimatedMinutes! / 60).toStringAsFixed(1)} h',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                    if (progress.linkedActivitiesCount > 0 &&
                        progress.totalPlannedSessions > 0) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.completionRatio,
                          minHeight: 4,
                          backgroundColor: cs.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasLink
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _kindLabel(task.kind),
                  style: TextStyle(
                    fontSize: 11,
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
                      ? cs.primary
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
