import '../../data/models/project_model.dart';

abstract class ProjectRepository {
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> getProject(String id);
  Future<List<ProjectModel>> getProjectsByUser(String userId);
  Future<ProjectModel> createProject(ProjectModel project);
  Future<void> updateProject(ProjectModel project);
  Future<void> deleteProject(String id);
  Future<void> addPostToProject(String projectId, String postId);
  Future<void> removePostFromProject(String projectId, String postId);
  Future<void> batchAddPostsToProject(String projectId, List<String> postIds);
  Future<void> batchRemovePostsFromProject(String projectId, List<String> postIds);
  
  // Parent-child relationship methods
  Future<void> addChildProject(String parentId, String childId);
  Future<void> removeChildProject(String parentId, String childId);
  Future<List<ProjectModel>> getChildProjects(String projectId);
  Future<List<ProjectModel>> getParentProjects(String projectId);
}
