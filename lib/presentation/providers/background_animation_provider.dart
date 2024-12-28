import 'package:flutter/material.dart';
import '../../core/di/injection.dart';
import '../../domain/repositories/settings_repository.dart';

enum BackgroundAnimationType {
  stripes,
  lavaLamp,
  gradient,
  none;

  String get displayName {
    switch (this) {
      case BackgroundAnimationType.stripes:
        return 'Stripes';
      case BackgroundAnimationType.lavaLamp:
        return 'Lava Lamp';
      case BackgroundAnimationType.gradient:
        return 'Gradient';
      case BackgroundAnimationType.none:
        return 'None';
    }
  }
}

class BackgroundAnimationProvider extends ChangeNotifier {
  BackgroundAnimationType _animationType = BackgroundAnimationType.stripes;
  final SettingsRepository _settingsRepository = getIt<SettingsRepository>();
  static const String _settingsKey = 'background_animation_type';

  BackgroundAnimationProvider() {
    _loadAnimationType();
  }

  BackgroundAnimationType get animationType => _animationType;

  Future<void> _loadAnimationType() async {
    final settingsData = await _settingsRepository.loadSettings();
    if (settingsData != null && settingsData[_settingsKey] != null) {
      _animationType = BackgroundAnimationType.values[settingsData[_settingsKey] as int];
      notifyListeners();
    }
  }

  Future<void> setAnimationType(BackgroundAnimationType type) async {
    _animationType = type;
    final settingsData = await _settingsRepository.loadSettings() ?? {};
    settingsData[_settingsKey] = type.index;
    await _settingsRepository.saveSettings(settingsData);
    notifyListeners();
  }
}
