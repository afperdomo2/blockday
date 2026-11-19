import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';

/// Shared linear progress indicator with an animated brand-gradient fill.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({super.key, required this.value, this.minHeight = 6});

  final double value;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reduced = AppMotion.reduceMotion(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: reduced ? Duration.zero : AppMotion.slow * 2,
      curve: AppMotion.enter,
      builder: (context, animated, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: SizedBox(
            height: minHeight,
            child: CustomPaint(
              painter: _GradientTrackPainter(
                value: animated,
                trackColor: cs.surfaceContainerHighest,
                colors: [cs.primary, cs.tertiary],
              ),
              size: Size(double.infinity, minHeight),
            ),
          ),
        );
      },
    );
  }
}

class _GradientTrackPainter extends CustomPainter {
  const _GradientTrackPainter({
    required this.value,
    required this.trackColor,
    required this.colors,
  });

  final double value;
  final Color trackColor;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = trackColor,
    );
    if (value <= 0) return;
    final width = size.width * value;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & Size(width, size.height), radius),
      Paint()
        ..shader = LinearGradient(colors: colors)
            .createShader(Offset.zero & Size(size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(_GradientTrackPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.colors != colors;
}
