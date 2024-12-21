import 'package:flutter/material.dart';

class ShadowedShape extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color shadowColor;
  final double shadowOpacity;

  const ShadowedShape({
    super.key,
    required this.icon,
    this.size = 27,
    this.color = Colors.white,
    this.shadowColor = Colors.black,
    this.shadowOpacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Outermost shadow layer
        Transform.translate(
          offset: const Offset(3, 3),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.4),
          ),
        ),
        Transform.translate(
          offset: const Offset(-3, -3),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.4),
          ),
        ),
        Transform.translate(
          offset: const Offset(3, -3),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.4),
          ),
        ),
        Transform.translate(
          offset: const Offset(-3, 3),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.4),
          ),
        ),
        // Middle shadow layer
        Transform.translate(
          offset: const Offset(2, 2),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.6),
          ),
        ),
        Transform.translate(
          offset: const Offset(-2, -2),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.6),
          ),
        ),
        Transform.translate(
          offset: const Offset(2, -2),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.6),
          ),
        ),
        Transform.translate(
          offset: const Offset(-2, 2),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.6),
          ),
        ),
        // Inner shadow layer
        Transform.translate(
          offset: const Offset(1, 1),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.8),
          ),
        ),
        Transform.translate(
          offset: const Offset(-1, -1),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.8),
          ),
        ),
        Transform.translate(
          offset: const Offset(1, -1),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.8),
          ),
        ),
        Transform.translate(
          offset: const Offset(-1, 1),
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.8),
          ),
        ),
        // Main icon on top
        Icon(
          icon,
          size: size,
          color: color,
        ),
      ],
    );
  }
}
