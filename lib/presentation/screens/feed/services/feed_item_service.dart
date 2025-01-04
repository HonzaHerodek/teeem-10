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
      if (isCreatingPost) {
        // Show remaining projects in editing mode
        count += projects.length - (((posts.length - 1) / 5).floor() + 1);
      }
    }
    return count;
  }

  bool isProjectPosition(int adjustedIndex) {
    if (projects.isEmpty) return false;
    
    // First project always shows after post creation
    if (adjustedIndex == 0) return true;
    
    // In editing mode, show remaining projects after the regular feed
    if (isCreatingPost && adjustedIndex >= posts.length + 1) {
      return true;
    }
    
    // In normal mode, show projects every 6th position
    return projects.length > 1 &&
        adjustedIndex > 1 &&
        ((adjustedIndex - 1) % 6 == 5);
  }

  int getProjectIndex(int adjustedIndex) {
    if (projects.isEmpty) return -1;
    
    // First project
    if (adjustedIndex == 0) return 0;
    
    if (isCreatingPost && adjustedIndex >= posts.length + 1) {
      // For editing mode, calculate index for remaining projects
      int regularProjectCount = ((posts.length - 1) / 5).floor() + 1;
      int extraIndex = (adjustedIndex - posts.length - 1);
      return regularProjectCount + extraIndex;
    }
    
    // Regular project positions (every 6th)
    if (adjustedIndex > 1) {
      return (((adjustedIndex - 1) - 5) ~/ 6) + 1;
    }
    
    return -1;
  }

  int getPostIndex(int adjustedIndex) {
    if (isProjectPosition(adjustedIndex)) return -1;
    
    if (projects.isEmpty) return adjustedIndex;
    
    // If there are projects, adjust for project positions
    int projectCount = (adjustedIndex > 0) ? ((adjustedIndex - 1) ~/ 6) + 1 : 0;
    return adjustedIndex - projectCount;
  }

  bool isValidPostIndex(int postIndex) {
    return postIndex >= 0 && postIndex < posts.length;
  }

  bool isCreatingPostPosition(int index) {
    return index == 0; // Post creation is always at index 0
  }

  ProjectModel? getProjectAtPosition(int adjustedIndex) {
    if (!isProjectPosition(adjustedIndex) || projects.isEmpty) return null;
    final projectIndex = getProjectIndex(adjustedIndex);
    return projectIndex >= 0 && projectIndex < projects.length ? projects[projectIndex] : null;
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
