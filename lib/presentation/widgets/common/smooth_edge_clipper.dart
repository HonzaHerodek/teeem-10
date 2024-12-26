import 'package:flutter/material.dart';
import 'dart:math' as math;

class SmoothEdgeClipper extends CustomClipper<Path> {
  final double smoothness;
  
  const SmoothEdgeClipper({
    this.smoothness = 0.5,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    
    // Create control points for a smooth curve
    final centerX = width / 2;
    final centerY = height / 2;
    
    // Calculate the radius with a slight oval shape
    final radiusX = width * 0.5;
    final radiusY = height * 0.5;
    
    // Create a smooth oval path using cubic curves
    path.moveTo(centerX + radiusX, centerY);
    
    // Top right quadrant
    path.cubicTo(
      centerX + radiusX, centerY - (radiusY * 0.2),
      centerX + (radiusX * 0.8), centerY - radiusY,
      centerX, centerY - radiusY
    );
    
    // Top left quadrant
    path.cubicTo(
      centerX - (radiusX * 0.8), centerY - radiusY,
      centerX - radiusX, centerY - (radiusY * 0.2),
      centerX - radiusX, centerY
    );
    
    // Bottom left quadrant
    path.cubicTo(
      centerX - radiusX, centerY + (radiusY * 0.2),
      centerX - (radiusX * 0.8), centerY + radiusY,
      centerX, centerY + radiusY
    );
    
    // Bottom right quadrant
    path.cubicTo(
      centerX + (radiusX * 0.8), centerY + radiusY,
      centerX + radiusX, centerY + (radiusY * 0.2),
      centerX + radiusX, centerY
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
