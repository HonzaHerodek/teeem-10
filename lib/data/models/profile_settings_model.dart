import 'package:flutter/material.dart';

class ProfileSettingsModel {
  final Color backgroundAnimationColor;
  final String defaultTarget;
  final String? email;
  final String? password;

  const ProfileSettingsModel({
    this.backgroundAnimationColor = Colors.blue,
    this.defaultTarget = 'all',
    this.email,
    this.password,
  });

  ProfileSettingsModel copyWith({
    Color? backgroundAnimationColor,
    String? defaultTarget,
    String? email,
    String? password,
  }) {
    return ProfileSettingsModel(
      backgroundAnimationColor: backgroundAnimationColor ?? this.backgroundAnimationColor,
      defaultTarget: defaultTarget ?? this.defaultTarget,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundAnimationColor': backgroundAnimationColor.value,
      'defaultTarget': defaultTarget,
      'email': email,
      'password': password,
    };
  }

  factory ProfileSettingsModel.fromJson(Map<String, dynamic> json) {
    return ProfileSettingsModel(
      backgroundAnimationColor: Color(json['backgroundAnimationColor'] as int),
      defaultTarget: json['defaultTarget'] as String,
      email: json['email'] as String?,
      password: json['password'] as String?,
    );
  }
}
