import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Section title with an optional trailing count badge.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ts = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: ts.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '$count',
                style: ts.labelSmall?.copyWith(
                  color: cs.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
