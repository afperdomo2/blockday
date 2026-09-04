import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/activity_colors.dart';
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
    final bg = activityColor(occurrence.color);
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;
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

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Material(
        color: isCompleted ? bg.withValues(alpha: 0.62) : bg,
        borderRadius: BorderRadius.circular(8),
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
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        occurrence.title,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLinked) ...[
                      const SizedBox(width: 4),
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
                  style: TextStyle(
                    color: fg.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
