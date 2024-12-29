import 'package:flutter/material.dart';
import '../../../../data/models/profile_settings_model.dart';
import 'profile_settings_view.dart';

class ExpandableSettingsSection extends StatefulWidget {
  final ProfileSettingsModel settings;
  final Function(ProfileSettingsModel) onSettingsChanged;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ScrollController? scrollController;

  const ExpandableSettingsSection({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.isExpanded,
    required this.onToggle,
    this.scrollController,
  }) : super(key: key);

  @override
  State<ExpandableSettingsSection> createState() =>
      _ExpandableSettingsSectionState();
}

class _ExpandableSettingsSectionState extends State<ExpandableSettingsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), // Match scroll duration
      vsync: this,
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic, // Match scroll curve
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisible());
    }
  }

  @override
  void didUpdateWidget(ExpandableSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward().then((_) => _ensureVisible());
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

  void _ensureVisible() {
    if (!widget.isExpanded) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_contentKey.currentContext != null && widget.scrollController != null) {
        final RenderBox renderBox = _contentKey.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;
        
        // Calculate the target scroll position to show the settings icon and some content
        final targetScroll = widget.scrollController!.position.pixels + 
                           position.dy - 
                           120; // Slightly more space at the top
        
        widget.scrollController!.animateTo(
          targetScroll.clamp(
            0.0,
            widget.scrollController!.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 800), // Match controller duration
          curve: Curves.easeInOutCubic, // Match controller curve
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Settings button always visible at the top
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.8),
            ),
            child: IconButton(
              icon: AnimatedBuilder(
                animation: _sizeAnimation,
                builder: (context, child) {
                  return Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: Tween<double>(begin: 28, end: 32)
                        .evaluate(_sizeAnimation),
                  );
                },
              ),
              onPressed: () {
                widget.onToggle();
                if (!widget.isExpanded) {
                  // Pre-scroll to ensure the settings will be visible when expanded
                  _ensureVisible();
                }
              },
            ),
          ),
        ),
        // Animated settings content
        ClipRect(
          child: SizeTransition(
            sizeFactor: _sizeAnimation,
            axisAlignment: -1,
            child: Container(
              key: _contentKey,
              child: ProfileSettingsView(
                settings: widget.settings,
                onSettingsChanged: widget.onSettingsChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
