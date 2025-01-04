import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/project_model.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../screens/feed/feed_bloc/feed_bloc.dart';
import '../../screens/feed/feed_bloc/feed_event.dart';

class ProjectContentSelectionService extends ChangeNotifier {
  final PostRepository _postRepository;
  final String projectId;
  final String projectName;
  List<String> _currentPostIds;
  List<String> _currentProjectIds;

  List<PostModel> _projectPosts = [];
  List<PostModel> _availablePosts = [];
  List<ProjectModel> _availableProjects = [];
  final Set<String> _selectedPostIds = {};
  final Set<String> _selectedProjectIds = {};
  bool _isLoading = true;
  bool _isSelectionMode = false;
  String _errorMessage = '';

  ProjectContentSelectionService({
    required PostRepository postRepository,
    required this.projectId,
    required this.projectName,
    required List<String> initialPostIds,
    required List<String> initialProjectIds,
  }) : _postRepository = postRepository,
      _currentPostIds = List.from(initialPostIds),
      _currentProjectIds = List.from(initialProjectIds) {
    _fetchProjectPosts();
  }

  // Getters
  List<PostModel> get projectPosts => List.unmodifiable(_projectPosts);
  List<PostModel> get availablePosts => List.unmodifiable(_availablePosts);
  List<ProjectModel> get availableProjects => List.unmodifiable(_availableProjects);
  Set<String> get selectedPostIds => Set.unmodifiable(_selectedPostIds);
  Set<String> get selectedProjectIds => Set.unmodifiable(_selectedProjectIds);
  bool get isLoading => _isLoading;
  bool get isSelectionMode => _isSelectionMode;
  String get errorMessage => _errorMessage;

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
        _currentPostIds.map((id) => _postRepository.getPostById(id).catchError((Object e) {
          print('Error fetching post $id: $e');
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

  void toggleProjectSelection(String projectId) {
    if (_selectedProjectIds.contains(projectId)) {
      _selectedProjectIds.remove(projectId);
    } else {
      _selectedProjectIds.add(projectId);
    }
    notifyListeners();
  }

  void enterSelectionMode(List<PostModel> feedPosts, List<ProjectModel> allProjects) {
    _isSelectionMode = true;
    _availablePosts = feedPosts.where(
      (post) => !_currentPostIds.contains(post.id)
    ).toList();
    _availableProjects = allProjects.where(
      (project) => !_currentProjectIds.contains(project.id) && project.id != projectId
    ).toList();
    _selectedPostIds.clear();
    _selectedProjectIds.clear();
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedPostIds.clear();
    _selectedProjectIds.clear();
    _availablePosts = [];
    _availableProjects = [];
    notifyListeners();
  }

  void handleContentAdded(BuildContext context) {
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

    // Handle posts
    final projectPostIds = _projectPosts.map((p) => p.id).toSet();
    final selectedProjectPosts = _selectedPostIds
        .where((id) => projectPostIds.contains(id))
        .toList();
    final selectedAvailablePosts = _selectedPostIds
        .where((id) => !projectPostIds.contains(id))
        .toList();

    // Handle projects
    final selectedProjects = _selectedProjectIds.toList();

    // Send batch operation event
    if (selectedProjectPosts.isNotEmpty || selectedAvailablePosts.isNotEmpty || selectedProjects.isNotEmpty) {
      context.read<FeedBloc>().add(
        FeedBatchOperations(
          projectId: projectId,
          postsToRemove: selectedProjectPosts,
          postsToAdd: selectedAvailablePosts,
          projectsToAdd: selectedProjects,
        ),
      );

      // Update local state
      _currentPostIds = _currentPostIds
          .where((id) => !selectedProjectPosts.contains(id))
          .toList()
        ..addAll(selectedAvailablePosts);
      _currentProjectIds = [..._currentProjectIds, ...selectedProjects];
    }

    final addedPostsCount = selectedAvailablePosts.length;
    final removedPostsCount = selectedProjectPosts.length;
    final addedProjectsCount = selectedProjects.length;
    
    List<String> messageParts = [];
    if (removedPostsCount > 0) {
      messageParts.add('$removedPostsCount posts removed');
    }
    if (addedPostsCount > 0) {
      messageParts.add('$addedPostsCount posts added');
    }
    if (addedProjectsCount > 0) {
      messageParts.add('$addedProjectsCount projects added');
    }
    
    final message = '${messageParts.join(' and ')} to $projectName';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );

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

  void updateProjectIds(List<String> newProjectIds) {
    _currentProjectIds = List.from(newProjectIds);
    notifyListeners();
  }
}
