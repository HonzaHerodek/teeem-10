import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';

class MockProjectRepository implements ProjectRepository {
  final List<ProjectModel> _projects = [
    ProjectModel(
      id: '1',
      name: 'Photography Collection',
      description: 'A collection of my best photography work from 2023',
      creatorId: 'user1',
      postIds: ['post_0', 'post_1', 'post_2'],
      childrenIds: ['3', '4'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
    ProjectModel(
      id: '2',
      name: 'Travel Adventures',
      description: 'Documenting my travels across Europe',
      creatorId: 'user1',
      postIds: ['post_3', 'post_4'],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ProjectModel(
      id: '3',
      name: 'Nature Photography',
      description: 'Wildlife and landscape shots',
      creatorId: 'user1',
      postIds: ['post_1'],
      parentId: '1',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
    ),
    ProjectModel(
      id: '4',
      name: 'Urban Photography',
      description: 'City life and architecture',
      creatorId: 'user1',
      postIds: ['post_2'],
      parentId: '1',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<ProjectModel>> getProjects() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    // For development: ensure Photography Collection appears first
    final projects = List<ProjectModel>.from(_projects);
    final photographyIndex = projects.indexWhere((p) => p.id == '1');
    if (photographyIndex > 0) {
      final photography = projects.removeAt(photographyIndex);
      projects.insert(0, photography);
    }
    return projects;
  }

  @override
  Future<ProjectModel> getProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _projects.firstWhere(
      (project) => project.id == id,
      orElse: () => throw Exception('Project not found'),
    );
  }

  @override
  Future<List<ProjectModel>> getProjectsByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _projects.where((project) => project.creatorId == userId).toList();
  }

  @override
  Future<ProjectModel> createProject(ProjectModel project) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _projects.add(project);
    return project;
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index == -1) {
      throw Exception('Project not found');
    }
    _projects[index] = project;
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _projects.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Project not found');
    }
    _projects.removeAt(index);
  }

  @override
  Future<void> addPostToProject(String projectId, String postId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final project = await getProject(projectId);
    if (!project.postIds.contains(postId)) {
      final updatedProject = project.copyWith(
        postIds: [...project.postIds, postId],
        updatedAt: DateTime.now(),
      );
      await updateProject(updatedProject);
    }
  }

  @override
  Future<void> removePostFromProject(String projectId, String postId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final project = await getProject(projectId);
    if (project.postIds.contains(postId)) {
      final updatedProject = project.copyWith(
        postIds: project.postIds.where((id) => id != postId).toList(),
        updatedAt: DateTime.now(),
      );
      await updateProject(updatedProject);
    }
  }

  @override
  Future<void> batchAddPostsToProject(String projectId, List<String> postIds) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final project = await getProject(projectId);
    final updatedPostIds = {...project.postIds, ...postIds}.toList();
    final updatedProject = project.copyWith(
      postIds: updatedPostIds,
      updatedAt: DateTime.now(),
    );
    await updateProject(updatedProject);
  }

  @override
  Future<void> batchRemovePostsFromProject(String projectId, List<String> postIds) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final project = await getProject(projectId);
    final updatedPostIds = project.postIds.where((id) => !postIds.contains(id)).toList();
    final updatedProject = project.copyWith(
      postIds: updatedPostIds,
      updatedAt: DateTime.now(),
    );
    await updateProject(updatedProject);
  }

  @override
  Future<List<ProjectModel>> getSubProjects(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _projects.where((project) => project.parentId == projectId).toList();
  }

  @override
  Future<ProjectModel> addSubProject(String parentId, ProjectModel project) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get parent project
    final parentProject = await getProject(parentId);
    
    // Create new project with parent reference
    final newProject = project.copyWith(
      parentId: parentId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Update parent project's children list
    final updatedParent = parentProject.copyWith(
      childrenIds: [...parentProject.childrenIds, newProject.id],
      updatedAt: DateTime.now(),
    );
    
    // Save both projects
    _projects.add(newProject);
    await updateProject(updatedParent);
    
    return newProject;
  }

  @override
  Future<void> removeSubProject(String parentId, String childId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get both projects
    final parentProject = await getProject(parentId);
    final childProject = await getProject(childId);
    
    // Verify parent-child relationship
    if (childProject.parentId != parentId) {
      throw Exception('Invalid parent-child relationship');
    }
    
    // Update parent's children list
    final updatedParent = parentProject.copyWith(
      childrenIds: parentProject.childrenIds.where((id) => id != childId).toList(),
      updatedAt: DateTime.now(),
    );
    
    // Remove child project's parent reference
    final updatedChild = childProject.copyWith(
      parentId: null,
      updatedAt: DateTime.now(),
    );
    
    // Save changes
    await updateProject(updatedParent);
    await updateProject(updatedChild);
  }

  @override
  Future<void> batchAddSubProjects(String parentId, List<String> projectIds) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get parent project
    final parentProject = await getProject(parentId);
    
    // Get all projects to add
    final projectsToAdd = await Future.wait(
      projectIds.map((id) => getProject(id))
    );
    
    // Update parent's children list
    final updatedParent = parentProject.copyWith(
      childrenIds: {...parentProject.childrenIds, ...projectIds}.toList(),
      updatedAt: DateTime.now(),
    );
    
    // Update each child project's parent reference
    final updatedChildren = projectsToAdd.map((project) => project.copyWith(
      parentId: parentId,
      updatedAt: DateTime.now(),
    ));
    
    // Save all changes
    await updateProject(updatedParent);
    for (final child in updatedChildren) {
      await updateProject(child);
    }
  }

  @override
  Future<void> batchRemoveSubProjects(String parentId, List<String> projectIds) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Get parent project
    final parentProject = await getProject(parentId);
    
    // Get all projects to remove
    final projectsToRemove = await Future.wait(
      projectIds.map((id) => getProject(id))
    );
    
    // Verify all projects are children of the parent
    for (final project in projectsToRemove) {
      if (project.parentId != parentId) {
        throw Exception('Invalid parent-child relationship');
      }
    }
    
    // Update parent's children list
    final updatedParent = parentProject.copyWith(
      childrenIds: parentProject.childrenIds
          .where((id) => !projectIds.contains(id))
          .toList(),
      updatedAt: DateTime.now(),
    );
    
    // Remove parent reference from each child project
    final updatedChildren = projectsToRemove.map((project) => project.copyWith(
      parentId: null,
      updatedAt: DateTime.now(),
    ));
    
    // Save all changes
    await updateProject(updatedParent);
    for (final child in updatedChildren) {
      await updateProject(child);
    }
  }

  @override
  Future<ProjectModel?> getParentProject(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final project = await getProject(projectId);
    if (project.parentId == null) return null;
    return getProject(project.parentId!);
  }
}
