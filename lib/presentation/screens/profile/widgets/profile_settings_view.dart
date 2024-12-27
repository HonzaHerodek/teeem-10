import 'package:flutter/material.dart';
import '../../../../data/models/profile_settings_model.dart';

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
  late String _selectedTarget;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.settings.email);
    _passwordController = TextEditingController(text: widget.settings.password);
    _selectedColor = widget.settings.backgroundAnimationColor;
    _selectedTarget = widget.settings.defaultTarget;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateSettings() {
    final newSettings = widget.settings.copyWith(
      backgroundAnimationColor: _selectedColor,
      defaultTarget: _selectedTarget,
      email: _emailController.text,
      password: _passwordController.text,
    );
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            'Background Animation Color',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
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
          const SizedBox(height: 24),
          Text(
            'Default Target',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8),
          Container(
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
          const SizedBox(height: 24),
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
    );
  }
}
