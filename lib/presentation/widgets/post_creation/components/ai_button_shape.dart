import 'package:flutter/material.dart';

class AIButtonShape extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color shadowColor;
  final double shadowOpacity;

  const AIButtonShape({
    super.key,
    required this.icon,
    this.size = 48,
    this.color = Colors.white,
    this.shadowColor = Colors.black,
    this.shadowOpacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Outermost shadow layer (6px)
        ...[
          const Offset(6, 0),
          const Offset(-6, 0),
          const Offset(0, 6),
          const Offset(0, -6),
          const Offset(6, 6),
          const Offset(-6, -6),
          const Offset(6, -6),
          const Offset(-6, 6),
          const Offset(4.5, 4.5),
          const Offset(-4.5, -4.5),
          const Offset(4.5, -4.5),
          const Offset(-4.5, 4.5),
        ].map((offset) => Transform.translate(
          offset: offset,
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.3),
          ),
        )),

        // Middle shadow layer (3px)
        ...[
          const Offset(3, 0),
          const Offset(-3, 0),
          const Offset(0, 3),
          const Offset(0, -3),
          const Offset(3, 3),
          const Offset(-3, -3),
          const Offset(3, -3),
          const Offset(-3, 3),
        ].map((offset) => Transform.translate(
          offset: offset,
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.5),
          ),
        )),

        // Inner shadow layer (1.5px)
        ...[
          const Offset(1.5, 0),
          const Offset(-1.5, 0),
          const Offset(0, 1.5),
          const Offset(0, -1.5),
          const Offset(1.5, 1.5),
          const Offset(-1.5, -1.5),
          const Offset(1.5, -1.5),
          const Offset(-1.5, 1.5),
        ].map((offset) => Transform.translate(
          offset: offset,
          child: Icon(
            icon,
            size: size,
            color: shadowColor.withOpacity(shadowOpacity * 0.7),
          ),
        )),

        // Main icon
        Icon(
          icon,
          size: size,
          color: color,
        ),
      ],
    );
  }
}
