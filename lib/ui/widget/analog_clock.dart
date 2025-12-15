import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnalogClock extends StatelessWidget {
  final Duration elapsed;

  const AnalogClock({
    super.key,
    required this.elapsed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.w,
      height: 200.w,
      child: CustomPaint(
        painter: _ClockPainter(
          elapsed: elapsed,
          primaryColor: Theme.of(context).colorScheme.primary,
          onSurfaceColor: Theme.of(context).colorScheme.onSurface,
          surfaceColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final Duration elapsed;
  final Color primaryColor;
  final Color onSurfaceColor;
  final Color surfaceColor;

  _ClockPainter({
    required this.elapsed,
    required this.primaryColor,
    required this.onSurfaceColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final backgroundPaint = Paint()
      ..color = surfaceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    final borderPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);

    _drawClockMarkers(canvas, center, radius);

    final totalSeconds = elapsed.inSeconds;
    final seconds = totalSeconds % 60;
    final totalMinutes = elapsed.inMinutes;
    final minutes = totalMinutes % 60;

    _drawHand(
      canvas,
      center,
      radius * 0.7,
      seconds / 60.0,
      primaryColor,
      2,
    );

    _drawHand(
      canvas,
      center,
      radius * 0.55,
      minutes / 60.0,
      primaryColor.withValues(alpha: 0.3),
      3,
    );

    final centerDotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerDotPaint);
  }

  void _drawClockMarkers(Canvas canvas, Offset center, double radius) {
    final markerPaint = Paint()
      ..color = onSurfaceColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final markerRadius = i % 3 == 0 ? 4.0 : 2.0;
      final markerDistance = radius - 15;

      final x = center.dx + markerDistance * cos(angle);
      final y = center.dy + markerDistance * sin(angle);

      canvas.drawCircle(Offset(x, y), markerRadius, markerPaint);
    }
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double length,
    double position,
    Color color,
    double strokeWidth,
  ) {
    final angle = (position * 360 - 90) * pi / 180;
    final handPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final handEnd = Offset(
      center.dx + length * cos(angle),
      center.dy + length * sin(angle),
    );

    canvas.drawLine(center, handEnd, handPaint);
  }

  @override
  bool shouldRepaint(_ClockPainter oldDelegate) {
    return oldDelegate.elapsed != elapsed;
  }
}
