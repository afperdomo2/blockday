import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';

/// Current-time indicator: fading line with a solid dot.
class NowLine extends StatelessWidget {
  const NowLine({super.key, this.leadingWidth = 0});

  final double leadingWidth;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(width: leadingWidth),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: cs.primary,
            shape: BoxShape.circle,
            border: Border.all(color: cs.surface, width: 2),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withValues(alpha: 0.15)],
              ),
              borderRadius: AppRadius.pillAll,
            ),
          ),
        ),
      ],
    );
  }
}
