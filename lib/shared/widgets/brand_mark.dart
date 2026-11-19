import 'package:flutter/material.dart';

import '../../core/theme/app_shadows.dart';

/// Blockday brand glyph: a calendar tile with two rings and three time blocks.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.secondary],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: AppShadows.card(Theme.of(context).brightness),
      ),
      child: CustomPaint(
        painter: _MarkPainter(color: cs.onPrimary, scale: size / 100),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.color, required this.scale});

  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.9);
    canvas.drawCircle(const Offset(36, 16), 6, ring);
    canvas.drawCircle(const Offset(64, 16), 6, ring);

    final bars = <(double, double, double)>[
      (14, 58, 26),
      (42, 46, 38),
      (70, 52, 32),
    ];
    for (final (x, top, height) in bars) {
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, 16, height),
        const Radius.circular(6),
      );
      canvas.drawRRect(
        rrect,
        Paint()..color = color.withValues(alpha: 0.55 + top / 200),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.scale != scale;

  @override
  bool shouldRebuildSemantics(_MarkPainter oldDelegate) => false;
}
