import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/project_model.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../screens/feed/feed_bloc/feed_bloc.dart';
import '../../screens/feed/feed_bloc/feed_event.dart';

class ProjectPostSelectionService extends ChangeNotifier {
  final PostRepository _postRepository;
  final String projectId;
  final String projectName;
  List<String> _currentPostIds;

  List<PostModel> _projectPosts = [];
  List<PostModel> _availablePosts = [];
  List<ProjectModel> _subProjects = [];
  final Set<String> _selectedPostIds = {};
  final Set<String> _selectedProjectIds = {};
  bool _isLoading = true;
  bool _isSelectionMode = false;
  String _errorMessage = '';

  ProjectPostSelectionService({
    required PostRepository postRepository,
    required this.projectId,
    required this.projectName,
    required List<String> initialPostIds,
  })  : _postRepository = postRepository,
        _currentPostIds = List.from(initialPostIds) {
    _fetchProjectPosts();
  }

  // Getters
  List<PostModel> get projectPosts => List.unmodifiable(_projectPosts);
  List<PostModel> get availablePosts => List.unmodifiable(_availablePosts);
  List<ProjectModel> get subProjects => List.unmodifiable(_subProjects);
  Set<String> get selectedPostIds => Set.unmodifiable(_selectedPostIds);
  Set<String> get selectedProjectIds => Set.unmodifiable(_selectedProjectIds);
  bool get isLoading => _isLoading;
  bool get isSelectionMode => _isSelectionMode;
  String get errorMessage => _errorMessage;

  // Project list getters
  List<ProjectModel> get currentSubProjects => _subProjects
      .where((p) => p.parentId == projectId)
      .toList();

  List<ProjectModel> get availableProjects => _subProjects
      .where((p) => p.parentId == null && !currentSubProjects.contains(p)) // Only show projects without a parent that aren't already sub-projects
      .toList();

  Future<void> _fetchProjectPosts() async {
    if (_currentPostIds.isEmpty) {
      _isLoading = false;
      _projectPosts = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final posts = await Future.wait(
        _currentPostIds
            .map((id) => _postRepository.getPostById(id).catchError((Object e) {
                  print('Error fetching post $id: $e');
                  // Skip posts that fail to load by filtering them out later
                  return Future<PostModel?>.value(null);
                })),
      );

      _projectPosts = posts.whereType<PostModel>().toList();
      _isLoading = false;
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      print('Unexpected error: $e');
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      _projectPosts = [];
      notifyListeners();
    }
  }

  void togglePostSelection(String postId) {
    if (_selectedPostIds.contains(postId)) {
      _selectedPostIds.remove(postId);
    } else {
      _selectedPostIds.add(postId);
    }
    notifyListeners();
  }

  void enterSelectionMode(
      List<PostModel> feedPosts, List<ProjectModel> projects) {
    _isSelectionMode = true;

    // Get available posts (posts not in current project)
    _availablePosts =
        feedPosts.where((post) => !_currentPostIds.contains(post.id)).toList();

    // Get all projects except self
    _subProjects = projects
        .where((p) => p.id != projectId) // Exclude self
        .toList();

    // Sort projects to maintain order: current sub-projects first, then available projects
    _subProjects.sort((a, b) {
      final aIsSubProject = a.parentId == projectId;
      final bIsSubProject = b.parentId == projectId;
      if (aIsSubProject == bIsSubProject) return 0;
      return aIsSubProject ? -1 : 1;
    });

    _selectedPostIds.clear();
    _selectedProjectIds.clear();
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedPostIds.clear();
    _selectedProjectIds.clear();
    _availablePosts = [];
    _subProjects = [];
    notifyListeners();
  }

  void toggleProjectSelection(String projectId) {
    if (_selectedProjectIds.contains(projectId)) {
      _selectedProjectIds.remove(projectId);
    } else {
      _selectedProjectIds.add(projectId);
    }
    notifyListeners();
  }

