import 'package:flutter/material.dart';
import '../../../../core/utils/dimming_effect.dart';
import '../../../../data/models/project_model.dart';
import '../controllers/feed_controller.dart';
import '../controllers/feed_header_controller.dart';
import '../managers/dimming_manager.dart';
import '../managers/feed_layout_manager.dart';
import '../managers/notification_item_manager.dart';

class FeedStateManager {
  final FeedController feedController;
  final FeedHeaderController headerController;
  final DimmingManager dimmingManager;
  final NotificationItemManager notificationManager;
  final FeedLayoutManager layoutManager;
  final Function(bool) onCreatePostChanged;
  final Function({
    required bool isDimmed,
    required DimmingConfig config,
    required Map<GlobalKey, DimmingConfig> excludedConfigs,
    Offset? source,
  }) onDimmingChanged;
  final Function(GlobalKey?) onKeyChanged;

  FeedStateManager({
    required this.feedController,
    required this.headerController,
    required this.dimmingManager,
    required this.notificationManager,
    required this.layoutManager,
    required this.onCreatePostChanged,
    required this.onDimmingChanged,
    required this.onKeyChanged,
  });

  void updateManagers({
    required bool isProfileOpen,
    required bool isCreatingPost,
    required GlobalKey? selectedItemKey,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Update layout manager state
      layoutManager.isProfileOpen = isProfileOpen;
      layoutManager.isCreatingPost = isCreatingPost;
      layoutManager.selectedItemKey = selectedItemKey;
      
      // Update notification manager state
      notificationManager.isProfileOpen = isProfileOpen;
      notificationManager.selectedItemKey = selectedItemKey;
    });
  }

  void handlePostComplete(bool success, [ProjectModel? project]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onCreatePostChanged(false);
      if (success) {
        feedController.refresh();
        if (project != null) {
          feedController.addPostToProject(
            projectId: project.id,
            postId: '', // This will be set by the backend
          );
        }
      }
    });
  }

  void handleProfileStateChange(bool isOpen) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Let the FeedLayoutManager handle the dimming update since it manages
      // all the excluded elements consistently
      layoutManager.isProfileOpen = isOpen;
    });
  }

  void dispose() {
    feedController.dispose();
    headerController.dispose();
  }
}
