import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_format.dart';

class DaysHeader extends StatelessWidget {
  const DaysHeader({super.key, required this.days});

  final List<DateTime> days;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          const SizedBox(width: 48),
          ...days.map((d) {
            final isToday = isSameDay(d, now);
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isToday
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxs,
                  vertical: AppSpacing.xs,
                ),
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
