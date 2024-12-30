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
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isProjectPost ? Colors.red : Colors.green,
            width: 2,
          ),
        ),
        child: CompactProjectCard(
          project: project,
          postThumbnails: postThumbnails,
          width: width,
          height: height,
        ),
      ),
    );
  }
}
