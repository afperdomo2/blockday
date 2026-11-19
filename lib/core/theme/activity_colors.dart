import 'package:flutter/material.dart';

/// An activity category color pair: a saturated accent and its readable
/// foreground.
class ActivityColor {
  const ActivityColor(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

/// Activity category palette (event category accent colors).
///
/// Foregrounds are contrast-checked against their background (>= 4.5:1 for
/// normal text). Dark mode uses lighter tonal variants.
/// Source of truth: `docs/DESIGN_SYSTEM.md`.
abstract final class ActivityColors {
  ActivityColors._();

  static const List<ActivityColor> light = <ActivityColor>[
    ActivityColor(Color(0xFF2E3EC9), Colors.white),
    ActivityColor(Color(0xFF1F6FB2), Colors.white),
    ActivityColor(Color(0xFF0E7C86), Colors.white),
    ActivityColor(Color(0xFF6B4BC4), Colors.white),
    ActivityColor(Color(0xFFB0356E), Colors.white),
    ActivityColor(Color(0xFFBE3A2B), Colors.white),
    ActivityColor(Color(0xFFB05A14), Colors.white),
    ActivityColor(Color(0xFFE3B23C), Colors.black87),
    ActivityColor(Color(0xFF2C7A4B), Colors.white),
    ActivityColor(Color(0xFF146B5E), Colors.white),
    ActivityColor(Color(0xFF495877), Colors.white),
  ];

  static const List<ActivityColor> dark = <ActivityColor>[
    ActivityColor(Color(0xFFAEB8FF), Colors.black87),
    ActivityColor(Color(0xFF7FB8E8), Colors.black87),
    ActivityColor(Color(0xFF64C2C9), Colors.black87),
    ActivityColor(Color(0xFFB69BE8), Colors.black87),
    ActivityColor(Color(0xFFEC8FB4), Colors.black87),
    ActivityColor(Color(0xFFF08A7A), Colors.black87),
    ActivityColor(Color(0xFFF0A468), Colors.black87),
    ActivityColor(Color(0xFFEFC85F), Colors.black87),
    ActivityColor(Color(0xFF86CC9B), Colors.black87),
    ActivityColor(Color(0xFF6FC9B8), Colors.black87),
    ActivityColor(Color(0xFFA8B4CC), Colors.black87),
  ];

  static int get length => light.length;

  static ActivityColor of(int index, Brightness brightness) {
    final palette = brightness == Brightness.dark ? dark : light;
    return palette[index % palette.length];
  }
}
