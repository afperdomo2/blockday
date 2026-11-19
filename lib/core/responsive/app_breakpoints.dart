import 'package:flutter/widgets.dart';

enum WindowSize { compact, medium, expanded }

abstract final class AppBreakpoints {
  AppBreakpoints._();

  static const double medium = 600;
  static const double expanded = 1024;

  static WindowSize of(double width) {
    if (width >= expanded) return WindowSize.expanded;
    if (width >= medium) return WindowSize.medium;
    return WindowSize.compact;
  }
}

extension WindowSizeContext on BuildContext {
  WindowSize get windowSize => AppBreakpoints.of(MediaQuery.sizeOf(this).width);

  bool get isCompact => windowSize == WindowSize.compact;
}
