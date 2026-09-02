import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/activity_colors.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../activities/providers/activities_stream_provider.dart';

class WeekView extends ConsumerWidget {
  const WeekView({super.key, required this.selectedDate});

  final DateTime selectedDate;

  static const double hourHeight = 48;
  static const double gutterWidth = 48;
  static const double totalHeight = 24 * hourHeight;

  DateTime get monday {
    final d = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return DateTime(d.year, d.month, d.day - (d.weekday - 1));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occurrences = ref.watch(weekOccurrencesProvider(selectedDate));
    final weekDays = List.generate(
      7,
      (i) => DateTime(monday.year, monday.month, monday.day + i),
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        _WeekHeader(weekDays: weekDays),
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height: totalHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: gutterWidth,
                    child: Column(
                      children: List.generate(24, (h) {
                        return SizedBox(
                          height: hourHeight,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6, top: 2),
                              child: Text(
                                '${h.toString().padLeft(2, '0')}:00',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  ...weekDays.map((day) {
                    final dayOcc = occurrences
                        .where((o) => _isSameDay(o.date, day))
                        .toList();
                    final isToday = _isSameDay(day, DateTime.now());
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isToday
                              ? colorScheme.primaryContainer.withValues(
                                  alpha: 0.15,
                                )
                              : null,
                          border: Border(
                            left: BorderSide(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) {
                            final localY = details.localPosition.dy;
                            final h = (localY / hourHeight)
                                .clamp(0, 23)
                                .toInt();
                            context.go(
                              '/activity/new?date=${day.toIso8601String()}&hour=$h',
                            );
                          },
                          child: Stack(
                            children: [
                              Column(
                                children: List.generate(24, (h) {
                                  return Container(
                                    height: hourHeight,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: colorScheme.outlineVariant
                                              .withValues(alpha: 0.3),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              ...dayOcc.map((occ) {
                                final startMin =
                                    occ.start.hour * 60 + occ.start.minute;
                                final endMin =
                                    occ.end.hour * 60 + occ.end.minute;
                                final top = startMin / 60 * hourHeight;
                                final height =
                                    (endMin - startMin) / 60 * hourHeight;
                                return Positioned(
                                  top: top + 1,
                                  left: 2,
                                  right: 2,
                                  height: height.clamp(18, totalHeight),
                                  child: _WeekBlock(occurrence: occ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.weekDays});
  final List<DateTime> weekDays;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          const SizedBox(width: 48),
          ...weekDays.map((d) {
            final isToday = _isSameDay(d, now);
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isToday
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'es').format(d),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isToday
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    Text(
                      '${d.day}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: isToday ? FontWeight.bold : null,
                        color: isToday
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WeekBlock extends StatelessWidget {
  const _WeekBlock({required this.occurrence});
  final Occurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final bg = activityColor(occurrence.color);
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return GestureDetector(
      onTap: () => context.go('/activity/${occurrence.activityId}'),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          occurrence.title,
          style: TextStyle(
            color: fg,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
