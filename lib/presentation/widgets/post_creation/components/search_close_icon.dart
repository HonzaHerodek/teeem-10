import 'package:flutter/material.dart';

class SearchCloseIconWidget extends StatelessWidget {
  final double size;

  const SearchCloseIconWidget({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: SearchCloseIconPainter(),
    );
  }
}

class SearchCloseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw search circle
    final center = Offset(size.width * 0.4, size.height * 0.4);
    final radius = size.width * 0.3;
    canvas.drawCircle(center, radius, paint);

    // Draw search handle
    final handleStart = Offset(
      center.dx + (radius * 0.7),
      center.dy + (radius * 0.7),
    );
    final handleEnd = Offset(
      size.width * 0.75,
      size.height * 0.75,
    );
    canvas.drawLine(handleStart, handleEnd, paint);

    // Draw cross inside the circle
    final crossSize = radius * 0.5;
    canvas.drawLine(
      Offset(center.dx - crossSize, center.dy - crossSize),
      Offset(center.dx + crossSize, center.dy + crossSize),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + crossSize, center.dy - crossSize),
      Offset(center.dx - crossSize, center.dy + crossSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
