import 'package:flutter/material.dart';

class StripesAnimation extends StatefulWidget {
  final Color color;
  final Widget child;

  const StripesAnimation({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  @override
  State<StripesAnimation> createState() => _StripesAnimationState();
}

class _StripesAnimationState extends State<StripesAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<Color> _getColorList(Color baseColor) {
    final hslColor = HSLColor.fromColor(baseColor);
    return [
      hslColor.withLightness((hslColor.lightness + 0.2).clamp(0.0, 1.0)).toColor(),
      baseColor,
      hslColor.withLightness((hslColor.lightness - 0.2).clamp(0.0, 1.0)).toColor(),
      baseColor,
      hslColor.withLightness((hslColor.lightness + 0.2).clamp(0.0, 1.0)).toColor(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(_controller);
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
              colors: _getColorList(widget.color),
              stops: [
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.2).clamp(0.0, 1.0),
                (_animation.value + 0.4).clamp(0.0, 1.0),
                (_animation.value + 0.6).clamp(0.0, 1.0),
                (_animation.value + 0.8).clamp(0.0, 1.0),
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
