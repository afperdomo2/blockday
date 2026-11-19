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
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        onTap: () => context.go('/activity/${activity.id}?from=/search'),
        leading: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: colors.background,
            shape: BoxShape.circle,
            border: Border.all(color: colors.foreground.withValues(alpha: 0.4)),
          ),
        ),
        title: Text(
          activity.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_subtitle(use24Hour)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
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
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.check_circle_outline),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: subtitle == null ? null : Text(subtitle!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
