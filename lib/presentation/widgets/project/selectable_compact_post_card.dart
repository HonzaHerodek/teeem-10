import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import '../compact_post_card.dart';

class SelectableCompactPostCard extends StatelessWidget {
  final PostModel post;
  final bool isSelected;
  final VoidCallback onToggle;
  final double width;
  final double height;
  final bool isProjectPost;

  const SelectableCompactPostCard({
    super.key,
    required this.post,
    required this.isSelected,
    required this.onToggle,
    required this.isProjectPost,
    this.width = 140,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isProjectPost ? Colors.red : Colors.green;
    
    return GestureDetector(
      onTap: onToggle,
      child: Stack(
        children: [
          // Base CompactPostCard
          CompactPostCard(
            post: post,
            width: width,
            height: height,
            circular: true,
          ),
          // Selection overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 3,
                ),
              ),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: borderColor.withOpacity(0.6),
                            border: Border.all(
                              color: borderColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isProjectPost 
                                ? Icons.close_rounded  // Cross symbol for project posts
                                : Icons.check_rounded, // Check symbol for available posts
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
