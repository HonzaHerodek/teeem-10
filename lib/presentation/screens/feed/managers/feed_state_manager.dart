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
    required List<GlobalKey> excludedKeys,
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
    // Update layout manager state directly
    layoutManager.isProfileOpen = isProfileOpen;
    layoutManager.isCreatingPost = isCreatingPost;
    layoutManager.selectedItemKey = selectedItemKey;
    
    // Update notification manager state directly
    notificationManager.isProfileOpen = isProfileOpen;
    notificationManager.selectedItemKey = selectedItemKey;
  }

  void handlePostComplete(bool success, [ProjectModel? project]) {
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
  }

  void handleProfileStateChange(bool isOpen) {
    if (isOpen) {
      dimmingManager.onDimmingUpdate(
        isDimmed: true,
        excludedKeys: const [],
        config: const DimmingConfig(
          dimmingStrength: 0.7,
          glowBlur: 10,
        ),
      );
    } else {
      dimmingManager.onDimmingUpdate(
        isDimmed: false,
        excludedKeys: const [],
        config: const DimmingConfig(),
      );
    }
  }

  void dispose() {
    feedController.dispose();
    headerController.dispose();
  }
}
