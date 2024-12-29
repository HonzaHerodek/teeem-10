import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
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
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    // Using sine wave for smooth, continuous animation with custom easing
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        weight: 1,
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: const _SineWaveCurve())),
      ),
    ]).animate(_controller);
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
            return Stack(
              children: [
                // Base black background
                Container(color: Colors.black),
                
                // Smooth gradient layers
                Opacity(
                  opacity: 0.7,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..rotateZ(_animation.value * math.pi / 4)
                      ..scale(2.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black,
                            Color(0xFF353535),
                            Color(0xFF454545),
                            Color(0xFF353535),
                            Colors.black,
                          ],
                          stops: [0.0, 0.35, 0.5, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Second layer with slower movement
                Opacity(
                  opacity: 0.5,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..rotateZ(-_animation.value * math.pi / 6)
                      ..scale(1.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black,
                            Color(0xFF303030),
                            Color(0xFF404040),
                            Color(0xFF303030),
                            Colors.black,
                          ],
                          stops: [0.0, 0.35, 0.5, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Content
                child!,
              ],
            );
          },
          child: widget.child,
        );
      },
    );
  }
}

// Custom curve that follows a sine wave pattern for smooth looping
class _SineWaveCurve extends Curve {
  const _SineWaveCurve();

  @override
  double transformInternal(double t) {
    // Smoother sine wave with custom easing
    return (math.sin(t * 2 * math.pi) + math.sin(t * math.pi) + 2) / 4;
  }
}
