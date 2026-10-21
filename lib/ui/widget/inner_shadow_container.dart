import 'package:flutter/material.dart';

class InnerShadowContainer extends StatelessWidget {
  final List<BoxShadow> shadows;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Widget? child;

  const InnerShadowContainer({super.key, required this.shadows, this.borderRadius = BorderRadius.zero, this.backgroundColor, this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: backgroundColor != null ? _BackgroundPainter(color: backgroundColor!, borderRadius: borderRadius) : null,

      foregroundPainter: _InnerShadowPainter(shadows: shadows, borderRadius: borderRadius),
      child: child,
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final Color color;
  final BorderRadius borderRadius;

  _BackgroundPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final paint = Paint()..color = color;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
  }
}

class _InnerShadowPainter extends CustomPainter {
  final List<BoxShadow> shadows;
  final BorderRadius borderRadius;

  _InnerShadowPainter({required this.shadows, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    if (shadows.isEmpty) return;

    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    canvas.save();
    canvas.clipRRect(rrect);

    for (final shadow in shadows) {
      final shadowBounds = rect.inflate(shadow.blurRadius * 2 + shadow.spreadRadius.abs());

      final path = Path()
        ..addRect(shadowBounds)
        ..addRRect(rrect.deflate(shadow.spreadRadius))
        ..fillType = PathFillType.evenOdd;

      final paint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius / 2);

      canvas.save();
      canvas.translate(shadow.offset.dx, shadow.offset.dy);
      canvas.drawPath(path, paint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InnerShadowPainter oldDelegate) {
    return oldDelegate.shadows != shadows || oldDelegate.borderRadius != borderRadius;
  }
}
