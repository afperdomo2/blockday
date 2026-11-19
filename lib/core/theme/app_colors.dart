import 'package:flutter/material.dart';

/// Semantic color tokens.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md`.
/// Use these instead of raw hex values in widgets.
abstract final class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2E3EC9);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE3E6FB);
  static const Color onPrimaryContainer = Color(0xFF1B2560);

  static const Color secondary = Color(0xFF5B64B8);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE7E8FA);
  static const Color onSecondaryContainer = Color(0xFF272C66);

  static const Color accent = Color(0xFF0E9C6E);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color accentContainer = Color(0xFFD4F0E3);
  static const Color onAccentContainer = Color(0xFF0B5B41);

  static const Color success = accent;

  static const Color destructive = Color(0xFFC4402E);
  static const Color onDestructive = Color(0xFFFFFFFF);
  static const Color destructiveContainer = Color(0xFFFBE4DE);
  static const Color onDestructiveContainer = Color(0xFF7A261A);

  static const Color backgroundLight = Color(0xFFF7F6F2);
  static const Color foreground = Color(0xFF23263B);
  static const Color mutedForeground = Color(0xFF5C6072);
  static const Color heading = Color(0xFF1B2560);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color mutedLight = Color(0xFFEDEBE6);
  static const Color borderLight = Color(0xFFE2DFD7);

  static const Color primaryDark = Color(0xFFAEB8FF);
  static const Color onPrimaryDark = Color(0xFF161F55);
  static const Color primaryContainerDark = Color(0xFF2D3891);
  static const Color onPrimaryContainerDark = Color(0xFFE3E6FB);

  static const Color secondaryDark = Color(0xFFB9BEE8);
  static const Color onSecondaryDark = Color(0xFF272C66);
  static const Color secondaryContainerDark = Color(0xFF3B4079);
  static const Color onSecondaryContainerDark = Color(0xFFE7E8FA);

  static const Color accentDark = Color(0xFF4BD3A2);
  static const Color onAccentDark = Color(0xFF06382A);
  static const Color accentContainerDark = Color(0xFF0E5C43);
  static const Color onAccentContainerDark = Color(0xFFBCEEDA);

  static const Color destructiveDark = Color(0xFFF1917F);
  static const Color onErrorDark = Color(0xFF4C1108);
  static const Color destructiveContainerDark = Color(0xFF7A261A);
  static const Color onErrorContainerDark = Color(0xFFFBE4DE);

  static const Color backgroundDark = Color(0xFF12141F);
  static const Color foregroundDark = Color(0xFFE7E8F2);
  static const Color mutedForegroundDark = Color(0xFFA4A8BE);
  static const Color cardDark = Color(0xFF181B28);
  static const Color mutedDark = Color(0xFF2F3346);
  static const Color borderDark = Color(0xFF343850);
}

/// Builds the app [ColorScheme] from the design tokens.
ColorScheme buildAppColorScheme(Brightness brightness) {
  if (brightness == Brightness.dark) {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onSecondaryDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.onSecondaryContainerDark,
      tertiary: AppColors.accentDark,
      onTertiary: AppColors.onAccentDark,
      tertiaryContainer: AppColors.accentContainerDark,
      onTertiaryContainer: AppColors.onAccentContainerDark,
      error: AppColors.destructiveDark,
      onError: AppColors.onErrorDark,
      errorContainer: AppColors.destructiveContainerDark,
      onErrorContainer: AppColors.onErrorContainerDark,
      surface: AppColors.backgroundDark,
      onSurface: AppColors.foregroundDark,
      onSurfaceVariant: AppColors.mutedForegroundDark,
      outline: Color(0xFF8B90A8),
      outlineVariant: AppColors.borderDark,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: AppColors.foregroundDark,
      onInverseSurface: AppColors.backgroundDark,
      inversePrimary: AppColors.primary,
      surfaceTint: AppColors.primaryDark,
      surfaceContainerLowest: Color(0xFF0D0F18),
      surfaceContainerLow: AppColors.cardDark,
      surfaceContainer: Color(0xFF1F2231),
      surfaceContainerHigh: Color(0xFF262A3B),
      surfaceContainerHighest: AppColors.mutedDark,
    );
  }
  return const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.accent,
    onTertiary: AppColors.onAccent,
    tertiaryContainer: AppColors.accentContainer,
    onTertiaryContainer: AppColors.onAccentContainer,
    error: AppColors.destructive,
    onError: AppColors.onDestructive,
    errorContainer: AppColors.destructiveContainer,
    onErrorContainer: AppColors.onDestructiveContainer,
    surface: AppColors.backgroundLight,
    onSurface: AppColors.foreground,
    onSurfaceVariant: AppColors.mutedForeground,
    outline: Color(0xFF76798C),
    outlineVariant: AppColors.borderLight,
    shadow: Color(0xFF1B2350),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2A2D40),
    onInverseSurface: AppColors.backgroundLight,
    inversePrimary: AppColors.primaryDark,
    surfaceTint: AppColors.primary,
    surfaceContainerLowest: AppColors.cardLight,
    surfaceContainerLow: AppColors.cardLight,
    surfaceContainer: Color(0xFFF1EFE9),
    surfaceContainerHigh: Color(0xFFEAE8E1),
    surfaceContainerHighest: AppColors.mutedLight,
  );
}
