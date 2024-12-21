import 'package:flutter/material.dart';
import 'dart:math' as math;

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
        // Shadow layers
        for (var offset in [
          const Offset(2, 2),
          const Offset(-2, 2),
          const Offset(2, -2),
          const Offset(-2, -2),
        ])
          Transform.translate(
            offset: offset,
            child: CustomPaint(
              size: Size(size, size),
              painter: _HexagonPainter(
                color: shadowColor,
                opacity: shadowOpacity * 0.5,
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
          size: Size(size * 0.6, size * 0.6),
          painter: _PlusPainter(
            color: color,
            strokeWidth: 2.5,
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
    final width = size.width;
    final height = size.height;
    
    // Calculate center and radius for a regular hexagon
    final centerX = width / 2;
    final centerY = height / 2;
    final radius = math.min(width / math.sqrt(3), height / 2);
    
    // Calculate the six vertices of the regular hexagon
    final vertices = List.generate(6, (i) {
      final angle = (i * 60 + 30) * math.pi / 180; // Start from top vertex (30°)
      return Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );
    });

    // Draw the hexagon path
    path.moveTo(vertices[0].dx, vertices[0].dy);
    for (int i = 1; i < vertices.length; i++) {
      path.lineTo(vertices[i].dx, vertices[i].dy);
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HexagonPainter oldDelegate) => 
    color != oldDelegate.color || opacity != oldDelegate.opacity;
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
