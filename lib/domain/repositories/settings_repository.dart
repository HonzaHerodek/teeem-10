abstract class SettingsRepository {
  Future<void> saveSettings(Map<String, dynamic> settings);
  Future<Map<String, dynamic>?> loadSettings();
}
