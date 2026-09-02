import 'package:flutter/material.dart';

import '../../../../core/theme/activity_colors.dart';
import '../../../activities/domain/occurrence.dart';
import '../../../../core/utils/date_format.dart';

class ActivityBlock extends StatelessWidget {
  const ActivityBlock({
    super.key,
    required this.occurrence,
    required this.onTap,
  });

  final Occurrence occurrence;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = activityColor(occurrence.color);
    final fg = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  occurrence.title,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
