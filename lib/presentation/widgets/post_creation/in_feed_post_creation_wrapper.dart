import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/project_model.dart';
import '../../screens/create_post/widgets/project_button.dart';
import '../../screens/create_post/widgets/project_selection_dialog.dart';
import '../../screens/create_post/managers/post_creation_manager.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'in_feed_post_creation.dart';
import 'components/post_creation_add_project.dart';

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
  bool _isNewlyCreatedProject = false;

  Widget _buildProjectButton() {
    return Padding(
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

          final manager = PostCreationManager();
          final userProjects = await manager.loadUserProjects(authState.userId!);
          
          if (!context.mounted) return;
          
          final result = await showDialog<ProjectModel?>(
            context: context,
            builder: (context) => ProjectSelectionDialog(
              userProjects: userProjects,
              userId: authState.userId!,
              onProjectCreated: (project) async {
                await manager.createProject(project);
                if (mounted) {
                  setState(() {
                    _selectedProject = project;
                    _isNewlyCreatedProject = true;
                  });
                }
              },
            ),
          );
          
          if (result != null && result != _selectedProject) {
            setState(() {
              _selectedProject = result;
              _isNewlyCreatedProject = false;
            });
          }
        },
        onRemoveProject: _selectedProject != null ? () => setState(() {
          _selectedProject = null;
          _isNewlyCreatedProject = false;
        }) : null,
        isNewlyCreated: _isNewlyCreatedProject,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selectedProject != null && _isNewlyCreatedProject)
          PostCreationAddProject(
            postCreation: InFeedPostCreation(
              key: widget.postCreationKey,
              onCancel: widget.onCancel,
              onComplete: (success) => widget.onComplete(success, _selectedProject),
            ),
            project: _selectedProject!,
            onRemoveProject: () => setState(() {
              _selectedProject = null;
              _isNewlyCreatedProject = false;
            }),
          )
        else
          Column(
            children: [
              InFeedPostCreation(
                key: widget.postCreationKey,
                onCancel: widget.onCancel,
                onComplete: (success) => widget.onComplete(success, _selectedProject),
              ),
              const SizedBox(height: 16),
              _buildProjectButton(),
            ],
          ),
      ],
    );
  }
}
