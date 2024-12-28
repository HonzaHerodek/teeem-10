import 'package:flutter/material.dart';

class ProfileSettingsModel {
  // Account Settings
  final String? email;
  final String? password;

  // Visual Settings
  final Color backgroundAnimationColor;
  final bool backgroundAnimationEnabled;

  // App Configuration
  final String defaultTarget;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const ProfileSettingsModel({
    this.email,
    this.password,
    this.backgroundAnimationColor = Colors.blue,
    this.backgroundAnimationEnabled = true,
    this.defaultTarget = 'all',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  ProfileSettingsModel copyWith({
    String? email,
    String? password,
    Color? backgroundAnimationColor,
    bool? backgroundAnimationEnabled,
    String? defaultTarget,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return ProfileSettingsModel(
      email: email ?? this.email,
      password: password ?? this.password,
      backgroundAnimationColor:
          backgroundAnimationColor ?? this.backgroundAnimationColor,
      backgroundAnimationEnabled:
          backgroundAnimationEnabled ?? this.backgroundAnimationEnabled,
      defaultTarget: defaultTarget ?? this.defaultTarget,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'backgroundAnimationColor': backgroundAnimationColor.value,
      'backgroundAnimationEnabled': backgroundAnimationEnabled,
      'defaultTarget': defaultTarget,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory ProfileSettingsModel.fromJson(Map<String, dynamic> json) {
    return ProfileSettingsModel(
      email: json['email'] as String?,
      password: json['password'] as String?,
      backgroundAnimationColor: Color(json['backgroundAnimationColor'] as int),
      backgroundAnimationEnabled: json['backgroundAnimationEnabled'] as bool,
      defaultTarget: json['defaultTarget'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      soundEnabled: json['soundEnabled'] as bool,
      vibrationEnabled: json['vibrationEnabled'] as bool,
    );
  }
}
