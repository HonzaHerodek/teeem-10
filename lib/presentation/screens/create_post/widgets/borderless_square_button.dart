import 'package:flutter/material.dart';

class BorderlessSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isBold;
  final double size;

  const BorderlessSquareButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isBold = false,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 12.0;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              key: ValueKey('action_button_icon_$icon'),
              color: Colors.white,
              size: isBold ? size * 0.6 : size * 0.5,
              weight: isBold ? 700 : 400,
            ),
          ),
        ),
      ),
    );
  }
}
