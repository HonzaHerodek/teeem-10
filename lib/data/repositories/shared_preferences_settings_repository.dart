import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

class SharedPreferencesSettingsRepository implements SettingsRepository {
  static const String _settingsKey = 'user_settings';
  final SharedPreferences _prefs;

  SharedPreferencesSettingsRepository(this._prefs);

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final String settingsJson = json.encode(settings);
    await _prefs.setString(_settingsKey, settingsJson);
  }

  @override
  Future<Map<String, dynamic>?> loadSettings() async {
    final String? settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson == null) return null;
    return json.decode(settingsJson) as Map<String, dynamic>;
  }
}