  void handleSelectionConfirmed(BuildContext context) {
    if (_selectedPostIds.isEmpty && _selectedProjectIds.isEmpty) {
      exitSelectionMode();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes made'),
          backgroundColor: Colors.grey,
        ),
      );
      return;
    }

    // Handle post transfers
    if (_selectedPostIds.isNotEmpty) {
      final projectPostIds = _projectPosts.map((p) => p.id).toSet();
      final selectedProjectPosts =
          _selectedPostIds.where((id) => projectPostIds.contains(id)).toList();
      final selectedAvailablePosts =
          _selectedPostIds.where((id) => !projectPostIds.contains(id)).toList();

      if (selectedProjectPosts.isNotEmpty ||
          selectedAvailablePosts.isNotEmpty) {
        context.read<FeedBloc>().add(
              FeedBatchOperations(
                projectId: projectId,
                postsToRemove: selectedProjectPosts,
                postsToAdd: selectedAvailablePosts,
              ),
            );

        // Update local state
        _currentPostIds = _currentPostIds
            .where((id) => !selectedProjectPosts.contains(id))
            .toList()
          ..addAll(selectedAvailablePosts);
      }
    }

    // Handle project transfers
    if (_selectedProjectIds.isNotEmpty) {
      // Find the selected projects
      final selectedProjects = _subProjects
          .where((p) => _selectedProjectIds.contains(p.id))
          .toList();

      // Projects selected in "Project items" (parentId == projectId) should be removed
      final projectsToRemove = selectedProjects
          .where((p) => p.parentId == projectId)
          .map((p) => p.id)
          .toList();

      // Projects selected in "Available items" (parentId == null) should be added
      final projectsToAdd = selectedProjects
          .where((p) => p.parentId == null)
          .map((p) => p.id)
          .toList();

      // Send a single event to handle both operations
      if (projectsToAdd.isNotEmpty || projectsToRemove.isNotEmpty) {
        context.read<FeedBloc>().add(
          FeedProjectTransfer(
            fromProjectId: projectId,
            projectsToAdd: projectsToAdd,
            projectsToRemove: projectsToRemove,
          ),
        );
      }
    }

    // Build success message
    final addedPostsCount = _selectedPostIds
        .where((id) => !_projectPosts.any((p) => p.id == id))
        .length;
    final removedPostsCount = _selectedPostIds
        .where((id) => _projectPosts.any((p) => p.id == id))
        .length;
    final addedProjectsCount = _selectedProjectIds
        .where((id) => _subProjects.any((p) => p.parentId == null))
        .length;
    final removedProjectsCount = _selectedProjectIds
        .where((id) => _subProjects.any((p) => p.parentId == projectId))
        .length;

    List<String> messageParts = [];
    if (addedPostsCount > 0) messageParts.add('$addedPostsCount posts added');
    if (removedPostsCount > 0)
      messageParts.add('$removedPostsCount posts removed');
    if (addedProjectsCount > 0)
      messageParts.add('$addedProjectsCount projects added');
    if (removedProjectsCount > 0)
      messageParts.add('$removedProjectsCount projects removed');

    final message = messageParts.join(', ') + ' in $projectName';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );

    // Refresh the feed to ensure all changes are reflected
    context.read<FeedBloc>().add(const FeedRefreshed());
    
    exitSelectionMode();
  }

  void updateProjectPosts(List<PostModel> posts) {
    _projectPosts = List.from(posts);
    notifyListeners();
  }

  void refreshPosts() {
    _fetchProjectPosts();
  }

  void updatePostIds(List<String> newPostIds) {
    _currentPostIds = List.from(newPostIds);
    _fetchProjectPosts();
  }

  void updateSubProjects(List<ProjectModel> projects) {
    // Update sub-projects list while maintaining selection mode if active
    if (_isSelectionMode) {
      // Keep only valid selections (projects that are still available or sub-projects)
      _selectedProjectIds.removeWhere((id) => !projects.any((p) => p.id == id));

      // Update projects list - include all projects except self
      _subProjects = projects
          .where((p) => p.id != projectId) // Exclude self
          .toList();

      // Sort projects to maintain order: current sub-projects first, then available projects
      _subProjects.sort((a, b) {
        final aIsSubProject = a.parentId == projectId;
        final bIsSubProject = b.parentId == projectId;
        if (aIsSubProject == bIsSubProject) return 0;
        return aIsSubProject ? -1 : 1;
      });
    } else {
      _subProjects = [];
    }
    notifyListeners();
  }
}
