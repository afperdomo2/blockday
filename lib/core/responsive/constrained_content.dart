import 'package:flutter/widgets.dart';

abstract final class AppContentWidth {
  AppContentWidth._();

  static const double form = 560;
  static const double list = 720;
  static const double day = 560;
  static const double threeDay = 760;
  static const double calendar = 1100;
}

class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({
    super.key,
    required this.child,
    required this.maxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
