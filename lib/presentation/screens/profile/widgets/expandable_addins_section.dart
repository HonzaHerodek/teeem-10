import 'package:flutter/material.dart';
import '../../../../data/models/profile_addins_model.dart';
import 'profile_addins_view.dart';

class ExpandableAddInsSection extends StatefulWidget {
  final ProfileAddInsModel addIns;
  final Function(ProfileAddInsModel) onAddInsChanged;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ScrollController? scrollController;

  const ExpandableAddInsSection({
    Key? key,
    required this.addIns,
    required this.onAddInsChanged,
    required this.isExpanded,
    required this.onToggle,
    this.scrollController,
  }) : super(key: key);

  @override
  State<ExpandableAddInsSection> createState() => _ExpandableAddInsSectionState();
}

class _ExpandableAddInsSectionState extends State<ExpandableAddInsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisible());
    }
  }

  @override
  void didUpdateWidget(ExpandableAddInsSection oldWidget) {
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
        
        final targetScroll = widget.scrollController!.position.pixels + 
                           position.dy - 
                           120;
        
        widget.scrollController!.animateTo(
          targetScroll.clamp(
            0.0,
            widget.scrollController!.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Add-ins button always visible at the top
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
                    Icons.extension,
                    color: Colors.white,
                    size: Tween<double>(begin: 28, end: 32)
                        .evaluate(_sizeAnimation),
                  );
                },
              ),
              onPressed: () {
                widget.onToggle();
                if (!widget.isExpanded) {
                  _ensureVisible();
                }
              },
            ),
          ),
        ),
        // Animated add-ins content
        ClipRect(
          child: SizeTransition(
            sizeFactor: _sizeAnimation,
            axisAlignment: -1,
            child: Container(
              key: _contentKey,
              child: ProfileAddInsView(
                addIns: widget.addIns,
                onAddInsChanged: widget.onAddInsChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
