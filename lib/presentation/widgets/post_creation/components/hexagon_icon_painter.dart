import 'package:flutter/material.dart';
import 'hexagon_step_input.dart';

class HexagonIconPainter {
  static void paintIcon(Canvas canvas, IconData icon, Offset center, double radius, Color color) {
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: color,
          fontSize: radius * 0.5,
          fontFamily: 'MaterialIcons',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );
  }

  static void paintShadowedIcon(Canvas canvas, IconData icon, Color color) {
    const shadowOffsets = [
      Offset(3, 3), Offset(-3, -3), Offset(3, -3), Offset(-3, 3),
      Offset(2, 2), Offset(-2, -2), Offset(2, -2), Offset(-2, 2),
      Offset(1, 1), Offset(-1, -1), Offset(1, -1), Offset(-1, 1),
      Offset(0, 0),
    ];

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: const TextStyle(
          fontSize: 24,
          fontFamily: 'MaterialIcons',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();

    for (var i = 0; i < shadowOffsets.length - 1; i++) {
      final opacity = 0.2 * (1 - (i / shadowOffsets.length));
      iconPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'MaterialIcons',
          color: Colors.black.withOpacity(opacity),
        ),
      );
      iconPainter.layout();
      iconPainter.paint(canvas, shadowOffsets[i]);
    }

    iconPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 24,
        fontFamily: 'MaterialIcons',
        color: color,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(canvas, shadowOffsets.last);
  }

  static void paintStepInfo(Canvas canvas, StepInfo stepInfo, Offset center, double radius) {
    // Paint icon first
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(stepInfo.icon.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.5,
          fontFamily: 'MaterialIcons',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();

    // Paint text with word wrapping
    final textPainter = TextPainter(
      text: TextSpan(
        text: stepInfo.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.22, // Slightly smaller to fit two lines
          fontWeight: FontWeight.bold,
          height: 1.1, // Tighter line height for better fit
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
    );
    
    // Layout with constrained width to force wrapping
    textPainter.layout(maxWidth: radius * 1.5);

    // Position icon above text
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - textPainter.height - iconPainter.height / 2,
      ),
    );

    // Position text below icon
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + iconPainter.height / 4,
      ),
    );
  }
}
