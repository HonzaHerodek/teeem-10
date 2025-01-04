import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../compact_project_card.dart';

class SelectableCompactProjectCard extends StatelessWidget {
  final ProjectModel project;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback onToggle;

  const SelectableCompactProjectCard({
    super.key,
    required this.project,
    required this.width,
    required this.height,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CompactProjectCard(
          project: project,
          postThumbnails: const [],
          width: width,
          height: height,
          onTap: onToggle,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isSelected
                    ? const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
