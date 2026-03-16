import 'package:flutter/material.dart';

class RouteIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = Colors.black54;
    final linePaint =
        Paint()
          ..color = Colors.black26
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    const r = 4.0;
    final cx = size.width / 2;

    // Origin circle (hollow)
    canvas.drawCircle(
      Offset(cx, r),
      r,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, r),
      r,
      dotPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Dashed line between the two dots
    final dashHeight = 4.0;
    final gap = 3.0;
    double y = r * 2 + 4;
    final endY = size.height - r * 2 - 4;
    while (y < endY) {
      canvas.drawLine(
        Offset(cx, y),
        Offset(cx, (y + dashHeight).clamp(0, endY)),
        linePaint,
      );
      y += dashHeight + gap;
    }

    // Destination pin (filled)
    final pinPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(Offset(cx, size.height - r), r, pinPaint);
  }

  @override
  bool shouldRepaint(RouteIndicatorPainter oldDelegate) => false;
}