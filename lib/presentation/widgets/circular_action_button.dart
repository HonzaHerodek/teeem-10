import 'package:flutter/material.dart';

class CircularActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isBold;
  final double size;
  final bool isSelected;
  final double strokeWidth;

  const CircularActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isBold = false,
    this.size = 56.0,
    this.isSelected = false,
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
        border: Border.all(
          color: Colors.white.withOpacity(strokeWidth > 1.0 ? 1.0 : 0.2),
          width: strokeWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              key: ValueKey('action_button_icon_$icon'),
              color: Colors.white,
              size: isBold ? size * 0.57 : size * 0.43,
              weight: isBold || isSelected ? 700 : 400,
            ),
          ),
        ),
      ),
    );
  }
}
