import 'package:flutter/material.dart';

/// An activity category color pair: a background and its readable foreground.
class ActivityColor {
  const ActivityColor(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

/// Activity category palette (event category accent colors).
///
/// Foregrounds are contrast-checked against their background (>= 4.5:1 for
/// normal text). Dark mode uses desaturated/lighter tonal variants.
/// Source of truth: `docs/DESIGN_SYSTEM.md`.
abstract final class ActivityColors {
  ActivityColors._();

  static const List<ActivityColor> light = <ActivityColor>[
    ActivityColor(Color(0xFF1565C0), Colors.white),
    ActivityColor(Color(0xFF0277BD), Colors.white),
    ActivityColor(Color(0xFF3949AB), Colors.white),
    ActivityColor(Color(0xFF6A1B9A), Colors.white),
    ActivityColor(Color(0xFFAD1457), Colors.white),
    ActivityColor(Color(0xFFC62828), Colors.white),
    ActivityColor(Color(0xFFE65100), Colors.white),
    ActivityColor(Color(0xFFF9A825), Colors.black87),
    ActivityColor(Color(0xFF2E7D32), Colors.white),
    ActivityColor(Color(0xFF00695C), Colors.white),
    ActivityColor(Color(0xFF455A64), Colors.white),
  ];

  static const List<ActivityColor> dark = <ActivityColor>[
    ActivityColor(Color(0xFF64B5F6), Colors.black87),
    ActivityColor(Color(0xFF4FC3F7), Colors.black87),
    ActivityColor(Color(0xFF7986CB), Colors.black87),
    ActivityColor(Color(0xFFBA68C8), Colors.black87),
    ActivityColor(Color(0xFFF06292), Colors.black87),
    ActivityColor(Color(0xFFE57373), Colors.black87),
    ActivityColor(Color(0xFFFF8A65), Colors.black87),
    ActivityColor(Color(0xFFFFD54F), Colors.black87),
    ActivityColor(Color(0xFF81C784), Colors.black87),
    ActivityColor(Color(0xFF4DB6AC), Colors.black87),
    ActivityColor(Color(0xFF90A4AE), Colors.black87),
  ];

  static int get length => light.length;

  static ActivityColor of(int index, Brightness brightness) {
    final palette = brightness == Brightness.dark ? dark : light;
    return palette[index % palette.length];
  }
}
