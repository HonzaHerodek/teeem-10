import 'package:flutter/material.dart';
import '../../providers/background_animation_provider.dart';
import 'stripes_animation.dart';
import 'lava_lamp_animation.dart';
import 'gradient_animation.dart';
import 'static_background.dart';

class BackgroundAnimationManager extends StatelessWidget {
  final BackgroundAnimationType type;
  final Color color;
  final Widget child;

  const BackgroundAnimationManager({
    Key? key,
    required this.type,
    required this.color,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case BackgroundAnimationType.stripes:
        return StripesAnimation(color: color, child: child);
      case BackgroundAnimationType.lavaLamp:
        return LavaLampAnimation(color: color, child: child);
      case BackgroundAnimationType.gradient:
        return GradientAnimation(color: color, child: child);
      case BackgroundAnimationType.none:
        return StaticBackground(color: color, child: child);
    }
  }
}
