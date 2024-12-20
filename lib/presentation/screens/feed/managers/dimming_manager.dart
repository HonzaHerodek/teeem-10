import 'package:flutter/material.dart';
import '../../../../core/utils/dimming_effect.dart';
import '../../../../data/models/notification_model.dart';
import '../controllers/feed_header_controller.dart';

class DimmingManager {
  final FeedHeaderController headerController;
  final GlobalKey plusActionButtonKey;
  final GlobalKey profileButtonKey;
  final GlobalKey searchBarKey;
  final GlobalKey filtersKey;
  final Function(
      {required bool isDimmed,
      required List<GlobalKey> excludedKeys,
      required DimmingConfig config,
      Offset? source}) onDimmingUpdate;

  const DimmingManager({
    required this.headerController,
    required this.plusActionButtonKey,
    required this.profileButtonKey,
    required this.searchBarKey,
    required this.filtersKey,
    required this.onDimmingUpdate,
  });

  DimmingConfig _getConfigForNotification(NotificationModel? notification) {
    // Default config used for all cases
    const defaultConfig = DimmingConfig(
      dimmingColor: Colors.black,
      dimmingStrength: 0.7,
      glowColor: Colors.blue,
      glowSpread: 4.0,
      glowBlur: 8.0,
      glowStrength: 0.5,
    );

    if (notification == null) {
      return defaultConfig;
    }

    switch (notification.type) {
      case NotificationType.post:
      case NotificationType.project:
        return defaultConfig.copyWith(
          excludeShape: DimmingExcludeShape.rectangle,
          borderRadius: BorderRadius.circular(12),
          glowSpread: 8.0,
          glowBlur: 16.0,
          glowStrength: 0.3,
        );
      case NotificationType.profile:
      default:
        return defaultConfig.copyWith(
          excludeShape: DimmingExcludeShape.circle,
        );
    }
  }

  List<GlobalKey> _getExcludedKeys({
    required bool isSearchVisible,
    required bool isProfileOpen,
    GlobalKey? selectedItemKey,
    NotificationModel? selectedNotification,
  }) {
    final keys = <GlobalKey>[];
    
    // Always exclude plus button during search/target or when profile panel is open
    if (isSearchVisible || isProfileOpen) {
      keys.add(plusActionButtonKey);
    }
    
    // Search/Target mode exclusions
    if (isSearchVisible) {
      keys.add(headerController.targetIconKey); // Target icon
      keys.add(searchBarKey); // Search bar
      keys.add(filtersKey); // Filter section
    }
    
    // Notification mode exclusions
    if (headerController.state.isNotificationMenuOpen) {
      keys.add(headerController.notificationBarKey); // Notification bar
      
      // Add selected item key if it exists and notification is not for profile
      if (selectedItemKey != null && 
          selectedNotification != null && 
          selectedNotification.type != NotificationType.profile) {
        keys.add(selectedItemKey);
      }
      
      // Exclude profile button for profile notifications
      if (selectedNotification?.type == NotificationType.profile) {
        keys.add(profileButtonKey);
      }
    }
    
    // Profile/Sliding panel mode exclusions
    if (isProfileOpen) {
      keys.add(plusActionButtonKey); // Plus button
      keys.add(headerController.targetIconKey); // Target/search button
    }

    return keys;
  }

  void updateDimming({
    required bool isProfileOpen,
    GlobalKey? selectedItemKey,
  }) {
    // Delay dimming update slightly to ensure layout is complete
    Future.delayed(const Duration(milliseconds: 100), () {
      final isSearchVisible = headerController.state.isSearchVisible;
      final isNotificationMenuOpen = headerController.state.isNotificationMenuOpen;
      final selectedNotification = headerController.selectedNotification;

      // Get positions of relevant elements
      final RenderBox? targetBox = headerController.targetIconKey.currentContext
          ?.findRenderObject() as RenderBox?;
      final RenderBox? plusBox = plusActionButtonKey.currentContext
          ?.findRenderObject() as RenderBox?;
      final RenderBox? notificationBox = headerController.notificationBarKey.currentContext
          ?.findRenderObject() as RenderBox?;

      // Calculate source position for dimming effect
      Offset? source;
      if (isSearchVisible) {
        if (plusBox != null) {
          final plusPosition = plusBox.localToGlobal(Offset.zero);
          source = plusPosition + Offset(plusBox.size.width / 2, plusBox.size.height / 2);
        } else if (targetBox != null) {
          final targetPosition = targetBox.localToGlobal(Offset.zero);
          source = targetPosition + Offset(targetBox.size.width / 2, targetBox.size.height / 2);
        }
      } else if (isNotificationMenuOpen && notificationBox != null) {
        // Use notification bar as source when notification menu is open
        final notificationPosition = notificationBox.localToGlobal(Offset.zero);
        source = notificationPosition + Offset(notificationBox.size.width / 2, notificationBox.size.height / 2);
      }

      onDimmingUpdate(
        isDimmed: isSearchVisible || isProfileOpen || isNotificationMenuOpen,
        excludedKeys: _getExcludedKeys(
          isSearchVisible: isSearchVisible,
          isProfileOpen: isProfileOpen,
          selectedItemKey: selectedItemKey,
          selectedNotification: selectedNotification,
        ),
        source: source,
        config: _getConfigForNotification(selectedNotification),
      );
    });
  }
}
