import 'package:flutter/material.dart';

class ShadowedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final TextAlign textAlign;
  final int maxLines;
  final double strokeWidth;
  final double shadowOpacity;
  final Color shadowColor;

  const ShadowedText({
    super.key,
    required this.text,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w500,
    this.letterSpacing = 0.2,
    this.textAlign = TextAlign.center,
    this.maxLines = 1,
    this.strokeWidth = 3,
    this.shadowOpacity = 0.5,
    this.shadowColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Shadow text for better visibility
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = shadowColor.withOpacity(shadowOpacity),
          ),
          textAlign: textAlign,
          maxLines: maxLines,
        ),
        // Main text
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
        ),
      ],
    );
  }
}
