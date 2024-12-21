import 'package:flutter/material.dart';
import '../../../../core/utils/dimming_effect.dart';
import '../controllers/feed_header_controller.dart';

typedef DimmingUpdateCallback = void Function({
  required bool isDimmed,
  required List<GlobalKey> excludedKeys,
  required DimmingConfig config,
  Offset? source,
});

class DimmingManager {
  final FeedHeaderController headerController;
  final GlobalKey plusActionButtonKey;
  final GlobalKey profileButtonKey;
  final GlobalKey searchBarKey;
  final GlobalKey filtersKey;
  final DimmingUpdateCallback onDimmingUpdate;

  DimmingManager({
    required this.headerController,
    required this.plusActionButtonKey,
    required this.profileButtonKey,
    required this.searchBarKey,
    required this.filtersKey,
    required this.onDimmingUpdate,
  });

  List<GlobalKey> getExcludedKeys() {
    return [
      plusActionButtonKey,
      profileButtonKey,
      searchBarKey,
      filtersKey,
    ];
  }

  void updateDimming({
    required bool isDimmed,
    required List<GlobalKey> excludedKeys,
    required DimmingConfig config,
    Offset? source,
  }) {
    onDimmingUpdate(
      isDimmed: isDimmed,
      excludedKeys: excludedKeys,
      config: config,
      source: source,
    );
  }
}
