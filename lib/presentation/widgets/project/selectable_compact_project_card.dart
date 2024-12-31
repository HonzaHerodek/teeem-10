import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../compact_project_card.dart';

class SelectableCompactProjectCard extends StatelessWidget {
  final ProjectModel project;
  final List<String> postThumbnails;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback onToggle;
  final bool isProjectPost;

  const SelectableCompactProjectCard({
    super.key,
    required this.project,
    required this.postThumbnails,
    required this.width,
    required this.height,
    required this.isSelected,
    required this.onToggle,
    required this.isProjectPost,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isProjectPost ? Colors.red : Colors.green;
    
    return GestureDetector(
      onTap: onToggle,
      child: Stack(
        children: [
          // Base CompactProjectCard with border
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: borderColor,
                width: 3,
              ),
            ),
            child: CompactProjectCard(
              project: project,
              postThumbnails: postThumbnails,
              width: width,
              height: height,
            ),
          ),
          // Selection overlay
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
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
              ),
            ),
        ],
      ),
    );
  }
}
