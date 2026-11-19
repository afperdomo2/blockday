import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

/// Card with soft layered depth and a gentle pressed response.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md`.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.color,
    this.radius,
    this.enableShadow = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final BorderRadius? radius;
  final bool enableShadow;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = widget.radius ?? AppRadius.lgAll;
    final interactive = widget.onTap != null;
    final reduced = AppMotion.reduceMotion(context);

    final decoration = BoxDecoration(
      color: widget.color ?? cs.surfaceContainerLow,
      borderRadius: radius,
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      boxShadow: widget.enableShadow
          ? (_pressed
                ? AppShadows.pressed(theme.brightness)
                : AppShadows.card(theme.brightness))
          : const <BoxShadow>[],
    );

    final content = Container(
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: interactive
              ? (value) => setState(() => _pressed = value)
              : null,
          borderRadius: radius,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    return Padding(
      padding: widget.margin,
      child: !interactive || reduced
          ? content
          : AnimatedScale(
              scale: _pressed ? AppMotion.pressScale : 1,
              duration: AppMotion.fast,
              curve: AppMotion.enter,
              child: content,
            ),
    );
  }
}
