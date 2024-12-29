import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

class SharedPreferencesSettingsRepository implements SettingsRepository {
  static const String _settingsKey = 'user_settings';
  SharedPreferences? _prefs;
  Map<String, dynamic>? _memoryCache;

  SharedPreferencesSettingsRepository();

  Future<void> _initializePrefs() async {
    if (_prefs != null) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      // Try to load existing settings into memory cache
      final String? settingsJson = _prefs?.getString(_settingsKey);
      if (settingsJson != null) {
        _memoryCache = json.decode(settingsJson) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
      // Continue without SharedPreferences - will use memory cache
    }
  }

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    _memoryCache = settings; // Always update memory cache
    
    try {
      await _initializePrefs();
      final String settingsJson = json.encode(settings);
      await _prefs?.setString(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('Failed to save settings to SharedPreferences: $e');
      // Continue with memory cache only
    }
  }

  @override
  Future<Map<String, dynamic>?> loadSettings() async {
    try {
      await _initializePrefs();
      if (_prefs != null) {
        final String? settingsJson = _prefs?.getString(_settingsKey);
        if (settingsJson != null) {
          _memoryCache = json.decode(settingsJson) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Failed to load settings from SharedPreferences: $e');
      // Continue with existing memory cache
    }
    
    return _memoryCache;
  }
}
