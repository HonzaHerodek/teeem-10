import 'package:flutter/material.dart';

class PostCreationCancelButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onCancel;

  const PostCreationCancelButton({
    Key? key,
    required this.isLoading,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: isLoading ? null : onCancel,
            padding: const EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }
}
