import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/profile_settings_model.dart';
import '../../../providers/background_color_provider.dart';
import '../../../providers/background_animation_provider.dart';
import '../../../providers/background_animation_provider.dart' show BackgroundAnimationType;
import 'settings_section.dart';

class ProfileSettingsView extends StatefulWidget {
  final ProfileSettingsModel settings;
  final Function(ProfileSettingsModel) onSettingsChanged;

  const ProfileSettingsView({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late Color _selectedColor;
  late bool _backgroundAnimationEnabled;
  late String _selectedTarget;
  late bool _notificationsEnabled;
  late bool _soundEnabled;
  late bool _vibrationEnabled;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.settings.email);
    _passwordController = TextEditingController(text: widget.settings.password);
    _selectedColor = widget.settings.backgroundAnimationColor;
    _backgroundAnimationEnabled = widget.settings.backgroundAnimationEnabled;
    _selectedTarget = widget.settings.defaultTarget;
    _notificationsEnabled = widget.settings.notificationsEnabled;
    _soundEnabled = widget.settings.soundEnabled;
    _vibrationEnabled = widget.settings.vibrationEnabled;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateSettings() {
    final newSettings = widget.settings.copyWith(
      email: _emailController.text,
      password: _passwordController.text,
      backgroundAnimationColor: _selectedColor,
      backgroundAnimationEnabled: _backgroundAnimationEnabled,
      defaultTarget: _selectedTarget,
      notificationsEnabled: _notificationsEnabled,
      soundEnabled: _soundEnabled,
      vibrationEnabled: _vibrationEnabled,
    );
    widget.onSettingsChanged(newSettings);
  }

  Widget _buildSettingField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.amber,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(), // Let parent handle scrolling
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSection(
              title: 'Account',
              initiallyExpanded: true,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => _updateSettings(),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => _updateSettings(),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SettingsSection(
              title: 'Visuals',
              children: [
                _buildSettingField(
                  label: 'Animation Type',
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: BackgroundAnimationType.values.map((type) {
                        final isSelected = context.select<BackgroundAnimationProvider, bool>(
                          (provider) => provider.animationType == type,
                        );
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(
                              type.displayName,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                            selectedColor: Colors.amber,
                            checkmarkColor: Colors.black,
                            backgroundColor: Colors.black26,
                            onSelected: (selected) {
                              if (selected) {
                                context.read<BackgroundAnimationProvider>().setAnimationType(type);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (context.select<BackgroundAnimationProvider, bool>(
                  (provider) => provider.animationType != BackgroundAnimationType.none,
                )) ...[
                  const SizedBox(height: 16),
                  _buildSettingField(
                    label: 'Animation Color',
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final color in [
                            Colors.blue,
                            Colors.purple,
                            Colors.red,
                            Colors.green,
                            Colors.orange,
                            Colors.pink,
                            Colors.teal,
                            Colors.amber,
                          ])
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                });
                                context.read<BackgroundColorProvider>().setBackgroundColor(color);
                                _updateSettings();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedColor == color
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            SettingsSection(
              title: 'App Configuration',
              children: [
                _buildSettingField(
                  label: 'Default Target',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedTarget,
                      dropdownColor: Colors.black87,
                      style: const TextStyle(color: Colors.white),
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedTarget = newValue;
                          });
                          _updateSettings();
                        }
                      },
                      items: ['all', 'following', 'trending']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                _buildSwitch(
                  label: 'Notifications',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _updateSettings();
                  },
                ),
                if (_notificationsEnabled) ...[
                  _buildSwitch(
                    label: 'Sound',
                    value: _soundEnabled,
                    onChanged: (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                      _updateSettings();
                    },
                  ),
                  _buildSwitch(
                    label: 'Vibration',
                    value: _vibrationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                      _updateSettings();
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32), // Bottom padding
          ],
        ),
      ),
    );
  }
}
