import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/background_color_provider.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<Color> _getColorList(Color baseColor) {
    // Create variations of the base color for the gradient
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
    return Consumer<BackgroundColorProvider>(
      builder: (context, provider, _) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getColorList(provider.backgroundColor),
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
      },
    );
  }
}
