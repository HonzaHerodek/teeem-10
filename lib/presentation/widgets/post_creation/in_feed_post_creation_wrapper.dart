import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/project_model.dart';
import '../../screens/create_post/widgets/project_button.dart';
import '../../screens/create_post/widgets/project_selection_dialog.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'in_feed_post_creation.dart';

class InFeedPostCreationWrapper extends StatefulWidget {
  final GlobalKey<InFeedPostCreationState>? postCreationKey;
  final VoidCallback onCancel;
  final Function(bool, ProjectModel?) onComplete;

  const InFeedPostCreationWrapper({
    super.key,
    this.postCreationKey,
    required this.onCancel,
    required this.onComplete,
  });

  @override
  State<InFeedPostCreationWrapper> createState() => _InFeedPostCreationWrapperState();
}

class _InFeedPostCreationWrapperState extends State<InFeedPostCreationWrapper> {
  ProjectModel? _selectedProject;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InFeedPostCreation(
          key: widget.postCreationKey,
          onCancel: widget.onCancel,
          onComplete: (success) => widget.onComplete(success, _selectedProject),
        ),
        const SizedBox(height: 16), // Increased spacing for better visual separation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ProjectButton(
            selectedProject: _selectedProject,
            isLoading: false,
            onShowDialog: () async {
              final authState = context.read<AuthBloc>().state;
              if (!authState.isAuthenticated || authState.userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in to add projects')),
                );
                return;
              }

              final result = await showDialog<ProjectModel?>(
                context: context,
                builder: (context) => ProjectSelectionDialog(
                  userProjects: const [], // Will be loaded by the dialog
                  userId: authState.userId!,
                  onProjectCreated: (project) async {
                    // Project creation is handled by the dialog
                  },
                ),
              );
              if (result != null) {
                setState(() => _selectedProject = result);
              }
            },
            onRemoveProject: () => setState(() => _selectedProject = null),
          ),
        ),
      ],
    );
  }
}
