import 'package:flutter/material.dart';

/// Typography tokens.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md`.
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
        fontSize: 56,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        height: 1,
      ),
      displaySmall: themed.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
        height: 1.05,
      ),
      headlineMedium: themed.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineSmall: themed.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleLarge: themed.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.15,
      ),
      titleMedium: themed.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      titleSmall: themed.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      bodyMedium: themed.bodyMedium?.copyWith(height: 1.5),
      bodySmall: themed.bodySmall?.copyWith(height: 1.4),
      labelLarge: themed.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: themed.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }

  static const TextStyle weekBlock = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle weekBlockCompact = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}
