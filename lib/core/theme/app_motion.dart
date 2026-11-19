import 'package:flutter/material.dart';

/// Shared motion tokens.
///
/// Enter decelerates, exit accelerates (exit ~60-70% of enter duration).
/// Source of truth: `docs/DESIGN_SYSTEM.md` + `ui-ux-pro-max` §7.
abstract final class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  /// Whether the user prefers reduced motion; gate non-essential animations.
  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
