import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'hexagon_color_manager.dart';
import 'hexagon_icon_painter.dart';
import 'hexagon_step_input.dart';

class StepTypeHexagonPainter extends CustomPainter {
  static const int SIDES_OF_HEXAGON = 6;
  final Offset center;
  final double radius;
  final bool clicked;
  final Color hexagonColor;
  final StepInfo? stepInfo;
  final bool showSearchIcon;

  StepTypeHexagonPainter({
    required this.center,
    required this.radius,
    required this.clicked,
    required this.hexagonColor,
    this.stepInfo,
    this.showSearchIcon = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = createHexagonPath();
    final paint = Paint()..style = PaintingStyle.fill;

    // Apply color and gradient
    paint.shader = HexagonColorManager.getHexagonShader(
      path,
      clicked ? Colors.pink : hexagonColor,
      showSearchIcon,
    );
    canvas.drawPath(path, paint);

    // Draw stroke for search icon
    if (showSearchIcon) {
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(path, strokePaint);

      // Draw search icon
      final iconSize = radius * 0.8;
      canvas.save();
      canvas.translate(center.dx - iconSize / 2, center.dy - iconSize / 2);
      canvas.scale(iconSize / 24);
      HexagonIconPainter.paintShadowedIcon(canvas, Icons.search, Colors.white);
      canvas.restore();
    } else if (stepInfo != null) {
      HexagonIconPainter.paintStepInfo(canvas, stepInfo!, center, radius);
    } else if (hexagonColor == Colors.grey[300]) {
      HexagonIconPainter.paintIcon(
        canvas,
        Icons.help_outline,
        center,
        radius,
        Colors.white.withOpacity(0.7),
      );
    }
  }

  Path createHexagonPath() {
    final path = Path();
    var startAngle = math.pi / 2;
    var angle = (math.pi * 2) / SIDES_OF_HEXAGON;

    Offset firstPoint = Offset(
      radius * math.cos(startAngle),
      radius * math.sin(startAngle),
    );
    path.moveTo(firstPoint.dx + center.dx, firstPoint.dy + center.dy);

    for (int i = 1; i <= SIDES_OF_HEXAGON; i++) {
      double x = radius * math.cos(startAngle + angle * i) + center.dx;
      double y = radius * math.sin(startAngle + angle * i) + center.dy;
      path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(StepTypeHexagonPainter oldDelegate) =>
      oldDelegate.clicked != clicked ||
      oldDelegate.hexagonColor != hexagonColor ||
      oldDelegate.stepInfo != stepInfo ||
      oldDelegate.showSearchIcon != showSearchIcon;
}
