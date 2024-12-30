import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedDot extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final Offset startPosition;
  final double speed;

  const AnimatedDot({
    super.key,
    required this.size,
    required this.color,
    required this.duration,
    required this.startPosition,
    required this.speed,
  });

  @override
  State<AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Offset _currentPosition;
  late double _angle;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.startPosition;
    _angle = math.Random().nextDouble() * 2 * math.pi;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        setState(() {
          // Update position based on angle and speed
          _currentPosition += Offset(
            math.cos(_angle) * widget.speed,
            math.sin(_angle) * widget.speed,
          );

          // Bounce off edges
          if (_currentPosition.dx < 0 || _currentPosition.dx > 1) {
            _angle = math.pi - _angle;
          }
          if (_currentPosition.dy < 0 || _currentPosition.dy > 1) {
            _angle = -_angle;
          }
        });
      })..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _currentPosition.dx * MediaQuery.of(context).size.width,
      top: _currentPosition.dy * MediaQuery.of(context).size.height,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(0.6),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: widget.size,
              spreadRadius: widget.size / 2,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedDotsBackground extends StatelessWidget {
  final int numberOfDots;

  const AnimatedDotsBackground({
    super.key,
    this.numberOfDots = 20,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random();
    
    List<Color> colors = [
      const Color(0xFF00FF00), // Green
      const Color(0xFF00FFFF), // Cyan
      const Color(0xFF0000FF), // Blue
    ];

    return Stack(
      children: List.generate(numberOfDots, (index) {
        return AnimatedDot(
          size: random.nextDouble() * 20 + 5, // Random size between 5 and 25
          color: colors[random.nextInt(colors.length)],
          duration: Duration(seconds: random.nextInt(5) + 5), // Random duration between 5 and 10 seconds
          startPosition: Offset(
            random.nextDouble(),
            random.nextDouble(),
          ),
          speed: (random.nextDouble() * 0.002) + 0.001, // Random speed
        );
      }),
    );
  }
}
