import 'package:flutter/material.dart';
import '../../../../core/utils/dimming_effect.dart';
import '../controllers/feed_controller.dart';
import '../controllers/feed_header_controller.dart';
import '../managers/dimming_manager.dart';
import '../managers/notification_item_manager.dart';
import '../managers/feed_layout_manager.dart';

/// Manages feed state and coordinates between different managers
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

  const FeedStateManager({
    required this.feedController,
    required this.headerController,
    required this.dimmingManager,
    required this.notificationManager,
    required this.layoutManager,
    required this.onCreatePostChanged,
    required this.onDimmingChanged,
    required this.onKeyChanged,
  });

  /// Handles post creation completion
  void handlePostComplete(bool success) {
    onCreatePostChanged(false);
    if (success) feedController.refresh();
  }

  /// Handles dimming updates
  void handleDimmingUpdate({
    required bool isDimmed,
    required List<GlobalKey> excludedKeys,
    required DimmingConfig config,
    Offset? source,
  }) {
    onDimmingChanged(
      isDimmed: isDimmed,
      config: config,
      excludedKeys: excludedKeys,
      source: source,
    );
  }

  /// Handles profile state changes
  void handleProfileStateChange(bool isOpen) {
    notificationManager.updateDimming();
  }

  /// Updates managers when feed state changes
  void updateManagers({
    required bool isProfileOpen,
    required bool isCreatingPost,
    required GlobalKey? selectedItemKey,
  }) {
    notificationManager.updateDimming();
    layoutManager.updateDimming();
  }

  /// Disposes of resources
  void dispose() {
    headerController.removeListener(notificationManager.updateDimming);
    headerController.dispose();
    feedController.dispose();
  }
}
