import 'package:flutter/material.dart';
import '../../../../data/models/project_model.dart';
import '../in_feed_post_creation.dart';
import '../../../../presentation/screens/create_post/widgets/project_button.dart';
import './crossed_square_icon.dart';

class PostCreationAddProject extends StatefulWidget {
  final InFeedPostCreation postCreation;
  final ProjectModel project;
  final VoidCallback onRemoveProject;

  const PostCreationAddProject({
    super.key,
    required this.postCreation,
    required this.project,
    required this.onRemoveProject,
  });

  @override
  State<PostCreationAddProject> createState() => _PostCreationAddProjectState();
}

class _PostCreationAddProjectState extends State<PostCreationAddProject> {
  Widget _buildProjectFrame(Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.project.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.project.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onRemoveProject,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CrossedSquareIconWidget(size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: child,
          ),
          const SizedBox(height: 8),
          Center(
            child: ProjectButton(
              selectedProject: widget.project,
              isLoading: false,
              onShowDialog: () {}, // Disabled since this is a newly created project
              onRemoveProject: widget.onRemoveProject,
              isNewlyCreated: true,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildProjectFrame(widget.postCreation);
  }
}
