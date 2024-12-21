import 'package:flutter/material.dart';
import '../../../../data/models/project_model.dart';

class ProjectButton extends StatelessWidget {
  final ProjectModel? selectedProject;
  final bool isLoading;
  final VoidCallback onShowDialog;
  final VoidCallback? onRemoveProject;
  final bool isNewlyCreated;

  const ProjectButton({
    super.key,
    this.selectedProject,
    required this.isLoading,
    required this.onShowDialog,
    this.onRemoveProject,
    this.isNewlyCreated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: selectedProject != null && isNewlyCreated
                      ? Border.all(color: Colors.white, width: 1.0)
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: isLoading 
                        ? () {} 
                        : (selectedProject != null && isNewlyCreated 
                            ? onRemoveProject 
                            : onShowDialog),
                    child: Center(
                      child: Icon(
                        selectedProject != null 
                            ? (isNewlyCreated ? Icons.close_outlined : Icons.folder_special)
                            : Icons.add_box_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
