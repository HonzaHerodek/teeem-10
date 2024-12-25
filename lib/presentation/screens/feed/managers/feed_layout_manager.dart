import 'package:flutter/material.dart';
import '../../../../core/utils/dimming_effect.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/project_model.dart';
import '../controllers/feed_controller.dart';
import '../controllers/feed_header_controller.dart';
import '../managers/dimming_manager.dart';

class FeedLayoutManager {
  final FeedController feedController;
  final FeedHeaderController headerController;
  final DimmingManager dimmingManager;
  bool _isProfileOpen;
  bool _isCreatingPost;
  GlobalKey? _selectedItemKey;

  bool get isProfileOpen => _isProfileOpen;
  bool get isCreatingPost => _isCreatingPost;
  GlobalKey? get selectedItemKey => _selectedItemKey;

  set isProfileOpen(bool value) {
    _isProfileOpen = value;
    updateDimming();
  }

  set isCreatingPost(bool value) {
    _isCreatingPost = value;
    updateDimming();
  }

  set selectedItemKey(GlobalKey? value) {
    _selectedItemKey = value;
    updateDimming();
  }

  FeedLayoutManager({
    required this.feedController,
    required this.headerController,
    required this.dimmingManager,
    bool isProfileOpen = false,
    bool isCreatingPost = false,
    GlobalKey? selectedItemKey,
  })  : _isProfileOpen = isProfileOpen,
        _isCreatingPost = isCreatingPost,
        _selectedItemKey = selectedItemKey;

  void updateFeedService(List<PostModel> posts, List<ProjectModel> projects) {
    // Implementation
  }

  double getTopPadding(BuildContext context) {
    // Implementation
    return 0.0;
  }

  List<GlobalKey> getExcludedAreas(BuildContext context) {
    // Implementation
    return [];
  }

  void updateDimming() {
    final isSearchActive = headerController.state.isSearchVisible;
    
    final baseConfig = const DimmingConfig(
      dimmingStrength: 0.7,
      glowBlur: 10,
    );

    if (isSearchActive) {
      // When search is active, use all excluded elements with their specific shapes
      dimmingManager.updateDimming(
        isDimmed: true,
        config: baseConfig,
        excludedKeys: dimmingManager.getExcludedKeys(),
      );
    } else if (_isProfileOpen) {
      // Profile panel dimming - exclude plus button and target button
      dimmingManager.updateDimming(
        isDimmed: true,
        config: baseConfig,
        excludedKeys: [
          dimmingManager.plusActionButtonKey,
          dimmingManager.searchBarKey,
        ],
      );
    } else if (_isCreatingPost) {
      // Post creation dimming - only exclude plus button
      dimmingManager.updateDimming(
        isDimmed: true,
        config: baseConfig,
        excludedKeys: [dimmingManager.plusActionButtonKey],
      );
    } else {
      // No dimming
      dimmingManager.updateDimming(
        isDimmed: false,
        config: const DimmingConfig(),
      );
    }
  }

  void handleScroll(ScrollController controller) {
    // Implementation
  }
}
