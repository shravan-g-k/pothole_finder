import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Maneuver encoding values
enum ManeuverType {
  left(0),
  right(1),
  sharpLeft(2),
  sharpRight(3),
  slightLeft(4),
  slightRight(5),
  straight(6),
  enterRoundabout(7),
  exitRoundabout(8),
  uTurn(9),
  goal(10),
  depart(11),
  keepLeft(12),
  keepRight(13);

  final int value;
  const ManeuverType(this.value);

  static ManeuverType fromValue(int value) {
    return ManeuverType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ManeuverType.straight,
    );
  }
}

/// A single entry point for all navigation maneuver icons.
class NavigationIcon extends StatelessWidget {
  final ManeuverType type;
  final double size;
  final Color color;
  final Color backgroundColor;

  const NavigationIcon._({
    required this.type,
    this.size = 48,
    this.color = Colors.white,
    this.backgroundColor = const Color(0xFF1976D2),
  });

  factory NavigationIcon.of(
    ManeuverType type, {
    double size = 48,
    Color color = Colors.white,
    Color backgroundColor = const Color(0xFF1976D2),
  }) => NavigationIcon._(
    type: type,
    size: size,
    color: color,
    backgroundColor: backgroundColor,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ManeuverPainter(type: type, color: color, iconSize: size),
        size: Size(size, size),
      ),
    );
  }
}

// ── Master Painter ─────────────────────────────────────────────────────────

class _ManeuverPainter extends CustomPainter {
  final ManeuverType type;
  final Color color;
  final double iconSize;

