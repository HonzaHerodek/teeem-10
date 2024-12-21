import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../feed_bloc/feed_bloc.dart';
import '../feed_bloc/feed_event.dart';
import '../feed_bloc/feed_state.dart';
import '../services/feed_position_tracker.dart';
import '../services/feed_item_service.dart';

class FeedController extends ChangeNotifier {
  final FeedBloc feedBloc;
  final FeedPositionTracker positionTracker;
  final BuildContext context;
  late FeedItemService _itemService;
  FeedItemService get itemService => _itemService;

  FeedController({
    required this.feedBloc,
    required this.positionTracker,
    required this.context,
  }) {
    _itemService = FeedItemService(
      posts: const [],
      projects: const [],
      isCreatingPost: false,
    );
  }

  void updateItemService(FeedItemService newService) {
    _itemService = newService;
    notifyListeners();
  }

  void selectPost(String postId) {
    updateSelection(postId, isProject: false);
  }

  void selectProject(String projectId) {
    updateSelection(projectId, isProject: true);
    feedBloc.add(FeedProjectSelected(projectId));
  }

  void addPostToProject({required String projectId, required String postId}) {
    feedBloc.add(FeedPostAddedToProject(projectId: projectId, postId: postId));
  }

  void updateSelection(String itemId, {required bool isProject}) {
    positionTracker.updatePosition(
      selectedItemId: itemId,
      isProject: isProject,
    );

    int targetIndex = -1;
    for (int i = 0; i < itemService.totalItemCount; i++) {
      if (isProject) {
        final project = itemService.getProjectAtPosition(i);
        if (project?.id == itemId) {
          targetIndex = i;
          break;
        }
      } else {
        final post = itemService.getPostAtPosition(i);
        if (post?.id == itemId) {
          targetIndex = i;
          break;
        }
      }
    }

    if (targetIndex != -1) {
      positionTracker.updatePosition(
        index: targetIndex,
        selectedItemId: itemId,
        isProject: isProject,
      );
    }

    notifyListeners();
  }

  void selectStep(String itemId, int stepIndex) {
    final position = positionTracker.currentPosition;
    if (position.selectedItemId != itemId) {
      positionTracker.updatePosition(
        selectedItemId: itemId,
        isProject: position.isProject,
      );
    }
  }

  Future<void> moveToPosition(int index) async {
    if (index < 0 || index >= itemService.totalItemCount) return;
    await positionTracker.scrollToIndex(index);
    positionTracker.updatePosition(index: index);
  }

  Future<int?> findItemIndex(String itemId, {bool isProject = false}) async {
    for (int i = 0; i < itemService.totalItemCount; i++) {
      if (isProject) {
        final project = itemService.getProjectAtPosition(i);
        if (project?.id == itemId) {
          return i;
        }
      } else {
        final post = itemService.getPostAtPosition(i);
        if (post?.id == itemId) {
          return i;
        }
      }
    }
    return null;
  }

  Future<void> scrollToIndex(int index) async {
    if (index < 0 || index >= itemService.totalItemCount) return;
    await positionTracker.scrollToIndex(index);
  }

  Future<int?> moveToItem(String itemId, {bool isProject = false}) async {
    final index = await findItemIndex(itemId, isProject: isProject);
    
    if (index != null) {
      positionTracker.updatePosition(
        index: index,
        selectedItemId: itemId,
        isProject: isProject,
      );
      
      await Future.delayed(const Duration(milliseconds: 50));
      await scrollToIndex(index);
      
      return index;
    }
    
    feedBloc.add(const FeedRefreshed());
    return null;
  }

  void refresh() {
    feedBloc.add(const FeedRefreshed());
  }

  void loadMore() {
    feedBloc.add(const FeedLoadMore());
  }

  void likePost(String postId) {
    feedBloc.add(FeedPostLiked(postId));
  }

  void ratePost(String postId, double rating) {
    feedBloc.add(FeedPostRated(postId, rating));
  }

  @override
  void dispose() {
    positionTracker.dispose();
    super.dispose();
  }
}
