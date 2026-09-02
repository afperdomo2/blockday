import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/activity_colors.dart';
import '../../../activities/providers/activities_stream_provider.dart';

class MonthView extends ConsumerWidget {
  const MonthView({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = selectedDate.year;
    final month = selectedDate.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final firstWeekday = firstDay.weekday;
    final daysInMonth = lastDay.day;
    final leadingEmpty = firstWeekday - 1;
    final totalCells = 42;

    final rangeStart = DateTime(year, month, 1);
    final rangeEnd = DateTime(year, month, daysInMonth);
    final occurrences = ref.watch(
      rangeOccurrencesProvider((start: rangeStart, end: rangeEnd)),
    );
    final countByDay = <DateTime, int>{};
    for (final o in occurrences) {
      final key = DateTime(o.date.year, o.date.month, o.date.day);
      countByDay[key] = (countByDay[key] ?? 0) + 1;
    }
    final colorsByDay = <DateTime, List<int>>{};
    for (final o in occurrences) {
      final key = DateTime(o.date.year, o.date.month, o.date.day);
      colorsByDay.putIfAbsent(key, () => []).add(o.color);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            DateFormat('MMMM y', 'es').format(selectedDate),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        _WeekdayHeader(),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final dayIndex = index - leadingEmpty + 1;
              if (dayIndex < 1 || dayIndex > daysInMonth) {
                return const SizedBox.shrink();
              }
              final date = DateTime(year, month, dayIndex);
              final isToday = _isSameDay(date, DateTime.now());
              final isSelected = _isSameDay(date, selectedDate);
              final count = countByDay[date] ?? 0;
              final colors = colorsByDay[date] ?? const [];
              return GestureDetector(
                onTap: () =>
                    context.go('/activity/new?date=${date.toIso8601String()}'),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : isToday
                        ? Theme.of(context).colorScheme.secondaryContainer
                              .withValues(alpha: 0.5)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '$dayIndex',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isToday || isSelected
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 2,
                          children: colors.take(3).map((c) {
                            return Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: activityColor(c),
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                        if (count > 3)
                          Text(
                            '+${count - 3}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontSize: 9),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Row(
      children: labels
          .map(
            (l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
