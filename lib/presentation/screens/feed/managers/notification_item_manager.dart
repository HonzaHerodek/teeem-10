import 'package:flutter/material.dart';
import '../controllers/feed_controller.dart';
import '../controllers/feed_header_controller.dart';
import '../managers/dimming_manager.dart';

class NotificationItemManager {
  final FeedController feedController;
  final FeedHeaderController headerController;
  final DimmingManager dimmingManager;
  bool _isProfileOpen;
  GlobalKey? _selectedItemKey;

  bool get isProfileOpen => _isProfileOpen;
  GlobalKey? get selectedItemKey => _selectedItemKey;

  set isProfileOpen(bool value) {
    _isProfileOpen = value;
    _updateState();
  }

  set selectedItemKey(GlobalKey? value) {
    _selectedItemKey = value;
    _updateState();
  }

  NotificationItemManager({
    required this.feedController,
    required this.headerController,
    required this.dimmingManager,
    bool isProfileOpen = false,
    GlobalKey? selectedItemKey,
  })  : _isProfileOpen = isProfileOpen,
        _selectedItemKey = selectedItemKey;

  void _updateState() {
    // Implementation for state updates
  }

  Future<void> moveToItem(String itemId, bool isProject) async {
    // Implementation
  }
}
