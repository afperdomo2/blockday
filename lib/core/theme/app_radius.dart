import 'package:flutter/material.dart';

/// Corner radius tokens.
///
/// Source of truth: `design-system/blockday/MASTER.md`.
abstract final class AppRadius {
  AppRadius._();

  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double pill = 999;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
}
