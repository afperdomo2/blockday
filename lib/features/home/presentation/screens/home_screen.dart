import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/activity_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../activities/providers/activities_stream_provider.dart';
import '../../../backlog/domain/task.dart';
import '../../../backlog/presentation/widgets/task_tile.dart';
import '../../../backlog/providers/tasks_providers.dart';
import '../../providers/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final nextWeek = DateTime(today.year, today.month, today.day + 7);

    final todayOccurrences = ref.watch(dayOccurrencesProvider(today));
    final upcoming = ref.watch(
      rangeOccurrencesProvider((start: tomorrow, end: nextWeek)),
    );
    final tasks =
        ref.watch(tasksStreamProvider).asData?.value ?? const <Task>[];
    final weekly = ref.watch(weeklyProgressProvider(today));

    final pendingTasks = <Task>[
      for (final t in tasks)
        if (ref.watch(taskStatusProvider(t.id)) == TaskStatus.pending) t,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _TodayHeader(date: today),
          const SizedBox(height: 12),
          _QuickActions(today: today),
          const SizedBox(height: 16),
          _WeekSummary(progress: weekly),
          const SizedBox(height: 20),
          _SectionHeader(
            title: 'Programado hoy',
            count: todayOccurrences.length,
          ),
          if (todayOccurrences.isEmpty)
            const _EmptyText('Sin actividades hoy')
          else
            ...todayOccurrences.map((o) => _OccurrenceTile(occurrence: o)),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Próximos', count: upcoming.length),
          if (upcoming.isEmpty)
            const _EmptyText('Sin eventos en los próximos días')
          else
            ...upcoming
                .take(8)
                .map((o) => _OccurrenceTile(occurrence: o, showDate: true)),
          const SizedBox(height: 20),
          _SectionHeader(
            title: 'Tareas sin programar',
            count: pendingTasks.length,
          ),
          if (pendingTasks.isEmpty)
            const _EmptyText('Nada pendiente. Todo está programado.')
          else
            ...pendingTasks.map(
              (t) => TaskTile(
                task: t,
                onTap: () => context.go('/backlog/task/${t.id}'),
              ),
            ),
        ],
      ),
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoy',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatDayHeader(date),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            icon: const Icon(Icons.event),
            label: const Text('Nueva actividad'),
            onPressed: () => context.go(
              '/activity/new?date=${today.toIso8601String()}&from=/',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonalIcon(
            icon: const Icon(Icons.playlist_add),
            label: const Text('Nueva tarea'),
            onPressed: () => context.go('/backlog/task/new'),
          ),
        ),
      ],
    );
  }
}

class _WeekSummary extends StatelessWidget {
  const _WeekSummary({required this.progress});

  final WeeklyProgress progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final planned = progress.planned;
    final completed = progress.completed;
    final shown = completed > planned ? planned : completed;
    final ratio = planned == 0 ? 0.0 : (completed / planned).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Resumen semanal',
                  style: ts.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              planned == 0
                  ? 'Sin sesiones programadas esta semana'
                  : '$shown de $planned sesiones completadas',
              style: ts.titleMedium,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            title,
            style: ts.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: ts.labelSmall?.copyWith(color: cs.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _OccurrenceTile extends StatelessWidget {
  const _OccurrenceTile({required this.occurrence, this.showDate = false});

  final Occurrence occurrence;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final time = showDate
        ? '${formatDayShort(occurrence.date)} · '
              '${formatHourRange(occurrence.start, occurrence.end)}'
        : formatHourRange(occurrence.start, occurrence.end);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/activity/${occurrence.activityId}?from=/'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: activityColor(occurrence.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      occurrence.title,
                      style: ts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (occurrence.isLinkedToTask)
                Icon(Icons.link, size: 16, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
