import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../activities/domain/activity.dart';
import '../../../activities/providers/activities_stream_provider.dart';
import '../../../backlog/providers/tasks_providers.dart';
import '../../../../core/responsive/constrained_content.dart';
import '../../../../core/theme/activity_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';
import '../../../settings/providers/settings_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/search_filter.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activities =
        ref.watch(activitiesStreamProvider).asData?.value ?? const [];
    final tasks = ref.watch(tasksStreamProvider).asData?.value ?? const [];
    final matchedActivities = filterActivities(activities, _query);
    final matchedTasks = filterTasks(tasks, _query);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar actividades y tareas...',
            border: InputBorder.none,
            isDense: true,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        centerTitle: false,
      ),
      body: ConstrainedContent(
        maxWidth: AppContentWidth.list,
        child: _query.trim().isEmpty
            ? const _SearchHint(
                icon: Icons.search,
                text: 'Escribe para buscar en tus actividades y tareas',
              )
            : matchedActivities.isEmpty && matchedTasks.isEmpty
            ? _SearchHint(
                icon: Icons.search_off,
                text: 'Sin resultados para "$_query"',
              )
            : ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                children: [
                  if (matchedActivities.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xs,
                      ),
                      child: SectionHeader(
                        title: 'Actividades',
                        count: matchedActivities.length,
                      ),
                    ),
                    ...matchedActivities.map(
                      (a) => _ActivityResultTile(activity: a),
                    ),
                  ],
                  if (matchedTasks.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.xs,
                      ),
                      child: SectionHeader(
                        title: 'Tareas',
                        count: matchedTasks.length,
                      ),
                    ),
                    ...matchedTasks.map(
                      (t) => _TaskResultTile(
                        title: t.title,
                        subtitle: t.tags.isEmpty
                            ? null
                            : t.tags.map((tag) => '#$tag').join('  '),
                        onTap: () => context.go('/backlog/task/${t.id}'),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _ActivityResultTile extends ConsumerWidget {
  const _ActivityResultTile({required this.activity});

  final Activity activity;

  String _subtitle(bool use24Hour) {
    if (activity.kind == ActivityKind.single) {
      return '${formatDayShort(activity.singleStart!)} · ${formatHourRange(activity.singleStart!, activity.singleEnd!, use24Hour: use24Hour)}';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = activity
        .occurrencesInRange(today, today.add(const Duration(days: 30)))
        .firstOrNull;
    return next == null
        ? 'Recurrente'
        : 'Recurrente · próximo ${formatDayShort(next.date)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final use24Hour = ref.watch(currentSettingsProvider).use24HourFormat;
    final colors = ActivityColors.of(
      activity.color,
      Theme.of(context).brightness,
    );
    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + AppSpacing.xxs,
      ),
      onTap: () => context.go('/activity/${activity.id}?from=/search'),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 34,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  _subtitle(use24Hour),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskResultTile extends StatelessWidget {
  const _TaskResultTile({
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + AppSpacing.xxs,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.7),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 20,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: EmptyState(icon: icon, title: text),
      ),
    );
  }
}
