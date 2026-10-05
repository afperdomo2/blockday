import 'package:flutter/material.dart';

/// Semantic color tokens.
///
/// Source of truth: `design-system/blockday/MASTER.md`.
/// Use these instead of raw hex values in widgets.
abstract final class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFF3B82F6);

  /// Event / completed state green.
  static const Color success = Color(0xFF059669);

  static const Color destructive = Color(0xFFDC2626);
  static const Color onDestructive = Color(0xFFFFFFFF);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color foreground = Color(0xFF0F172A);
  static const Color mutedForeground = Color(0xFF475569);
}

/// Builds the app [ColorScheme] from the design tokens.
ColorScheme buildAppColorScheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: brightness,
  ).copyWith(error: AppColors.destructive, onError: AppColors.onDestructive);

  if (brightness == Brightness.light) {
    return scheme.copyWith(surface: AppColors.backgroundLight);
  }
  return scheme;
}
