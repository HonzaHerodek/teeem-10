import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/project_model.dart';
import '../../../../data/models/targeting_model.dart';
import '../../../../domain/repositories/post_repository.dart';
import '../../../../domain/repositories/project_repository.dart';

class PostCreationManager {
  final PostRepository _postRepository;
  final ProjectRepository _projectRepository;

  PostCreationManager({
    PostRepository? postRepository,
    ProjectRepository? projectRepository,
  })  : _postRepository = postRepository ?? getIt<PostRepository>(),
        _projectRepository = projectRepository ?? getIt<ProjectRepository>();

  Future<void> savePost({
    required PostModel post,
    required ProjectModel? selectedProject,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // Create the post
      await _postRepository.createPost(post);

      // If a project is selected, add the post to it
      if (selectedProject != null) {
        await _projectRepository.addPostToProject(selectedProject.id, post.id);
      }

      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<List<ProjectModel>> loadUserProjects(String userId) async {
    return await _projectRepository.getProjectsByUser(userId);
  }

  Future<void> createProject(ProjectModel project) async {
    await _projectRepository.createProject(project);
  }

  PostModel createPostModel({
    required String userId,
    required String? username,
    required String title,
    required String description,
    required List<PostStep> steps,
    required TargetingCriteria? targetingCriteria,
  }) {
    return PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      username: username ?? 'Anonymous',
      userProfileImage: 'https://i.pravatar.cc/150?u=$userId',
      title: title,
      description: description,
      steps: steps,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      likes: [],
      comments: [],
      status: PostStatus.active,
      targetingCriteria: targetingCriteria,
      aiMetadata: {
        'tags': ['tutorial', 'multi-step'],
        'category': 'tutorial',
      },
      ratings: [],
      userTraits: [],
    );
  }
}
