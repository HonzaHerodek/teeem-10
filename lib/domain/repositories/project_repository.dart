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
  Future<List<ProjectModel>> getSubProjects(String projectId);
  Future<ProjectModel> addSubProject(String parentId, ProjectModel project);
  Future<void> removeSubProject(String parentId, String childId);
  Future<void> batchAddSubProjects(String parentId, List<String> projectIds);
  Future<void> batchRemoveSubProjects(String parentId, List<String> projectIds);
  Future<ProjectModel?> getParentProject(String projectId);
}
