import 'package:flutter/material.dart';

class GradientAnimation extends StatefulWidget {
  final Color color;
  final Widget child;

  const GradientAnimation({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  @override
  State<GradientAnimation> createState() => _GradientAnimationState();
}

class _GradientAnimationState extends State<GradientAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<Color> _getColors(Color baseColor, double value) {
    final hslColor = HSLColor.fromColor(baseColor);
    final adjustedHue = (hslColor.hue + value * 30) % 360;
    final primaryColor = hslColor.withHue(adjustedHue);
    
    return [
      primaryColor.withLightness((primaryColor.lightness + 0.1).clamp(0.0, 1.0)).toColor(),
      primaryColor.withSaturation((primaryColor.saturation - 0.1).clamp(0.0, 1.0)).toColor(),
      primaryColor.withLightness((primaryColor.lightness - 0.1).clamp(0.0, 1.0)).toColor(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getColors(widget.color, _animation.value),
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
