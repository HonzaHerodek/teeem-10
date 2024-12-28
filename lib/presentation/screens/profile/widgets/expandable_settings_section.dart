import 'package:flutter/material.dart';
import '../../../../data/models/profile_settings_model.dart';
import 'profile_settings_view.dart';

class ExpandableSettingsSection extends StatefulWidget {
  final ProfileSettingsModel settings;
  final Function(ProfileSettingsModel) onSettingsChanged;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ExpandableSettingsSection({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<ExpandableSettingsSection> createState() =>
      _ExpandableSettingsSectionState();
}

class _ExpandableSettingsSectionState extends State<ExpandableSettingsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ExpandableSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Settings button always visible
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.8),
            ),
            child: IconButton(
              icon: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _sizeAnimation,
                color: Colors.white,
                size: 28,
              ),
              onPressed: widget.onToggle,
            ),
          ),
        ),
        // Animated settings content
        ClipRect(
          child: SizeTransition(
            sizeFactor: _sizeAnimation,
            axisAlignment: -1,
            child: ProfileSettingsView(
              settings: widget.settings,
              onSettingsChanged: widget.onSettingsChanged,
            ),
          ),
        ),
      ],
    );
  }
}
