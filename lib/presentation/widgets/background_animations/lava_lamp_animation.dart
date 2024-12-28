import 'package:flutter/material.dart';
import 'dart:math' as math;

class LavaLampAnimation extends StatefulWidget {
  final Color color;
  final Widget child;

  const LavaLampAnimation({
    Key? key,
    required this.color,
    required this.child,
  }) : super(key: key);

  @override
  State<LavaLampAnimation> createState() => _LavaLampAnimationState();
}

class _LavaLampAnimationState extends State<LavaLampAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  final int _blobCount = 4;

  List<Color> _getColors(Color baseColor) {
    final hslColor = HSLColor.fromColor(baseColor);
    return [
      hslColor.withLightness((hslColor.lightness + 0.1).clamp(0.0, 1.0)).toColor(),
      baseColor.withOpacity(0.8),
      hslColor.withLightness((hslColor.lightness - 0.1).clamp(0.0, 1.0)).toColor(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _animations = List.generate(_blobCount, (index) {
      final start = index * (1.0 / _blobCount);
      return Tween<double>(
        begin: start,
        end: start + 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.0,
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_animations[0].value * 2 * math.pi) * 0.5,
                math.cos(_animations[1].value * 2 * math.pi) * 0.5,
              ),
              radius: 1.2 + math.sin(_animations[2].value * 2 * math.pi) * 0.3,
              colors: _getColors(widget.color),
              stops: [
                0.0,
                0.5 + math.sin(_animations[3].value * 2 * math.pi) * 0.2,
                1.0,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
