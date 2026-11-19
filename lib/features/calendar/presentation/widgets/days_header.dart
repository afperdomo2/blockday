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
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    return Container(
      color: cs.surfaceContainerLow,
      child: Row(
        children: [
          const SizedBox(width: 48),
          ...days.map((d) {
            final isToday = isSameDay(d, now);
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isToday ? cs.primary : null,
                  borderRadius: AppRadius.mdAll,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxs,
                  vertical: AppSpacing.xs,
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'es').format(d),
                      style: ts.labelSmall?.copyWith(
                        color: isToday
                            ? cs.onPrimary.withValues(alpha: 0.85)
                            : cs.onSurfaceVariant,
                        fontWeight: isToday ? FontWeight.w600 : null,
                      ),
                    ),
                    Text(
                      '${d.day}',
                      style: ts.titleSmall?.copyWith(
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday ? cs.onPrimary : cs.onSurface,
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
