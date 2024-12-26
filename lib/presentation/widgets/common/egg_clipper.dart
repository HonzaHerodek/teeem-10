import 'package:flutter/material.dart';

class EggClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width * 0.98; // Very subtle width reduction
    final h = size.height;
    final wm = w / 2;
    
    // Center the shape
    final xOffset = (size.width - w) / 2;
    
    // Start from bottom center
    path.moveTo(xOffset + wm, h);
    
    // Left side - smoother curve with more control points
    path.cubicTo(
      xOffset,           h * 0.9,  // First control point - closer to bottom
      xOffset,           h * 0.3,  // Second control point - higher up
      xOffset + wm,      0         // End point
    );
    
    // Right side - mirror the left side for symmetry
    path.cubicTo(
      xOffset + w,       h * 0.3,  // First control point - higher up
      xOffset + w,       h * 0.9,  // Second control point - closer to bottom
      xOffset + wm,      h         // End point
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
