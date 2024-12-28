import 'package:flutter/material.dart';

class StaticBackground extends StatelessWidget {
  final Color color;
  final Widget child;

  const StaticBackground({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  List<Color> _getColors(Color baseColor) {
    final hslColor = HSLColor.fromColor(baseColor);
    return [
      hslColor.withLightness((hslColor.lightness + 0.1).clamp(0.0, 1.0)).toColor(),
      baseColor,
      hslColor.withLightness((hslColor.lightness - 0.1).clamp(0.0, 1.0)).toColor(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getColors(color),
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
