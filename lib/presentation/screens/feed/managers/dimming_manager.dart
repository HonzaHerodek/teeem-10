import 'package:flutter/material.dart';
import '../../../../core/utils/dimming_effect.dart';
import '../controllers/feed_header_controller.dart';

typedef DimmingUpdateCallback = void Function({
  required bool isDimmed,
  required DimmingConfig config,
  required Map<GlobalKey, DimmingConfig> excludedConfigs,
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

  Map<GlobalKey, DimmingConfig> getExcludedConfigs() {
    return {
      plusActionButtonKey: const DimmingConfig(
        excludeShape: DimmingExcludeShape.circle,
        glowSpread: 4.0,
        glowBlur: 8.0,
        glowStrength: 0.5,
      ),
      profileButtonKey: const DimmingConfig(
        excludeShape: DimmingExcludeShape.circle,
        glowSpread: 4.0,
        glowBlur: 8.0,
        glowStrength: 0.5,
      ),
      searchBarKey: const DimmingConfig(
        excludeShape: DimmingExcludeShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        glowSpread: 4.0,
        glowBlur: 8.0,
        glowStrength: 0.5,
      ),
      filtersKey: const DimmingConfig(
        excludeShape: DimmingExcludeShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        glowSpread: 4.0,
        glowBlur: 8.0,
        glowStrength: 0.5,
      ),
    };
  }

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
    required DimmingConfig config,
    List<GlobalKey> excludedKeys = const [],
    Offset? source,
  }) {
    // Convert excludedKeys to excludedConfigs if provided, otherwise use getExcludedConfigs
    final configs = excludedKeys.isEmpty 
        ? getExcludedConfigs() 
        : Map.fromEntries(excludedKeys.map((key) => 
            MapEntry(key, getExcludedConfigs()[key] ?? config)));

    onDimmingUpdate(
      isDimmed: isDimmed,
      config: config,
      excludedConfigs: configs,
      source: source,
    );
  }
}
