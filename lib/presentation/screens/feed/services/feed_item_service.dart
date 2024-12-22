import '../../../../data/models/post_model.dart';
import '../../../../data/models/project_model.dart';

class FeedItemService {
  final List<PostModel> posts;
  final List<ProjectModel> projects;
  final bool isCreatingPost;

  const FeedItemService({
    required this.posts,
    required this.projects,
    this.isCreatingPost = false,
  });

  int get totalItemCount {
    int count = 1; // Always include space for post creation
    count += posts.length;
    if (projects.isNotEmpty) {
      count += 1; // First project
      count += ((posts.length - 1) / 5).floor(); // Additional projects
    }
    return count;
  }

  bool isProjectPosition(int adjustedIndex) {
    if (projects.isEmpty) return false;
    if (adjustedIndex == 0) return true; // First project after post creation
    return projects.length > 1 &&
        adjustedIndex > 1 &&
        ((adjustedIndex - 1) % 6 == 5); // Every 6th position after first project
  }

  int getProjectIndex(int adjustedIndex) {
    if (adjustedIndex == 0) return 0;
    return (((adjustedIndex - 1) - 5) ~/ 6 + 1) % projects.length;
  }

  int getPostIndex(int adjustedIndex) {
    return adjustedIndex - ((adjustedIndex) ~/ 6);
  }

  bool isValidPostIndex(int postIndex) {
    return postIndex < posts.length;
  }

  bool isCreatingPostPosition(int index) {
    return index == 0; // Post creation is always at index 0
  }

  ProjectModel? getProjectAtPosition(int adjustedIndex) {
    if (!isProjectPosition(adjustedIndex)) return null;
    final projectIndex = getProjectIndex(adjustedIndex);
    return projectIndex < projects.length ? projects[projectIndex] : null;
  }

  PostModel? getPostAtPosition(int adjustedIndex) {
    if (isProjectPosition(adjustedIndex)) return null;
    final postIndex = getPostIndex(adjustedIndex);
    return isValidPostIndex(postIndex) ? posts[postIndex] : null;
  }

  // Helper method to find the feed position for a specific post
  int? getFeedPositionForPost(String postId) {
    // First find the post in the raw list
    final rawIndex = posts.indexWhere((p) => p.id == postId);
    if (rawIndex == -1) return null;

    // Start with linear search since it's most reliable
    for (int i = 0; i < totalItemCount; i++) {
      // Skip project positions and creating post position
      if (isCreatingPostPosition(i) || isProjectPosition(i)) {
        continue;
      }
      
      final post = getPostAtPosition(i);
      if (post?.id == postId) {
        return i;
      }
    }
    
    return null;
  }
}
