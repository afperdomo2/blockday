import 'package:flutter/material.dart';

/// Typography tokens.
///
/// Source of truth: `design-system/blockday/MASTER.md`.
/// Font: Plus Jakarta Sans (bundled as assets, offline-safe).
abstract final class AppTypography {
  AppTypography._();

  static const String fontFamily = 'PlusJakartaSans';

  static TextTheme build(Brightness brightness) {
    final base = brightness == Brightness.light
        ? Typography.blackMountainView
        : Typography.whiteMountainView;

    final themed = base.apply(fontFamily: fontFamily);

    return themed.copyWith(
      displayLarge: themed.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.05,
      ),
      headlineMedium: themed.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: themed.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.1,
      ),
      titleMedium: themed.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      titleSmall: themed.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      bodyMedium: themed.bodyMedium?.copyWith(height: 1.5),
      bodySmall: themed.bodySmall?.copyWith(height: 1.4),
      labelSmall: themed.labelSmall?.copyWith(letterSpacing: 0.3),
    );
  }
}
