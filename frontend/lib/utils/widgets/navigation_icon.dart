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
///
/// Usage:
///   NavigationIcon.fromValue(0)          // by encoding int
///   NavigationIcon.of(ManeuverType.left) // by enum
///   NavigationIcon.left()                // named constructors
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

  // ── Factory constructors ──────────────────────────────────────────────────

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
    // Apply padding so strokes don't clip at edges
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Stroke width: 7% of icon size, minimum 2.5
  double get _sw => math.max(2.5, iconSize * 0.07);

  /// Arrowhead length: 20% of icon size, minimum 7
  double get _headLen => math.max(7.0, iconSize * 0.30);

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

  /// Draws a sleek notched-chevron arrowhead at [tip] pointing in [angle].
  void _arrow(Canvas c, Offset tip, double angle) {
    final len = _headLen;
    const spread = 0.5; // half-angle – narrower for a sharper look
    const notch = 1; // how far the base notch cuts back toward the tip

    // Two outer barb points
    final p1 =
        tip +
        Offset(
          math.cos(angle + math.pi - spread) * len,
          math.sin(angle + math.pi - spread) * len,
        );
    final p2 =
        tip +
        Offset(
          math.cos(angle + math.pi + spread) * len,
          math.sin(angle + math.pi + spread) * len,
        );

    // Notch point (indented base – gives a "chevron" shape)
    final mid =
        tip +
        Offset(
          math.cos(angle + math.pi) * len * notch,
          math.sin(angle + math.pi) * len * notch,
        );

    c.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(mid.dx, mid.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close(),
      _fill,
    );
  }

  // ── Individual painters ───────────────────────────────────────────────────

  /// Straight arrow pointing up
  void _paintStraight(Canvas c, Size s) {
    final cx = s.width / 2;
    final bot = Offset(cx, s.height);
    final top = Offset(cx, 0);
    c.drawLine(bot, top, _stroke);
    _arrow(c, top, -math.pi / 2);
  }

  /// 90° turn: vertical stem from bottom, 90° arc, horizontal arm with arrow.
  void _paintTurn(Canvas c, Size s, {required bool isRight}) {
    final cx = s.width / 2;
    final w = s.width;
    final h = s.height;
    final r = w * 0.25; // arc radius

    // Vertical stem bottom to turn point
    final stemBot = Offset(cx, h);
    final stemTop = Offset(cx, h * 0.45);
    c.drawLine(stemBot, stemTop, _stroke);

    // 90° arc
    if (isRight) {
      final arcCenter = Offset(cx + r, stemTop.dy);
      final arcRect = Rect.fromCircle(center: arcCenter, radius: r);
      // Arc from 180° (left) sweeping -90° (upward to right)
      c.drawArc(arcRect, math.pi, math.pi / 2, false, _stroke);
      // Horizontal arm from arc top to arrow tip
      final armStart = Offset(cx + r, stemTop.dy - r);
      final tip = Offset(w, stemTop.dy - r);
      c.drawLine(armStart, tip, _stroke);
      _arrow(c, tip + Offset(5, 0), 0); // pointing right
    } else {
      final arcCenter = Offset(cx - r, stemTop.dy);
      final arcRect = Rect.fromCircle(center: arcCenter, radius: r);
      // Arc from 0° (right) sweeping +90° (upward to left)
      c.drawArc(arcRect, 0, math.pi / 2, false, _stroke);
      final armStart = Offset(cx - r, stemTop.dy - r);
      final tip = Offset(0, stemTop.dy - r);
      c.drawLine(armStart, tip, _stroke);
      _arrow(c, tip, math.pi); // pointing left
    }
  }

  /// Sharp turn (~135°): stem up, then sharply back down‐left or down‐right
  void _paintSharpTurn(Canvas c, Size s, {required bool isRight}) {
    final cx = s.width / 2;
    final h = s.height;
    final w = s.width;
    final p = _stroke;

    // Stem from bottom to upper area
    final stemBot = Offset(cx, h);
    final elbow = Offset(cx, h * 0.25);
    c.drawLine(stemBot, elbow, p);

    // Diagonal line going back down
    final tipX = isRight ? w * 0.85 : w * 0.15;
    final tip = Offset(tipX, h * 0.70);
    c.drawLine(elbow, tip, p);

    _arrow(c, tip, math.atan2(tip.dy - elbow.dy, tip.dx - elbow.dx));
  }

  /// Slight turn (~30°): gentle curve veering left or right
  void _paintSlightTurn(Canvas c, Size s, {required bool isRight}) {
    final cx = s.width / 2;
    final h = s.height;
    final w = s.width;
    final p = _stroke;

    final bot = Offset(cx, h);
    final ctrl = Offset(cx, h * 0.45);
    final offsetX = isRight ? w * 0.28 : -w * 0.28;
    final tip = Offset(cx + offsetX, 0);

    final path =
        Path()
          ..moveTo(bot.dx, bot.dy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy);
    c.drawPath(path, p);

    // Tangent at endpoint of quadratic bezier = direction from control to end
    final dx = tip.dx - ctrl.dx;
    final dy = tip.dy - ctrl.dy;
    _arrow(c, tip, math.atan2(dy, dx));
  }

  /// U-turn: right stem up, semicircle over top, left stem down with arrow
  void _paintUTurn(Canvas c, Size s) {
    final w = s.width;
    final h = s.height;
    final p = _stroke;

    final rightX = w * 0.65;
    final leftX = w * 0.35;
    final r = (rightX - leftX) / 2;
    final arcCenterX = (leftX + rightX) / 2;
    final arcTopY = h * 0.20;

    // Right stem going up
    c.drawLine(Offset(rightX, h * 0.75), Offset(rightX, arcTopY + r), p);

    // Semicircle from right to left (going over the top)
    final arcRect = Rect.fromCircle(
      center: Offset(arcCenterX, arcTopY + r),
      radius: r,
    );
    c.drawArc(arcRect, 0, -math.pi, false, p);

    // Left stem going down
    final downTip = Offset(leftX, h * 0.75);
    c.drawLine(Offset(leftX, arcTopY + r), downTip, p);

    _arrow(c, downTip, math.pi / 2); // pointing down
  }

  /// Roundabout: circle with entry stem and directional arrow
  void _paintRoundabout(Canvas c, Size s, {required bool entering}) {
    final cx = s.width / 2;
    final cy = s.height * 0.40;
    final r = s.width * 0.22;
    final p = _stroke;

    // Draw the roundabout circle
    c.drawCircle(Offset(cx, cy), r, p);

    if (entering) {
      // Stem from bottom-center into the circle
      final stemBot = Offset(cx, s.height);
      final stemTop = Offset(cx, cy + r);
      c.drawLine(stemBot, stemTop, p);

      // Arrow indicator on the left side of circle (counter-clockwise flow)
      final arrowPt = Offset(cx - r, cy);
      _arrow(c, arrowPt, math.pi / 2); // pointing down (ccw direction)
    } else {
      // Stem from bottom-center into the circle
      final stemBot = Offset(cx, s.height);
      final stemTop = Offset(cx, cy + r);
      c.drawLine(stemBot, stemTop, p);

      // Exit line going up-right from circle
      final exitStart = Offset(
        cx + r * math.cos(-math.pi / 4),
        cy + r * math.sin(-math.pi / 4),
      );
      final exitTip = Offset(s.width * 0.90, s.height * 0.05);
      c.drawLine(exitStart, exitTip, p);
      _arrow(
        c,
        exitTip,
        math.atan2(exitTip.dy - exitStart.dy, exitTip.dx - exitStart.dx),
      );
    }
  }

  /// Goal / destination: map pin icon
  void _paintGoal(Canvas c, Size s) {
    final cx = s.width / 2;
    final h = s.height;
    final pinR = s.width * 0.28;
    final pinCy = pinR;

    // Outer circle
    c.drawCircle(Offset(cx, pinCy), pinR, _stroke);

    // Inner filled dot
    c.drawCircle(Offset(cx, pinCy), pinR * 0.35, _fill);

    // Pin tail triangle
    final tailPath =
        Path()
          ..moveTo(cx - pinR * 0.50, pinCy + pinR * 0.75)
          ..lineTo(cx, h)
          ..lineTo(cx + pinR * 0.50, pinCy + pinR * 0.75)
          ..close();
    c.drawPath(tailPath, _fill);
  }

  /// Depart / start: circle with arrow shooting out
  void _paintDepart(Canvas c, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final r = s.width * 0.25;

    // Outer circle
    c.drawCircle(Offset(cx, cy), r, _stroke);

    // Inner filled dot
    c.drawCircle(Offset(cx, cy), r * 0.35, _fill);

    // Arrow shooting upward from circle
    final arrowStart = Offset(cx, cy - r);
    final arrowTip = Offset(cx, 0);
    c.drawLine(arrowStart, arrowTip, _stroke);
    _arrow(c, arrowTip, -math.pi / 2); // pointing up
  }

  /// Keep left / right: fork where one branch has the arrow
  void _paintKeep(Canvas c, Size s, {required bool isRight}) {
    final cx = s.width / 2;
    final h = s.height;
    final w = s.width;
    final p = _stroke;

    // Shared stem from bottom
    final stemBot = Offset(cx, h);
    final fork = Offset(cx, h * 0.55);
    c.drawLine(stemBot, fork, p);

    // Straight arm (the road not taken) — thinner, faded
    final fadedPaint =
        Paint()
          ..color = color.withAlpha(80)
          ..strokeWidth = _sw * 0.6
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
    c.drawLine(fork, Offset(cx, 0), fadedPaint);

    // Leaning arm (the chosen direction) with arrowhead
    final tipX = isRight ? w * 0.85 : w * 0.15;
    final tip = Offset(tipX, h * 0.10);
    c.drawLine(fork, tip, p);
    _arrow(c, tip, math.atan2(tip.dy - fork.dy, tip.dx - fork.dx));
  }

  @override
  bool shouldRepaint(_ManeuverPainter oldDelegate) =>
      oldDelegate.type != type ||
      oldDelegate.color != color ||
      oldDelegate.iconSize != iconSize;
}
