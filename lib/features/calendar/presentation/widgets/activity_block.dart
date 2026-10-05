import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/activity_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../../core/utils/date_format.dart';
import '../../../backlog/providers/tasks_providers.dart';

class ActivityBlock extends ConsumerWidget {
  const ActivityBlock({
    super.key,
    required this.occurrence,
    required this.onTap,
  });

  final Occurrence occurrence;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ac = ActivityColors.of(
      occurrence.color,
      Theme.of(context).brightness,
    );
    final bg = ac.background;
    final fg = ac.foreground;
    final ts = Theme.of(context).textTheme;
    final isLinked = occurrence.isLinkedToTask;
    final sessionsAsync = ref.watch(sessionsStreamProvider);
    final isCompleted =
        sessionsAsync.asData?.value.any(
          (s) =>
              s.activityId == occurrence.activityId &&
              s.date ==
                  DateTime(
                    occurrence.date.year,
                    occurrence.date.month,
                    occurrence.date.day,
                  ).millisecondsSinceEpoch &&
              s.completedAt != null,
        ) ??
        false;

    final content = Material(
      color: isCompleted ? bg.withValues(alpha: 0.62) : bg,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        onLongPress: isLinked
            ? () {
                final dur = occurrence.end
                    .difference(occurrence.start)
                    .inMinutes;
                ref
                    .read(sessionsRepositoryProvider)
                    .toggleCompleted(
                      occurrence.activityId,
                      occurrence.date,
                      actualMinutes: dur,
                    );
              }
            : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      occurrence.title,
                      style: ts.labelLarge?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isLinked) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.link,
                      size: 14,
                      color: fg.withValues(alpha: 0.9),
                    ),
                  ],
                ],
              ),
              Text(
                formatHourRange(occurrence.start, occurrence.end),
                style: ts.labelSmall?.copyWith(
                  color: fg.withValues(alpha: 0.85),
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );

    if (AppMotion.reduceMotion(context)) return content;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: AppMotion.base,
      curve: AppMotion.enter,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: content,
    );
  }
}
