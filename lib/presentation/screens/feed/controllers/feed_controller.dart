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
    // Initialize with empty service
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

  void updateSelection(String itemId, {required bool isProject}) {
    // Update position tracker
    positionTracker.updatePosition(
      selectedItemId: itemId,
      isProject: isProject,
    );

    // Find the item's index
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
      // Update position with found index
      positionTracker.updatePosition(
        index: targetIndex,
        selectedItemId: itemId,
        isProject: isProject,
      );
    }

    // Notify listeners to trigger UI updates
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
    // Step selection logic can be expanded based on requirements
  }

  Future<void> moveToPosition(int index) async {
    if (index < 0 || index >= itemService.totalItemCount) return;

    await positionTracker.scrollToIndex(index);
    positionTracker.updatePosition(index: index);
  }

  Future<int?> moveToItem(String itemId, {bool isProject = false}) async {
    int? targetIndex;
    
    // Find the item's index
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
    
    if (targetIndex != null && targetIndex != -1) {
      // Update selection first
      positionTracker.updatePosition(
        index: targetIndex,
        selectedItemId: itemId,
        isProject: isProject,
      );
      
      // Wait for selection to be processed
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Then scroll to the item
      await positionTracker.scrollToIndex(targetIndex);
      
      // Return the found index
      return targetIndex;
    }
    
    // If item not found, try refreshing the feed
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
