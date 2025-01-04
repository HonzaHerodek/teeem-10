import 'package:flutter/material.dart';
import '../../core/di/injection.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/models/profile_settings_model.dart';

class BackgroundColorProvider extends ChangeNotifier {
  Color _backgroundColor = Colors.blue;
  final SettingsRepository _settingsRepository = getIt<SettingsRepository>();

  BackgroundColorProvider();

  Color get backgroundColor => _backgroundColor;

  Future<void> initialize() async {
    final settingsData = await _settingsRepository.loadSettings();
    if (settingsData != null) {
      final settings = ProfileSettingsModel.fromJson(settingsData);
      _backgroundColor = settings.backgroundAnimationColor;
      notifyListeners();
    }
  }

  Future<void> setBackgroundColor(Color color) async {
    _backgroundColor = color;
    final settingsData = await _settingsRepository.loadSettings();
    final currentSettings = settingsData != null 
        ? ProfileSettingsModel.fromJson(settingsData)
        : const ProfileSettingsModel();
        
    final newSettings = currentSettings.copyWith(
      backgroundAnimationColor: color,
    );
    await _settingsRepository.saveSettings(newSettings.toJson());
    notifyListeners();
  }
}
