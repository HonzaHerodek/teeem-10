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
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(highlightAnimation!.value),
                      width: 2,
                    ),
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
