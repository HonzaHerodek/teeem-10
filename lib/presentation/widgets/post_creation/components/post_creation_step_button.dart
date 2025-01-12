import 'package:flutter/material.dart';

class PostCreationStepButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final bool hasSelectedStepType;
  final bool isGridButton;

  const PostCreationStepButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
    required this.hasSelectedStepType,
    this.isGridButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: GestureDetector(
          onTap: isLoading ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.225),
              border: Border.all(color: Colors.white24, width: 1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              isGridButton ? Icons.grid_on : (hasSelectedStepType ? Icons.edit : Icons.close),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
