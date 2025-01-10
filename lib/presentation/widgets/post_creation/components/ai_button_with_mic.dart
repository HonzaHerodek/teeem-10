import 'package:flutter/material.dart';
import 'ai_button_shape.dart';

class AIButtonWithMic extends StatefulWidget {
  final double size;
  final bool isHighlighted;
  final VoidCallback onPressed;

  const AIButtonWithMic({
    super.key,
    this.size = 48,
    this.isHighlighted = false,
    required this.onPressed,
  });

  @override
  State<AIButtonWithMic> createState() => _AIButtonWithMicState();
}

class _AIButtonWithMicState extends State<AIButtonWithMic>
    with SingleTickerProviderStateMixin {
  late AnimationController _borderController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _borderAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _borderController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isHighlighted)
            AnimatedBuilder(
              animation: _borderAnimation,
              builder: (context, child) {
                return Container(
                  width: widget.size * 1.4,
                  height: widget.size * 1.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(_borderAnimation.value),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
          Stack(
            alignment: Alignment.center,
            children: [
              AIButtonShape(
                icon: Icons.auto_awesome,
                size: widget.size,
              ),
              if (widget.isHighlighted)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mic,
                      size: widget.size * 0.4,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
