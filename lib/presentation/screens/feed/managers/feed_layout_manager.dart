import 'package:flutter/material.dart';
import '../../../../core/utils/dimming_effect.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/project_model.dart';
import '../controllers/feed_controller.dart';
import '../controllers/feed_header_controller.dart';
import '../managers/dimming_manager.dart';
import '../services/feed_item_service.dart';

/// Manages feed layout, padding, and state updates
class FeedLayoutManager {
  final FeedController feedController;
  final FeedHeaderController headerController;
  final DimmingManager dimmingManager;
  final bool isProfileOpen;
  final bool isCreatingPost;
  final GlobalKey? selectedItemKey;
  final Function({
    required bool isDimmed,
    required List<GlobalKey> excludedKeys,
    required DimmingConfig config,
    Offset? source,
  }) onDimmingUpdate;

  const FeedLayoutManager({
    required this.feedController,
    required this.headerController,
    required this.dimmingManager,
    required this.isProfileOpen,
    required this.isCreatingPost,
    required this.selectedItemKey,
    required this.onDimmingUpdate,
  });

  /// Gets the top padding for the feed content
  double getTopPadding(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    const headerBaseHeight = 64.0;
    const chipsHeight = 96.0;
    return topPadding + headerBaseHeight + chipsHeight;
  }

  /// Gets excluded areas for the sliding panel
  List<Rect> getExcludedAreas(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return [
      Rect.fromLTWH(
        0,
        size.height - bottomPadding - 88,
        size.width,
        88 + bottomPadding,
      ),
    ];
  }

  /// Updates feed item service with new data
  void updateFeedService(List<PostModel> posts, List<ProjectModel> projects) {
    feedController.updateItemService(
      FeedItemService(
        posts: posts,
        projects: projects,
        isCreatingPost: isCreatingPost,
      ),
    );
  }

  /// Updates dimming state
  void updateDimming() {
    dimmingManager.updateDimming(
      isProfileOpen: isProfileOpen,
      selectedItemKey: selectedItemKey,
    );
  }

  /// Handles scroll events
  void handleScroll(ScrollController controller) {
    if (controller.position.pixels <= controller.position.minScrollExtent) {
      feedController.refresh();
    } else if (controller.position.pixels >= controller.position.maxScrollExtent) {
      feedController.loadMore();
    }
  }
}
