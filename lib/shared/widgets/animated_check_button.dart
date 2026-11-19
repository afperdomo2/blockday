import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

/// Circular toggle with an animated check, used to complete sessions/tasks.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md`.
class AnimatedCheckButton extends StatefulWidget {
  const AnimatedCheckButton({
    super.key,
    required this.checked,
    required this.onChanged,
    this.size = 30,
    this.checkedColor = AppColors.success,
    this.tooltip,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final double size;
  final Color checkedColor;
  final String? tooltip;

  @override
  State<AnimatedCheckButton> createState() => _AnimatedCheckButtonState();
}

class _AnimatedCheckButtonState extends State<AnimatedCheckButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );

  @override
  void didUpdateWidget(AnimatedCheckButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checked != widget.checked) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!AppMotion.reduceMotion(context)) {
      HapticFeedback.selectionClick();
    }
    widget.onChanged(!widget.checked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reduced = AppMotion.reduceMotion(context);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.spring,
    );

    final button = Semantics(
      button: true,
      checked: widget.checked,
      label: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: AnimatedContainer(
          duration: reduced ? Duration.zero : AppMotion.fast,
          curve: AppMotion.enter,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.checked ? widget.checkedColor : Colors.transparent,
            border: Border.all(
              color: widget.checked
                  ? widget.checkedColor
                  : cs.outline.withValues(alpha: 0.5),
              width: 1.6,
            ),
          ),
          child: widget.checked
              ? ScaleTransition(
                  scale: Tween<double>(begin: 0.6, end: 1).animate(animation),
                  child: Icon(
                    Icons.check_rounded,
                    size: widget.size * 0.62,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ),
    );

    if (widget.tooltip == null) return button;
    return Tooltip(message: widget.tooltip!, child: button);
  }
}
