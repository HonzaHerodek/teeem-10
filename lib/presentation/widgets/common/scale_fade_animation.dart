import 'package:flutter/material.dart';

class ScaleFadeAnimation extends StatefulWidget {
  final Widget child;
  final bool isVisible;
  final VoidCallback? onAnimationComplete;
  final Duration duration;
  final double initialScale;
  final double peakScale;
  final double finalScale;
  final Curve scaleCurve;
  final Curve fadeInCurve;
  final double fadeStartThreshold;

  const ScaleFadeAnimation({
    super.key,
    required this.child,
    required this.isVisible,
    this.onAnimationComplete,
    this.duration = const Duration(milliseconds: 1200), // Longer duration
    this.initialScale = 0.0,
    this.peakScale = 1.05,
    this.finalScale = 1.0,
    this.scaleCurve = Curves.easeOutBack,
    this.fadeInCurve = Curves.easeOut,
    this.fadeStartThreshold = 0.1,
  });

  @override
  State<ScaleFadeAnimation> createState() => _ScaleFadeAnimationState();
}

class _ScaleFadeAnimationState extends State<ScaleFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
      value: 0.0,
    );

    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Scale animation with smooth transitions
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInExpo,
      reverseCurve: Curves.easeInExpo,
    ));

    // Fade animation synchronized with scale
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0, 0.5,
        curve: Curves.easeIn,
      ),
      reverseCurve: const Interval(
        0.0, 0.4,
        curve: Curves.easeIn,
      ),
    ));

    // Start animation if needed
    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ScaleFadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reinitialize animations if animation parameters changed
    if (oldWidget.initialScale != widget.initialScale ||
        oldWidget.peakScale != widget.peakScale ||
        oldWidget.finalScale != widget.finalScale ||
        oldWidget.scaleCurve != widget.scaleCurve ||
        oldWidget.fadeInCurve != widget.fadeInCurve ||
        oldWidget.fadeStartThreshold != widget.fadeStartThreshold) {
      _initializeAnimations();
    }

    // Handle visibility changes
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward().then((_) {
        widget.onAnimationComplete?.call();
      });
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse().then((_) {
        widget.onAnimationComplete?.call();
      });
    }
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: Alignment.center,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
