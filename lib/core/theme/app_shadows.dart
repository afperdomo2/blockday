import 'package:flutter/material.dart';

/// Soft layered shadow tokens.
///
/// Each level stacks a tight contact shadow over a diffuse ambient one so
/// surfaces gain depth without looking heavy. Dark mode widens the blur and
/// keeps the shadows near-black.
/// Source of truth: `docs/DESIGN_SYSTEM.md`.
abstract final class AppShadows {
  AppShadows._();

  static Color _ink(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF000000)
      : const Color(0xFF1B2350);

  static List<BoxShadow> _layered(
    Brightness brightness, {
    required double tightAlpha,
    required double tightBlur,
    required double tightY,
    required double ambientAlpha,
    required double ambientBlur,
    required double ambientY,
  }) {
    final ink = _ink(brightness);
    final boost = brightness == Brightness.dark ? 1.6 : 1.0;
    return [
      BoxShadow(
        color: ink.withValues(alpha: tightAlpha),
        blurRadius: tightBlur,
        offset: Offset(0, tightY),
      ),
      BoxShadow(
        color: ink.withValues(alpha: ambientAlpha * boost),
        blurRadius: ambientBlur,
        offset: Offset(0, ambientY),
      ),
    ];
  }

  /// Cards at rest: barely there, just enough to lift from the background.
  static List<BoxShadow> card(Brightness brightness) => _layered(
    brightness,
    tightAlpha: 0.04,
    tightBlur: 2,
    tightY: 1,
    ambientAlpha: 0.05,
    ambientBlur: 10,
    ambientY: 4,
  );

  /// Pressed cards and raised controls: tighter, deeper contact shadow.
  static List<BoxShadow> pressed(Brightness brightness) => _layered(
    brightness,
    tightAlpha: 0.05,
    tightBlur: 1,
    tightY: 1,
    ambientAlpha: 0.04,
    ambientBlur: 4,
    ambientY: 1,
  );

  /// Floating surfaces: menus, FABs, bottom bars.
  static List<BoxShadow> floating(Brightness brightness) => _layered(
    brightness,
    tightAlpha: 0.06,
    tightBlur: 6,
    tightY: 3,
    ambientAlpha: 0.1,
    ambientBlur: 22,
    ambientY: 12,
  );

  /// Brand-tinted glow for primary CTAs.
  static List<BoxShadow> brand(Color color, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return _layered(
        brightness,
        tightAlpha: 0.08,
        tightBlur: 4,
        tightY: 2,
        ambientAlpha: 0.2,
        ambientBlur: 16,
        ambientY: 8,
      );
    }
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.28),
        blurRadius: 14,
        offset: const Offset(0, 5),
      ),
    ];
  }
}
