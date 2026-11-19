import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/activity_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../../core/utils/date_format.dart';
import '../../../backlog/providers/tasks_providers.dart';
import '../../../settings/providers/settings_providers.dart';

class ActivityBlock extends ConsumerWidget {
  const ActivityBlock({
    super.key,
    required this.occurrence,
    required this.onTap,
    this.showResizeHandles = false,
    this.onResizeStart,
    this.onResizeUpdate,
    this.onResizeEnd,
  });

  final Occurrence occurrence;
  final VoidCallback onTap;
  final bool showResizeHandles;
  final void Function(DragStartDetails details, bool isTop)? onResizeStart;
  final void Function(DragUpdateDetails details)? onResizeUpdate;
  final void Function(DragEndDetails details)? onResizeEnd;

  static const double resizeHandleHeight = 24;

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

    void toggleSession() {
      final dur = occurrence.end.difference(occurrence.start).inMinutes;
      ref
          .read(sessionsRepositoryProvider)
          .toggleCompleted(
            occurrence.activityId,
            occurrence.date,
            actualMinutes: dur,
          );
    }

    final content = Material(
      color: isCompleted ? bg.withValues(alpha: 0.62) : bg,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: 1,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onLongPress: isLinked ? null : () {},
        child: InkWell(
          onTap: onTap,
          onLongPress: isLinked ? toggleSession : null,
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
                  formatHourRange(
                    occurrence.start,
                    occurrence.end,
                    use24Hour: ref
                        .watch(currentSettingsProvider)
                        .use24HourFormat,
                  ),
                  style: ts.labelSmall?.copyWith(
                    color: fg.withValues(alpha: 0.85),
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Widget body;
    if (showResizeHandles) {
      body = Stack(
        children: [
          Positioned.fill(child: content),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: resizeHandleHeight,
            child: _BlockResizeHandle(
              isTop: true,
              onTap: onTap,
              onLongPress: isLinked ? toggleSession : null,
              onDragStart: onResizeStart,
              onDragUpdate: onResizeUpdate,
              onDragEnd: onResizeEnd,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: resizeHandleHeight,
            child: _BlockResizeHandle(
              isTop: false,
              onTap: onTap,
              onLongPress: isLinked ? toggleSession : null,
              onDragStart: onResizeStart,
              onDragUpdate: onResizeUpdate,
              onDragEnd: onResizeEnd,
            ),
          ),
        ],
      );
    } else {
      body = content;
    }

    if (AppMotion.reduceMotion(context)) return body;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: AppMotion.base,
      curve: AppMotion.enter,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: body,
    );
  }
}

class _BlockResizeHandle extends StatelessWidget {
  const _BlockResizeHandle({
    required this.isTop,
    required this.onTap,
    required this.onLongPress,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final bool isTop;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final void Function(DragStartDetails, bool)? onDragStart;
  final void Function(DragUpdateDetails)? onDragUpdate;
  final void Function(DragEndDetails)? onDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      onVerticalDragStart: onDragStart == null
          ? null
          : (details) => onDragStart!(details, isTop),
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      child: Center(
        child: Container(
          width: 28,
          height: 3,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }
}
