import 'package:flutter/material.dart';
import '../../../../data/models/project_model.dart';

class ProjectSelectionDialog extends StatelessWidget {
  final List<ProjectModel> userProjects;
  final String userId;
  final Function(ProjectModel) onProjectCreated;

  const ProjectSelectionDialog({
    super.key,
    required this.userProjects,
    required this.userId,
    required this.onProjectCreated,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to Project'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userProjects.isNotEmpty) ...[
              const Text('Select existing project:'),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: userProjects.length,
                  itemBuilder: (context, index) {
                    final project = userProjects[index];
                    return ListTile(
                      title: Text(project.name),
                      subtitle: Text(project.description),
                      onTap: () => Navigator.pop(context, project),
                    );
                  },
                ),
              ),
              const Divider(),
            ],
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create New Project'),
              onPressed: () => _showCreateProjectDialog(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _showCreateProjectDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final newProject = await showDialog<ProjectModel?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Project'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a description' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final project = ProjectModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descController.text,
                  creatorId: userId,
                  postIds: [],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                onProjectCreated(project);
                Navigator.pop(context, project);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (context.mounted && newProject != null) {
      Navigator.pop(context, newProject);
    }
  }
}
