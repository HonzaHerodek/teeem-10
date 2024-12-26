import 'package:flutter/material.dart';

class EggClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width * 0.85; // Wider width for more oval shape
    final h = size.height;
    final wm = w / 2;
    
    // Center the shape
    final xOffset = (size.width - w) / 2;
    
    path.moveTo(xOffset + wm, h); // Start from bottom center
    
    // Left side with rounder curves
    path.quadraticBezierTo(
      xOffset, h * 0.9, // Bottom control point moved up for rounder bottom
      xOffset, h * 0.5  // End point
    );
    
    path.quadraticBezierTo(
      xOffset, h * 0.1, // Top control point moved down for rounder top
      xOffset + wm, h * 0.1 // End point moved down to create round top
    );
    
    // Right side with rounder curves
    path.quadraticBezierTo(
      xOffset + w, h * 0.1, // Top control point moved down for rounder top
      xOffset + w, h * 0.5   // End point
    );
    
    path.quadraticBezierTo(
      xOffset + w, h * 0.9, // Bottom control point moved up for rounder bottom
      xOffset + wm, h       // End point
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
