import 'package:blockday/core/theme/app_colors.dart';
import 'package:blockday/core/theme/app_theme.dart';
import 'package:blockday/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light theme uses the brand palette', () {
    final theme = AppTheme.light;
    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.colorScheme.tertiary, AppColors.accent);
    expect(theme.colorScheme.surface, AppColors.backgroundLight);
    expect(theme.colorScheme.error, AppColors.destructive);
    expect(theme.textTheme.bodyMedium?.fontFamily, AppTypography.fontFamily);
  });

  test('dark theme uses the dark palette', () {
    final theme = AppTheme.dark;
    expect(theme.colorScheme.primary, AppColors.primaryDark);
    expect(theme.colorScheme.surface, AppColors.backgroundDark);
    expect(theme.brightness, Brightness.dark);
  });

  test('headings use the brand ink color in light mode', () {
    final theme = AppTheme.light;
    expect(theme.textTheme.titleLarge?.color, AppColors.heading);
  });

  test('interactive surfaces respect touch targets', () {
    final theme = AppTheme.light;
    final filled = theme.filledButtonTheme.style;
    expect(filled?.minimumSize?.resolve(const {}), const Size(48, 48));
  });
}
