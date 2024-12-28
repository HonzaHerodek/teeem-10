import 'package:flutter/material.dart';

class BottomSlidingPanel extends StatefulWidget {
  final Widget child;
  final bool isOpen;
  final VoidCallback? onClose;

  const BottomSlidingPanel({
    super.key,
    required this.child,
    required this.isOpen,
    this.onClose,
  });

  @override
  State<BottomSlidingPanel> createState() => _BottomSlidingPanelState();
}

class _BottomSlidingPanelState extends State<BottomSlidingPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double _dragStartY = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isOpen) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(BottomSlidingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartY = details.localPosition.dy;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final dragDistance = details.localPosition.dy - _dragStartY;
    final screenHeight = MediaQuery.of(context).size.height;
    final normalizedDrag = dragDistance / screenHeight;

    if (normalizedDrag > 0) {
      _controller.value = 1.0 - normalizedDrag;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 500 || _controller.value < 0.5) {
      widget.onClose?.call();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent overlay with animation
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_controller.value > 0) {
              return Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    color: Colors.black.withOpacity(0.14 * _controller.value),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // Sliding panel
        SlideTransition(
          position: _offsetAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onVerticalDragStart: widget.isOpen ? _handleDragStart : null,
              onVerticalDragUpdate: widget.isOpen ? _handleDragUpdate : null,
              onVerticalDragEnd: widget.isOpen ? _handleDragEnd : null,
              child: Material(
                elevation: 16,
                color: Colors.transparent,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
