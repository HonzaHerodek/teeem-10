import 'package:flutter/material.dart';

class TargetIcon extends StatelessWidget {
  final VoidCallback onTap;
  final bool isActive;
  final bool isHighlighted;
  final Animation<double>? highlightAnimation;

  const TargetIcon({
    super.key,
    required this.onTap,
    this.isActive = false,
    this.isHighlighted = false,
    this.highlightAnimation,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
      ),
      child: IconButton(
        icon: Icon(
          isActive ? Icons.group : Icons.group_outlined,
          color: Colors.white,
        ),
        onPressed: onTap,
      ),
    );

    if (isHighlighted && highlightAnimation != null) {
      return Stack(
        children: [
          icon,
          Positioned.fill(
            child: AnimatedBuilder(
              animation: highlightAnimation!,
              builder: (context, child) {
                final colors = [Colors.purple, Colors.yellow, Colors.blue, Colors.green];
                final currentColorIndex = (highlightAnimation!.value * (colors.length - 1)).floor();
                final nextColorIndex = (currentColorIndex + 1) % colors.length;
                final progress = (highlightAnimation!.value * (colors.length - 1)) - currentColorIndex;
                
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.lerp(
                        colors[currentColorIndex],
                        colors[nextColorIndex],
                        progress,
                      )!.withOpacity(0.8),
                      width: 4.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors[currentColorIndex].withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return icon;
  }
}
