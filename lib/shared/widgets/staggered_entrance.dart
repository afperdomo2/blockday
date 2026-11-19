import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';

class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.child,
    this.maxSteps = 24,
    this.duration = const Duration(milliseconds: 900),
  });

  final Widget child;
  final int maxSteps;
  final Duration duration;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return _StaggerScope(
      animation: _controller,
      maxSteps: widget.maxSteps,
      child: widget.child,
    );
  }
}

class _StaggerScope extends InheritedWidget {
  const _StaggerScope({
    required this.animation,
    required this.maxSteps,
    required super.child,
  });

  final Animation<double> animation;
  final int maxSteps;

  @override
  bool updateShouldNotify(_StaggerScope oldWidget) =>
      animation != oldWidget.animation || maxSteps != oldWidget.maxSteps;
}

class StaggeredItem extends StatelessWidget {
  const StaggeredItem({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  static const double _stepFraction = 0.045;
  static const double _itemFraction = 0.3;

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_StaggerScope>();
    if (scope == null) return child;

    final start = (index * _stepFraction).clamp(0.0, 1.0 - _itemFraction);
    final animation = CurvedAnimation(
      parent: scope.animation,
      curve: Interval(start, start + _itemFraction, curve: AppMotion.enter),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
