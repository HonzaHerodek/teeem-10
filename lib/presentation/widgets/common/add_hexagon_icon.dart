import 'package:flutter/material.dart';
import 'dart:math';

class AddHexagonIcon extends StatelessWidget {
  final double size;
  final Color color;
  final Color shadowColor;
  final double shadowOpacity;

  const AddHexagonIcon({
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.shadowColor = Colors.black,
    this.shadowOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outermost shadow layer
        Transform.translate(
          offset: const Offset(3, 3),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.4,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-3, -3),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.4,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(3, -3),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.4,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-3, 3),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.4,
            ),
          ),
        ),
        // Middle shadow layer
        Transform.translate(
          offset: const Offset(2, 2),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.6,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-2, -2),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.6,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(2, -2),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.6,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-2, 2),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.6,
            ),
          ),
        ),
        // Inner shadow layer
        Transform.translate(
          offset: const Offset(1, 1),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.8,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-1, -1),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.8,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(1, -1),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.8,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(-1, 1),
          child: CustomPaint(
            size: Size(size, size),
            painter: _HexagonPainter(
              color: shadowColor,
              opacity: shadowOpacity * 0.8,
            ),
          ),
        ),
        // Main hexagon
        CustomPaint(
          size: Size(size, size),
          painter: _HexagonPainter(
            color: color,
            opacity: 1.0,
          ),
        ),
        // Plus icon with stroke
        CustomPaint(
          size: Size(size * 0.65, size * 0.65),
          painter: _PlusPainter(
            color: color,
            strokeWidth: 3.0,
            shadowColor: shadowColor,
            shadowOpacity: shadowOpacity,
          ),
        ),
      ],
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;
  final double opacity;

  _HexagonPainter({
    required this.color,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final side = w * 0.5;
    final centerX = w / 2;
    final centerY = h / 2;

    path.moveTo(centerX + side * cos(0), centerY + side * sin(0));

    for (int i = 1; i <= 6; i++) {
      final angle = i * (pi / 3);
      path.lineTo(
        centerX + side * cos(angle),
        centerY + side * sin(angle),
      );
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HexagonPainter oldDelegate) => color != oldDelegate.color;
}

class _PlusPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final Color shadowColor;
  final double shadowOpacity;

  _PlusPainter({
    required this.color,
    required this.strokeWidth,
    required this.shadowColor,
    required this.shadowOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw stroke
    final strokePaint = Paint()
      ..color = shadowColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2.0
      ..strokeCap = StrokeCap.round;

    // Draw main plus
    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final length = size.width * 0.35;

    // Vertical line
    canvas.drawLine(
      Offset(centerX, centerY - length),
      Offset(centerX, centerY + length),
      strokePaint,
    );
    // Horizontal line
    canvas.drawLine(
      Offset(centerX - length, centerY),
      Offset(centerX + length, centerY),
      strokePaint,
    );

    // Main plus
    // Vertical line
    canvas.drawLine(
      Offset(centerX, centerY - length),
      Offset(centerX, centerY + length),
      mainPaint,
    );
    // Horizontal line
    canvas.drawLine(
      Offset(centerX - length, centerY),
      Offset(centerX + length, centerY),
      mainPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
