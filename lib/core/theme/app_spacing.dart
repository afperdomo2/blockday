/// Spacing scale (4/8dp rhythm).
///
/// Source of truth: `design-system/blockday/MASTER.md`.
/// Prefer these tokens over ad-hoc `SizedBox`/`EdgeInsets` values.
abstract final class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double jumbo = 48;
}
