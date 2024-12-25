import 'package:flutter/material.dart';

class EggClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width * 0.65; // Much narrower width
    final h = size.height;
    final wm = w / 2;
    final hm = h / 2;
    
    // Center the shape
    final xOffset = (size.width - w) / 2;
    
    path.moveTo(xOffset + wm, h); // Start from bottom center
    
    // Left side
    path.quadraticBezierTo(
      xOffset, h * 0.8, // Control point
      xOffset, h * 0.5  // End point
    );
    
    path.quadraticBezierTo(
      xOffset, h * 0.15, // Control point
      xOffset + wm, 0    // End point
    );
    
    // Right side
    path.quadraticBezierTo(
      xOffset + w, h * 0.15, // Control point
      xOffset + w, h * 0.5   // End point
    );
    
    path.quadraticBezierTo(
      xOffset + w, h * 0.8, // Control point
      xOffset + wm, h       // End point
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
