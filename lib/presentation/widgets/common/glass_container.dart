import 'package:flutter/material.dart';
import 'dart:ui';
import 'gradient_box_border.dart';

class CircularClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RoundedRectClipper extends CustomClipper<Path> {
  final BorderRadius borderRadius;

  RoundedRectClipper(this.borderRadius);

  @override
  Path getClip(Size size) {
    return Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width, size.height),
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<Color> gradientColors;
  final List<Color> borderGradientColors;
  final double blurStrength;
  final List<BoxShadow>? boxShadow;
  final List<double>? gradientStops;
  final bool isCircular;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.isCircular = false,
    this.gradientColors = const [
      Color.fromRGBO(255, 255, 255, 0.2),
      Color.fromRGBO(255, 255, 255, 0.05),
    ],
    this.borderGradientColors = const [
      Color.fromRGBO(255, 255, 255, 0.5),
      Color.fromRGBO(255, 255, 255, 0.2),
    ],
    this.blurStrength = 20.0,
    this.boxShadow = const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.2),
        blurRadius: 15,
        spreadRadius: -10,
      ),
    ],
    this.gradientStops,
  });

  factory GlassContainer.newlyCreated({
    required Widget child,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    bool isCircular = false,
  }) {
    return GlassContainer(
      child: child,
      borderRadius: borderRadius,
      padding: padding,
      isCircular: isCircular,
      gradientColors: const [
        Color.fromRGBO(255, 255, 255, 0.2),
        Color.fromRGBO(255, 255, 255, 0.05),
      ],
      borderGradientColors: const [
        Color.fromRGBO(255, 255, 255, 0.5),
        Color.fromRGBO(255, 255, 255, 0.2),
      ],
      blurStrength: 15.0,
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.25),
          blurRadius: 15,
          spreadRadius: 1,
          offset: Offset(0, 0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final clipper = isCircular
        ? CircularClipper()
        : RoundedRectClipper(borderRadius ?? BorderRadius.circular(32.0));

    return Container(
      decoration: BoxDecoration(
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            !isCircular ? (borderRadius ?? BorderRadius.circular(32.0)) : null,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
          stops: gradientStops,
        ),
        border: borderGradientColors.isEmpty ? null : GradientBoxBorder(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: borderGradientColors,
          ),
          width: 1.0,
        ),
        boxShadow: boxShadow,
      ),
      child: ClipPath(
        clipper: clipper,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurStrength,
                sigmaY: blurStrength,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradientColors[0].withOpacity(0.75),
                      gradientColors[1].withOpacity(0.75),
                    ],
                    stops: gradientStops,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.5,
                      colors: [
                        gradientColors[0].withOpacity(0.75),
                        gradientColors[1].withOpacity(0.75),
                      ],
                      stops: const [0.1, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