  _ManeuverPainter({
    required this.type,
    required this.color,
    required this.iconSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pad = iconSize * 0.15;
    canvas.save();
    canvas.translate(pad, pad);
    final drawSize = Size(size.width - pad * 2, size.height - pad * 2);

    switch (type) {
      case ManeuverType.left:
        _paintTurn(canvas, drawSize, isRight: false);
      case ManeuverType.right:
        _paintTurn(canvas, drawSize, isRight: true);
      case ManeuverType.sharpLeft:
        _paintSharpTurn(canvas, drawSize, isRight: false);
      case ManeuverType.sharpRight:
        _paintSharpTurn(canvas, drawSize, isRight: true);
      case ManeuverType.slightLeft:
        _paintSlightTurn(canvas, drawSize, isRight: false);
      case ManeuverType.slightRight:
        _paintSlightTurn(canvas, drawSize, isRight: true);
      case ManeuverType.straight:
        _paintStraight(canvas, drawSize);
      case ManeuverType.enterRoundabout:
        _paintRoundabout(canvas, drawSize, entering: true);
      case ManeuverType.exitRoundabout:
        _paintRoundabout(canvas, drawSize, entering: false);
      case ManeuverType.uTurn:
        _paintUTurn(canvas, drawSize);
      case ManeuverType.goal:
        _paintGoal(canvas, drawSize);
      case ManeuverType.depart:
        _paintDepart(canvas, drawSize);
      case ManeuverType.keepLeft:
        _paintKeep(canvas, drawSize, isRight: false);
      case ManeuverType.keepRight:
        _paintKeep(canvas, drawSize, isRight: true);
    }

    canvas.restore();
  }

  // ── Styling & Core Engines ────────────────────────────────────────────────

  double get _sw => math.max(3.0, iconSize * 0.085);
  double get _headLen => math.max(10.0, iconSize * 0.32);

  Paint get _stroke =>
      Paint()
        ..color = color
        ..strokeWidth = _sw
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

  Paint get _fill =>
      Paint()
        ..color = color
        ..style = PaintingStyle.fill;

  /// The engine that magically aligns arrows to ANY path flawlessly.
  void _drawManeuverPath(Canvas canvas, Path path) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final length = metric.length;

    // Retract the stroke slightly so the rounded cap doesn't poke out of the arrow's notch
    final drawLength = math.max(0.0, length - (_headLen * 0.4));
    canvas.drawPath(metric.extractPath(0, drawLength), _stroke);

    // Get exact tangent at the tip of the path for absolute perfect arrow rotation
    final tangent = metric.getTangentForOffset(length);
    if (tangent != null) {
      final tip = tangent.position;
      final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);

      final double len = _headLen;
      final double width = len * 0.85; // Arrow width ratio
      final double notch = len * 0.25; // Base indentation

      canvas.save();
      canvas.translate(tip.dx, tip.dy);
      canvas.rotate(angle);

      // Clean, geometric polygonal arrow
      final arrowPath =
          Path()
            ..moveTo(0, 0)
            ..lineTo(-len, -width / 2)
            ..lineTo(-len + notch, 0)
            ..lineTo(-len, width / 2)
            ..close();

      canvas.drawPath(arrowPath, _fill);
      canvas.restore();
    }
  }

  // ── Individual painters ───────────────────────────────────────────────────

  void _paintStraight(Canvas c, Size s) {
    final path =
        Path()
          ..moveTo(s.width / 2, s.height)
          ..lineTo(s.width / 2, 0);
    _drawManeuverPath(c, path);
  }

  void _paintTurn(Canvas c, Size s, {required bool isRight}) {
    final cx = s.width / 2;
    final arcR = s.width * 0.3;

    final path =
        Path()
          ..moveTo(cx, s.height)
          ..lineTo(cx, s.height * 0.5 + arcR)
          ..arcToPoint(
            Offset(cx + (isRight ? arcR : -arcR), s.height * 0.5),
            radius: Radius.circular(arcR),
            clockwise: isRight,
          )
          ..lineTo(isRight ? s.width : 0, s.height * 0.5);

    _drawManeuverPath(c, path);
  }

  void _paintSharpTurn(Canvas c, Size s, {required bool isRight}) {
    final cx = s.width / 2;
    final h = s.height;
    final w = s.width;
    final dir = isRight ? 1.0 : -1.0;

    final path =
        Path()
          ..moveTo(cx, h)
          ..lineTo(cx, h * 0.6)
          ..quadraticBezierTo(cx, h * 0.1, cx + (w * 0.35 * dir), h * 0.35)
          ..lineTo(cx + (w * 0.45 * dir), h * 0.7); // loops back downward

    _drawManeuverPath(c, path);
  }

  void _paintSlightTurn(Canvas c, Size s, {required bool isRight}) {
    final cx = s.width / 2;
    final h = s.height;
    final w = s.width;
    final dir = isRight ? 1.0 : -1.0;

    final path =
        Path()
          ..moveTo(cx, h)
          ..quadraticBezierTo(cx, h * 0.3, cx + (w * 0.35 * dir), 0);

    _drawManeuverPath(c, path);
  }

  void _paintUTurn(Canvas c, Size s) {
    final h = s.height;
    final w = s.width;
    final gap = w * 0.4; // Road gap width
    final rightX = w / 2 + gap / 2;
    final leftX = w / 2 - gap / 2;
    final arcR = gap / 2;

    final path =
        Path()
          ..moveTo(rightX, h)
          ..lineTo(rightX, h * 0.35)
          ..arcToPoint(
            Offset(leftX, h * 0.35),
            radius: Radius.circular(arcR),
            clockwise: false, // Standard U-turns sweep outward to the left
          )
          ..lineTo(leftX, h * 0.8);

    _drawManeuverPath(c, path);
  }

  void _paintRoundabout(Canvas c, Size s, {required bool entering}) {
    final cx = s.width / 2;
    final cy = s.height * 0.45;
    final islandR = s.width * 0.15;
    final pathR = islandR + _sw * 1.5;

    // Inner island
    c.drawCircle(Offset(cx, cy), islandR, _stroke);

    final path =
        Path()
          ..moveTo(cx, s.height)
          ..lineTo(cx, cy + pathR);

    if (entering) {
      // Sweeps to the left side
      path.arcToPoint(
        Offset(cx - pathR, cy),
        radius: Radius.circular(pathR),
        clockwise: false,
      );
    } else {
      // Sweeps over the top and out the right
      path.arcToPoint(
        Offset(cx - pathR, cy),
        radius: Radius.circular(pathR),
        clockwise: false,
      );
      path.arcToPoint(
        Offset(cx, cy - pathR),
        radius: Radius.circular(pathR),
        clockwise: false,
      );
      path.arcToPoint(
        Offset(cx + pathR, cy),
        radius: Radius.circular(pathR),
        clockwise: false,
      );
      path.lineTo(s.width, cy);
    }

    _drawManeuverPath(c, path);
  }

  void _paintKeep(Canvas c, Size s, {required bool isRight}) {
    final cx = s.width / 2;
    final h = s.height;
    final w = s.width;
    final dir = isRight ? 1.0 : -1.0;

    // The road not taken
    final fadedPath =
        Path()
          ..moveTo(cx, h)
          ..lineTo(cx, h * 0.55)
          ..quadraticBezierTo(cx, h * 0.3, cx - (w * 0.35 * dir), 0);

    final fadedPaint =
        Paint()
          ..color = color.withAlpha(80)
          ..strokeWidth = _sw * 0.6
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    c.drawPath(fadedPath, fadedPaint);

    // The chosen path
    final mainPath =
        Path()
          ..moveTo(cx, h)
          ..lineTo(cx, h * 0.55)
          ..quadraticBezierTo(cx, h * 0.3, cx + (w * 0.35 * dir), 0);

    _drawManeuverPath(c, mainPath);
  }

  void _paintGoal(Canvas c, Size s) {
    final cx = s.width / 2;
    final h = s.height;
    final pinR = s.width * 0.25;

    c.drawCircle(Offset(cx, pinR), pinR, _stroke);
    c.drawCircle(Offset(cx, pinR), pinR * 0.35, _fill);

    final tailPath =
        Path()
          ..moveTo(cx - pinR * 0.6, pinR * 1.7)
          ..lineTo(cx, h * 0.85)
          ..lineTo(cx + pinR * 0.6, pinR * 1.7)
          ..close();
    c.drawPath(tailPath, _fill);
  }

  void _paintDepart(Canvas c, Size s) {
    final cx = s.width / 2;
    final h = s.height;
    final startR = s.width * 0.15;

    c.drawCircle(Offset(cx, h - startR), startR, _stroke);
    c.drawCircle(Offset(cx, h - startR), startR * 0.4, _fill);

    final path =
        Path()
          ..moveTo(cx, h - startR * 2)
          ..lineTo(cx, 0);

    _drawManeuverPath(c, path);
  }

  @override
  bool shouldRepaint(_ManeuverPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.color != color ||
      oldDelegate.iconSize != iconSize;
}
