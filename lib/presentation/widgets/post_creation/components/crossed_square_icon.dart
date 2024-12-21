import 'package:flutter/material.dart';

class CrossedSquareIcon extends CustomPainter {
  final Color color;

  CrossedSquareIcon({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw rounded square
    final RRect square = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    canvas.drawRRect(square, paint);

    // Draw diagonal line
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CrossedSquareIconWidget extends StatelessWidget {
  final double size;
  final Color color;

  const CrossedSquareIconWidget({
    super.key,
    this.size = 40.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: CrossedSquareIcon(color: color),
    );
  }
}
