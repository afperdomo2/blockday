import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';

/// Shared linear progress indicator with tokenized rounding and track color.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value, this.minHeight = 6});

  final double value;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: LinearProgressIndicator(
        value: value,
        minHeight: minHeight,
        backgroundColor: cs.surfaceContainerHighest,
      ),
    );
  }
}
