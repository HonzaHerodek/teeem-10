import 'package:flutter/material.dart';
import '../../../../data/models/project_model.dart';
import './borderless_square_button.dart';

class ProjectButton extends StatelessWidget {
  final ProjectModel? selectedProject;
  final bool isLoading;
  final VoidCallback onShowDialog;
  final VoidCallback? onRemoveProject;

  const ProjectButton({
    super.key,
    this.selectedProject,
    required this.isLoading,
    required this.onShowDialog,
    this.onRemoveProject,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BorderlessSquareButton(
            icon: selectedProject != null ? Icons.folder_special : Icons.add_box_outlined,
            onPressed: isLoading ? () {} : onShowDialog,
            size: 40,
          ),
          if (selectedProject != null)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onRemoveProject,
                  color: Colors.black,
                  tooltip: 'Remove project',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
