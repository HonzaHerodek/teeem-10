import 'package:bloc/bloc.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'package:myapp/domain/repositories/post_repository.dart';
import 'package:myapp/domain/repositories/project_repository.dart';
import 'package:myapp/core/services/rating_service.dart';
import '../models/filter_type.dart';
import '../services/filter_service.dart';
import 'feed_event.dart';
import 'feed_state.dart';
import 'mixins/post_actions_mixin.dart';
import 'mixins/project_actions_mixin.dart';
import 'mixins/feed_management_mixin.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> 
    with PostActionsMixin, ProjectActionsMixin, FeedManagementMixin {
  final PostRepository _postRepository;
  final ProjectRepository _projectRepository;
  final FilterService _filterService;
  final RatingService _ratingService;
  final AuthRepository _authRepository;

  FeedBloc({
    required PostRepository postRepository,
    required ProjectRepository projectRepository,
    required AuthRepository authRepository,
    required FilterService filterService,
    required RatingService ratingService,
  })  : _postRepository = postRepository,
        _projectRepository = projectRepository,
        _filterService = filterService,
        _ratingService = ratingService,
        _authRepository = authRepository,
        super(const FeedInitial()) {
    // Feed management
    on<FeedStarted>((event, emit) => handleFeedStart(
      authRepository: _authRepository,
      postRepository: _postRepository,
      projectRepository: _projectRepository,
      filterService: _filterService,
      emit: emit,
    ));
    on<FeedRefreshed>((event, emit) => handleFeedRefresh(
      authRepository: _authRepository,
      postRepository: _postRepository,
      projectRepository: _projectRepository,
      filterService: _filterService,
      emit: emit,
    ));
    on<FeedLoadMore>((event, emit) => handleFeedLoadMore(
      authRepository: _authRepository,
      postRepository: _postRepository,
      projectRepository: _projectRepository,
      filterService: _filterService,
      emit: emit,
    ));
    
    // Post actions
    on<FeedPostLiked>((event, emit) => 
      handlePostAction(event.postId, 
        () => _postRepository.likePost(event.postId, (state as FeedSuccess).currentUserId),
        _postRepository, emit));
    on<FeedPostUnliked>((event, emit) => 
      handlePostAction(event.postId,
        () => _postRepository.unlikePost(event.postId, (state as FeedSuccess).currentUserId),
        _postRepository, emit));
    on<FeedPostDeleted>((event, emit) => 
      handlePostDeletion(event.postId, _postRepository, emit));
    on<FeedPostHidden>((event, emit) => 
      handlePostAction(event.postId,
        () => _postRepository.hidePost(event.postId, (state as FeedSuccess).currentUserId),
        _postRepository, emit));
    on<FeedPostSaved>((event, emit) => 
      handlePostAction(event.postId,
        () => _postRepository.savePost(event.postId, (state as FeedSuccess).currentUserId),
        _postRepository, emit));
    on<FeedPostUnsaved>((event, emit) => 
      handlePostAction(event.postId,
        () => _postRepository.unsavePost(event.postId, (state as FeedSuccess).currentUserId),
        _postRepository, emit));
    on<FeedPostReported>((event, emit) => 
      handlePostAction(event.postId,
        () => _postRepository.reportPost(event.postId, (state as FeedSuccess).currentUserId, event.reason),
        _postRepository, emit));
    on<FeedPostRated>((event, emit) => 
      handlePostRating(event.postId, event.rating, _ratingService, _postRepository, emit));
    
    // Project actions
    on<FeedProjectSelected>((event, emit) => 
      handleProjectSelection(event.projectId, _projectRepository, emit));
    on<FeedPostAddedToProject>((event, emit) => 
      handleAddPostToProject(event.projectId, event.postId, _projectRepository, emit));
    on<FeedRemovePostFromProject>((event, emit) => 
      handleRemovePostFromProject(event.projectId, event.postId, _projectRepository, emit));
    on<FeedBatchAddPostsToProject>((event, emit) =>
      handleBatchAddPostsToProject(event.projectId, event.postIds, _projectRepository, emit));
    on<FeedBatchRemovePostsFromProject>((event, emit) =>
      handleBatchRemovePostsFromProject(event.projectId, event.postIds, _projectRepository, emit));
    on<FeedBatchOperations>((event, emit) =>
      handleBatchOperations(
        event.projectId,
        event.postsToRemove,
        event.postsToAdd,
        _projectRepository,
        emit,
      ));
    
    // Sub-project operations
    on<FeedSubProjectCreated>((event, emit) =>
      handleSubProjectCreation(
        event.parentId,
        event.project,
        _projectRepository,
        emit,
      ));
    on<FeedProjectTransfer>((event, emit) =>
      handleProjectTransfer(
        event.fromProjectId,
        event.projectsToRemove,
        event.projectsToAdd,
        _projectRepository,
        emit,
      ));
    
    // Filtering
    on<FeedFilterChanged>(_onFilterChanged);
    on<FeedSearchChanged>(_onSearchChanged);
  }

  void _onFilterChanged(FeedFilterChanged event, Emitter<FeedState> emit) async {
    if (state is! FeedSuccess) return;
    
    final currentState = state as FeedSuccess;
    try {
      // Convert string filter type to enum
      final filterType = FilterType.values.firstWhere(
        (type) => type.toString().split('.').last.toLowerCase() == event.filterType.toLowerCase(),
        orElse: () => FilterType.none,
      );
      
      _filterService.setFilter(filterType);
      if (event.filter.isNotEmpty) {
        _filterService.setSearchQuery(event.filter);
      }
      
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) throw Exception('User not authenticated');
      
      final filteredPosts = _filterService.filterPosts(currentState.posts, currentUser);
      
      emit(FeedSuccess(
        posts: filteredPosts,
        projects: currentState.projects,
        currentUserId: currentState.currentUserId,
        selectedProjectId: currentState.selectedProjectId,
      ));
    } catch (e) {
      emit(FeedFailure(error: e.toString()));
    }
  }

  void _onSearchChanged(FeedSearchChanged event, Emitter<FeedState> emit) async {
    if (state is! FeedSuccess) return;
    
    final currentState = state as FeedSuccess;
    try {
      _filterService.setSearchQuery(event.query);
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) throw Exception('User not authenticated');
      
      final filteredPosts = _filterService.filterPosts(currentState.posts, currentUser);
      
      emit(FeedSuccess(
        posts: filteredPosts,
        projects: currentState.projects,
        currentUserId: currentState.currentUserId,
        selectedProjectId: currentState.selectedProjectId,
      ));
    } catch (e) {
      emit(FeedFailure(error: e.toString()));
    }
  }
}
