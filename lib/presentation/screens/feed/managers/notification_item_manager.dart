import 'package:flutter/material.dart';
import '../../../../data/models/notification_model.dart';
import '../controllers/feed_controller.dart';
import '../controllers/feed_header_controller.dart';
import '../managers/dimming_manager.dart';

/// Manages the coordination between notifications and their corresponding feed items
class NotificationItemManager {
  final FeedController feedController;
  final FeedHeaderController headerController;
  final DimmingManager dimmingManager;
  final bool isProfileOpen;
  final GlobalKey? selectedItemKey;
  final Function(GlobalKey?) onKeyUpdate;

  const NotificationItemManager({
    required this.feedController,
    required this.headerController,
    required this.dimmingManager,
    required this.isProfileOpen,
    required this.selectedItemKey,
    required this.onKeyUpdate,
  });

  /// Attempts to move to and highlight a feed item
  Future<void> moveToItem(String itemId, bool isProject, {bool scrollOnly = false}) async {
    // First find the item index
    final foundIndex = await feedController.findItemIndex(itemId, isProject: isProject);
    
    if (foundIndex != null) {
      if (!scrollOnly) {
        // For new selections, create key and update dimming first
        final newKey = GlobalKey();
        onKeyUpdate(newKey);

        // Wait for key to be attached and layout to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Update dimming before scrolling
        dimmingManager.updateDimming(
          isProfileOpen: isProfileOpen,
          selectedItemKey: newKey,
        );
      }

      // Then scroll to the item
      await feedController.scrollToIndex(foundIndex);
      
      // Start periodic check to ensure item stays visible
      _startPeriodicCheck(itemId, isProject);
      
      // Ensure dimming is still correct after scroll
      if (!scrollOnly && selectedItemKey != null) {
        dimmingManager.updateDimming(
          isProfileOpen: isProfileOpen,
          selectedItemKey: selectedItemKey,
        );
      }
    } else {
      // If item not found, clear the key
      onKeyUpdate(null);
      // Refresh feed to try to load the item
      feedController.refresh();
    }
  }

  /// Starts periodic check to ensure selected item stays visible
  void _startPeriodicCheck(String itemId, bool isProject) {
    Future.doWhile(() async {
      // Check if notification is still selected
      final notification = headerController.selectedNotification;
      if (notification == null || 
          (notification.type == NotificationType.post && notification.postId != itemId) ||
          (notification.type == NotificationType.project && notification.projectId != itemId)) {
        return false;
      }

      // Find current position
      final index = await feedController.findItemIndex(itemId, isProject: isProject);
      if (index != null) {
        // Ensure item is visible
        await feedController.scrollToIndex(index);
      }

      // Wait before next check
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    });
  }

  /// Ensures the selected notification's item is highlighted and visible
  Future<void> ensureItemHighlighted(bool forceScroll) async {
    final notification = headerController.selectedNotification;
    if (notification == null || notification.type == NotificationType.profile) {
      if (selectedItemKey != null) {
        onKeyUpdate(null);
        dimmingManager.updateDimming(
          isProfileOpen: isProfileOpen,
          selectedItemKey: null,
        );
      }
      return;
    }

    final itemId = notification.type == NotificationType.post
        ? notification.postId!
        : notification.projectId!;
    final isProject = notification.type == NotificationType.project;

    // Check if item exists in current feed
    final index = await feedController.findItemIndex(itemId, isProject: isProject);
    if (index != null) {
      if (selectedItemKey == null) {
        // If no key exists, do full highlight and scroll
        await moveToItem(itemId, isProject);
      } else if (forceScroll) {
        // If key exists but scroll requested, just scroll
        await moveToItem(itemId, isProject, scrollOnly: true);
      } else {
        // Otherwise just ensure dimming is correct
        dimmingManager.updateDimming(
          isProfileOpen: isProfileOpen,
          selectedItemKey: selectedItemKey,
        );
      }
    }
  }

  /// Updates dimming based on current notification state
  void updateDimming() {
    final isNotificationMenuOpen = headerController.state.isNotificationMenuOpen;
    final isSearchVisible = headerController.state.isSearchVisible;
    
    if (isNotificationMenuOpen) {
      // When notification menu is open, ensure highlighting
      ensureItemHighlighted(false);
    } else if (isSearchVisible) {
      // Handle search mode dimming
      dimmingManager.updateDimming(
        isProfileOpen: isProfileOpen,
        selectedItemKey: null,
      );
    } else {
      // Clear selection for other cases
      if (selectedItemKey != null) {
        onKeyUpdate(null);
        dimmingManager.updateDimming(
          isProfileOpen: isProfileOpen,
          selectedItemKey: null,
        );
      }
    }
  }
}
