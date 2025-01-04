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
      childProjectIds: ['3', '4'],
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
      name: 'sub-project 1',
      description: 'First sub-project of Photography Collection',
      creatorId: 'user1',
      postIds: [],
      parentProjectIds: ['1'],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
    ),
    ProjectModel(
      id: '4',
      name: 'sub-project 2',
      description: 'Second sub-project of Photography Collection',
      creatorId: 'user1',
      postIds: [],
      parentProjectIds: ['1'],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
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
  Future<void> addChildProject(String parentId, String childId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final parent = await getProject(parentId);
    final child = await getProject(childId);

    if (!parent.childProjectIds.contains(childId)) {
      final updatedParent = parent.copyWith(
        childProjectIds: [...parent.childProjectIds, childId],
        updatedAt: DateTime.now(),
      );
      await updateProject(updatedParent);
    }

    if (!child.parentProjectIds.contains(parentId)) {
      final updatedChild = child.copyWith(
        parentProjectIds: [...child.parentProjectIds, parentId],
        updatedAt: DateTime.now(),
      );
      await updateProject(updatedChild);
    }
  }

  @override
  Future<void> removeChildProject(String parentId, String childId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final parent = await getProject(parentId);
    final child = await getProject(childId);

    final updatedParent = parent.copyWith(
      childProjectIds: parent.childProjectIds.where((id) => id != childId).toList(),
      updatedAt: DateTime.now(),
    );
    await updateProject(updatedParent);

    final updatedChild = child.copyWith(
      parentProjectIds: child.parentProjectIds.where((id) => id != parentId).toList(),
      updatedAt: DateTime.now(),
    );
    await updateProject(updatedChild);
  }

  @override
  Future<List<ProjectModel>> getChildProjects(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final project = await getProject(projectId);
    return Future.wait(
      project.childProjectIds.map((id) => getProject(id)),
    );
  }

  @override
  Future<List<ProjectModel>> getParentProjects(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final project = await getProject(projectId);
    return Future.wait(
      project.parentProjectIds.map((id) => getProject(id)),
    );
  }
}
