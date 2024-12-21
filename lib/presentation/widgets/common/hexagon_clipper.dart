import 'package:flutter/material.dart';

import 'dart:math' as math;

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
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

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
