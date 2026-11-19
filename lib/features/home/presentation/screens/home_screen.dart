import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsive/constrained_content.dart';
import '../../../../core/theme/activity_colors.dart';
import '../../../../core/theme/app_icon_size.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../shared/widgets/about_dialog.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../../../shared/widgets/brand_mark.dart';
import '../../../../shared/widgets/date_hero.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../../../shared/widgets/search_action.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/settings_action.dart';
import '../../../../shared/widgets/staggered_entrance.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../activities/providers/activities_stream_provider.dart';
import '../../../backlog/domain/task.dart';
import '../../../backlog/presentation/widgets/task_tile.dart';
import '../../../backlog/providers/tasks_providers.dart';
import '../../../settings/providers/settings_providers.dart';
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
      appBar: AppBar(
        title: Row(
          children: [
            const BrandMark(size: 26),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Text('Inicio', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          const SearchAction(),
          const SettingsAction(),
          IconButton(
            tooltip: 'Acerca de',
            icon: const Icon(Icons.info_outline),
            onPressed: () => showBlockdayAboutDialog(context),
          ),
        ],
      ),
      body: ConstrainedContent(
        maxWidth: AppContentWidth.list,
        child: StaggeredEntrance(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.jumbo * 2,
            ),
            children: [
              StaggeredItem(
                index: 0,
                child: DateHero(
                  date: today,
                  label: 'Hoy',
                  caption: formatDayHeader(today),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              StaggeredItem(index: 1, child: _QuickActions(today: today)),
              const SizedBox(height: AppSpacing.lg),
              StaggeredItem(index: 2, child: _WeekSummary(progress: weekly)),
              const SizedBox(height: AppSpacing.xl),
              StaggeredItem(
                index: 3,
                child: SectionHeader(
                  title: 'Programado hoy',
                  count: todayOccurrences.length,
                ),
              ),
              if (todayOccurrences.isEmpty)
                const StaggeredItem(
                  index: 4,
                  child: EmptyHint(
                    icon: Icons.event_available_outlined,
                    text: 'Sin actividades hoy',
                  ),
                )
              else
                ...todayOccurrences.asMap().entries.map(
                  (e) => StaggeredItem(
                    index: 4 + e.key,
                    child: _OccurrenceTile(occurrence: e.value),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              StaggeredItem(
                index: 10,
                child: SectionHeader(title: 'Próximos', count: upcoming.length),
              ),
              if (upcoming.isEmpty)
                const StaggeredItem(
                  index: 11,
                  child: EmptyHint(
                    icon: Icons.event_note_outlined,
                    text: 'Sin eventos en los próximos días',
                  ),
                )
              else
                ...upcoming
                    .take(8)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => StaggeredItem(
                        index: 11 + e.key,
                        child: _OccurrenceTile(
                          occurrence: e.value,
                          showDate: true,
                        ),
                      ),
                    ),
              const SizedBox(height: AppSpacing.xl),
              StaggeredItem(
                index: 20,
                child: SectionHeader(
                  title: 'Tareas sin programar',
                  count: pendingTasks.length,
                ),
              ),
              if (pendingTasks.isEmpty)
                const StaggeredItem(
                  index: 21,
                  child: EmptyHint(
                    icon: Icons.task_alt_outlined,
                    text: 'Nada pendiente. Todo está programado.',
                  ),
                )
              else
                ...pendingTasks.asMap().entries.map(
                  (e) => StaggeredItem(
                    index: 21 + e.key,
                    child: TaskTile(
                      task: e.value,
                      onTap: () => context.go('/backlog/task/${e.value.id}'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              boxShadow: AppShadows.brand(cs.primary, brightness),
            ),
            child: FilledButton.icon(
              icon: const Icon(Icons.event, size: AppIconSize.md),
              label: const Text('Nueva actividad'),
              onPressed: () => context.go(
                '/activity/new?date=${today.toIso8601String()}&from=/',
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilledButton.tonalIcon(
            icon: const Icon(Icons.playlist_add, size: AppIconSize.md),
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

    return AppCard(
      child: Row(
        children: [
          ProgressRing(
            value: ratio,
            size: 64,
            child: Text(
              '${(ratio * 100).round()}%',
              style: ts.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights,
                      size: AppIconSize.sm,
                      color: cs.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Resumen semanal',
                      style: ts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  planned == 0
                      ? 'Sin sesiones programadas esta semana'
                      : '$shown de $planned sesiones completadas',
                  style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppProgressBar(value: ratio, minHeight: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OccurrenceTile extends ConsumerWidget {
  const _OccurrenceTile({required this.occurrence, this.showDate = false});

  final Occurrence occurrence;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    final use24 = ref.watch(currentSettingsProvider).use24HourFormat;
    final time = showDate
        ? '${formatDayShort(occurrence.date)} · '
              '${formatHourRange(occurrence.start, occurrence.end, use24Hour: use24)}'
        : formatHourRange(occurrence.start, occurrence.end, use24Hour: use24);
    final accent = ActivityColors.of(
      occurrence.color,
      Theme.of(context).brightness,
    ).background;

    return AppCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + AppSpacing.xxs,
      ),
      onTap: () => context.go('/activity/${occurrence.activityId}?from=/'),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 34,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  occurrence.title,
                  style: ts.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  time,
                  style: ts.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (occurrence.isLinkedToTask)
            Icon(Icons.link, size: AppIconSize.sm, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
