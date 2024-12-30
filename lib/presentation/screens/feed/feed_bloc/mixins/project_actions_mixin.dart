import 'package:bloc/bloc.dart';
import 'package:myapp/data/models/project_model.dart';
import 'package:myapp/domain/repositories/project_repository.dart';
import '../../feed_bloc/feed_state.dart';
import '../../feed_bloc/feed_event.dart';

mixin ProjectActionsMixin on Bloc<FeedEvent, FeedState> {
  Future<void> handleProjectSelection(
    String projectId,
    ProjectRepository projectRepository,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedSuccess) return;
    
    final currentState = state as FeedSuccess;
    try {
      final project = await projectRepository.getProject(projectId);
      
      emit(FeedSuccess(
        posts: currentState.posts,
        projects: currentState.projects,
        currentUserId: currentState.currentUserId,
        selectedProjectId: projectId,
      ));
    } catch (e) {
      emit(FeedFailure(error: e.toString()));
    }
  }

  Future<void> handleAddPostToProject(
    String projectId,
    String postId,
    ProjectRepository projectRepository,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedSuccess) return;

    final currentState = state as FeedSuccess;
    try {
      await projectRepository.addPostToProject(projectId, postId);
      final updatedProjects = await projectRepository.getProjects();

      emit(FeedSuccess(
        posts: currentState.posts,
        projects: updatedProjects,
        currentUserId: currentState.currentUserId,
        selectedProjectId: currentState.selectedProjectId,
      ));
    } catch (e) {
      emit(FeedFailure(error: e.toString()));
    }
  }

  Future<void> handleRemovePostFromProject(
    String projectId,
    String postId,
    ProjectRepository projectRepository,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedSuccess) return;

    final currentState = state as FeedSuccess;
    try {
      await projectRepository.removePostFromProject(projectId, postId);
      final updatedProjects = await projectRepository.getProjects();

      emit(FeedSuccess(
        posts: currentState.posts,
        projects: updatedProjects,
        currentUserId: currentState.currentUserId,
        selectedProjectId: currentState.selectedProjectId,
      ));
    } catch (e) {
      emit(FeedFailure(error: e.toString()));
    }
  }

  Future<void> handleBatchAddPostsToProject(
    String projectId,
    List<String> postIds,
    ProjectRepository projectRepository,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedSuccess) return;

    final currentState = state as FeedSuccess;
    try {
      // Get current project state
      final project = await projectRepository.getProject(projectId);
      
      // Add the new posts
      await projectRepository.batchAddPostsToProject(projectId, postIds);
      
      // Get updated projects
      final updatedProjects = await projectRepository.getProjects();

      emit(FeedSuccess(
        posts: currentState.posts,
        projects: updatedProjects,
        currentUserId: currentState.currentUserId,
        selectedProjectId: currentState.selectedProjectId,
      ));
    } catch (e) {
      emit(FeedFailure(error: e.toString()));
    }
  }

  Future<void> handleBatchRemovePostsFromProject(
    String projectId,
    List<String> postIds,
    ProjectRepository projectRepository,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedSuccess) return;

    final currentState = state as FeedSuccess;
    try {
      // Get current project state
      final project = await projectRepository.getProject(projectId);
      
      // Remove the posts
      await projectRepository.batchRemovePostsFromProject(projectId, postIds);
      
      // Get updated projects
      final updatedProjects = await projectRepository.getProjects();

      emit(FeedSuccess(
        posts: currentState.posts,
        projects: updatedProjects,
        currentUserId: currentState.currentUserId,
        selectedProjectId: currentState.selectedProjectId,
      ));
    } catch (e) {
      emit(FeedFailure(error: e.toString()));
    }
  }

  Future<void> handleSubProjectCreation(
    String parentId,
    ProjectModel newProject,
    ProjectRepository projectRepository,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedSuccess) return;

    final currentState = state as FeedSuccess;
    try {
      // Create the sub-project
      await projectRepository.addSubProject(parentId, newProject);
      
      // Get updated projects list
      final updatedProjects = await projectRepository.getProjects();

      emit(FeedSuccess(
        posts: currentState.posts,
        projects: updatedProjects,
        currentUserId: currentState.currentUserId,
        selectedProjectId: currentState.selectedProjectId,
      ));
    } catch (e) {
      emit(FeedFailure(error: e.toString()));
    }
  }

  Future<void> handleBatchOperations(
    String projectId,
    List<String> postsToRemove,
    List<String> postsToAdd,
    ProjectRepository projectRepository,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedSuccess) return;

    final currentState = state as FeedSuccess;
    try {
      // Get current project state
      final project = await projectRepository.getProject(projectId);
      
      // First remove posts
      if (postsToRemove.isNotEmpty) {
        await projectRepository.batchRemovePostsFromProject(projectId, postsToRemove);
      }
      
      // Then add posts
      if (postsToAdd.isNotEmpty) {
        await projectRepository.batchAddPostsToProject(projectId, postsToAdd);
      }
      
      // Get final updated state
      final updatedProjects = await projectRepository.getProjects();

      emit(FeedSuccess(
        posts: currentState.posts,
        projects: updatedProjects,
        currentUserId: currentState.currentUserId,
        selectedProjectId: currentState.selectedProjectId,
      ));
    } catch (e) {
      emit(FeedFailure(error: e.toString()));
    }
  }
}
