import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color seedColor = Color(0xFF3F51B5);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface.withValues(alpha: 0.85),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: _textTheme(scheme, brightness),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface.withValues(alpha: 0.9),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(visualDensity: VisualDensity.compact),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme, Brightness brightness) {
    final base = brightness == Brightness.light
        ? Typography.blackMountainView
        : Typography.whiteMountainView;
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        letterSpacing: -0.02 * 57,
        height: 1.05,
      ),
      titleLarge: base.titleLarge?.copyWith(
        letterSpacing: -0.01 * 22,
        height: 1.1,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01 * 16,
      ),
      labelSmall: base.labelSmall?.copyWith(
        letterSpacing: 0.05 * 11,
        height: 1.4,
      ),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.5),
    );
  }
}
