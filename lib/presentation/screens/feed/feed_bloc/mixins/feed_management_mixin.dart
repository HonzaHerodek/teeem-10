import 'package:bloc/bloc.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'package:myapp/domain/repositories/post_repository.dart';
import 'package:myapp/domain/repositories/project_repository.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/data/models/post_model.dart';
import 'package:myapp/data/models/project_model.dart';
import '../../services/filter_service.dart';
import '../feed_state.dart';
import '../feed_event.dart';

mixin FeedManagementMixin on Bloc<FeedEvent, FeedState> {
  // Minimum duration to show loading state to prevent flicker
  static const _minimumLoadingDuration = Duration(milliseconds: 1500);
  static const _timeoutDuration = Duration(seconds: 15);
  
  ConnectivityService? _connectivityService;
  bool _isLoading = false;

  Future<void> _ensureConnectivity() async {
    if (isClosed) return;
    
    try {
      if (_connectivityService == null) {
        _connectivityService = ConnectivityService();
        await _connectivityService!.initialize();
      }
      
      if (!_connectivityService!.isOnline) {
        if (_connectivityService != null) {
          _connectivityService!.dispose();
          _connectivityService = null;
        }
        throw Exception('No internet connection');
      }
    } catch (e) {
      if (_connectivityService != null) {
        _connectivityService!.dispose();
        _connectivityService = null;
      }
      throw Exception('Connection check failed: ${e.toString()}');
    }
  }

  Future<void> loadFeed({
    required AuthRepository authRepository,
    required PostRepository postRepository,
    required ProjectRepository projectRepository,
    required FilterService filterService,
    required Emitter<FeedState> emit,
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async {
    // Prevent multiple concurrent loads except for load more
    if (_isLoading && !isLoadMore || isClosed) return;
    _isLoading = true;

    // Start loading timer immediately
    final loadingTimer = Future.delayed(_minimumLoadingDuration);
    
    try {
      // Check connectivity first
      await _ensureConnectivity();
      if (isClosed) return;

      // Get current user with timeout
      final currentUser = await authRepository.getCurrentUser()
        .timeout(_timeoutDuration,
          onTimeout: () => throw Exception('Failed to get user: timeout'));
      
      if (isClosed) return;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get posts and projects with timeout and error handling
      List<PostModel> posts;
      List<ProjectModel> projects;
      
      try {
        final results = await Future.wait([
          postRepository.getPosts()
            .timeout(_timeoutDuration,
              onTimeout: () => throw Exception('Failed to load posts: timeout')),
          projectRepository.getProjects()
            .timeout(_timeoutDuration,
              onTimeout: () => throw Exception('Failed to load projects: timeout')),
        ]);
        
        if (isClosed) return;
        
        posts = results[0] as List<PostModel>;
        projects = results[1] as List<ProjectModel>;
      } catch (e) {
        throw Exception('Failed to load feed data: ${e.toString()}');
      }

      // Filter posts safely
      List<PostModel> filteredPosts;
      try {
        filteredPosts = filterService.filterPosts(posts, currentUser);
      } catch (e) {
        throw Exception('Failed to filter posts: ${e.toString()}');
      }

      // Wait for minimum loading time to complete
      await loadingTimer;

      // Only emit new state if bloc is still active and we're still loading
      if (!isClosed && _isLoading) {
        if (isLoadMore && state is FeedSuccess) {
          final currentState = state as FeedSuccess;
          emit(FeedSuccess(
            posts: [...currentState.posts, ...filteredPosts],
            projects: projects,
            currentUserId: currentUser.id,
            selectedProjectId: currentState.selectedProjectId,
          ));
        } else {
          emit(FeedSuccess(
            posts: filteredPosts,
            projects: projects,
            currentUserId: currentUser.id,
            selectedProjectId: state is FeedSuccess 
              ? (state as FeedSuccess).selectedProjectId 
              : null,
          ));
        }
      }
    } catch (e) {
      // Ensure minimum loading time even on error
      await loadingTimer;
      
      // Only emit error if bloc is still active and we're still loading
      if (!isClosed && _isLoading) {
        emit(FeedFailure(error: e.toString()));
      }
    } finally {
      _isLoading = false;
      // Clean up connectivity service if not needed
      if (!isClosed && state is! FeedLoading) {
        if (_connectivityService != null) {
          _connectivityService!.dispose();
          _connectivityService = null;
        }
      }
    }
  }

  Future<void> handleFeedStart({
    required AuthRepository authRepository,
    required PostRepository postRepository,
    required ProjectRepository projectRepository,
    required FilterService filterService,
    required Emitter<FeedState> emit,
  }) async {
    if (!isClosed) {
      emit(const FeedLoading());
      await loadFeed(
        authRepository: authRepository,
        postRepository: postRepository,
        projectRepository: projectRepository,
        filterService: filterService,
        emit: emit,
      );
    }
  }

  Future<void> handleFeedRefresh({
    required AuthRepository authRepository,
    required PostRepository postRepository,
    required ProjectRepository projectRepository,
    required FilterService filterService,
    required Emitter<FeedState> emit,
  }) async {
    if (!isClosed && state is! FeedSuccess) {
      emit(const FeedLoading());
    }
    await loadFeed(
      authRepository: authRepository,
      postRepository: postRepository,
      projectRepository: projectRepository,
      filterService: filterService,
      emit: emit,
      isRefresh: true,
    );
  }

  Future<void> handleFeedLoadMore({
    required AuthRepository authRepository,
    required PostRepository postRepository,
    required ProjectRepository projectRepository,
    required FilterService filterService,
    required Emitter<FeedState> emit,
  }) async {
    if (!isClosed && state is FeedSuccess) {
      final currentState = state as FeedSuccess;
      emit(FeedLoadingMore(
        posts: currentState.posts,
        projects: currentState.projects,
      ));
      
      await loadFeed(
        authRepository: authRepository,
        postRepository: postRepository,
        projectRepository: projectRepository,
        filterService: filterService,
        emit: emit,
        isLoadMore: true,
      );
    }
  }
}
