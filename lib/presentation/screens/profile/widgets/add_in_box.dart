import 'package:flutter/material.dart';
import '../../../../data/models/profile_addins_model.dart';
import 'add_in_box_components.dart';

class AddInBox extends StatefulWidget {
  final AddInItem addIn;
  final VoidCallback onGet;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const AddInBox({
    Key? key,
    required this.addIn,
    required this.onGet,
    required this.isExpanded,
    required this.onToggleExpand,
  }) : super(key: key);

  @override
  State<AddInBox> createState() => _AddInBoxState();
}

class _AddInBoxState extends State<AddInBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AddInBox oldWidget) {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final isExpanded = widget.isExpanded;
            final scale = 1.0 + (_scaleAnimation.value * 0.1);
            final elevation = 2.0 + (_scaleAnimation.value * 6.0);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: isExpanded ? MediaQuery.of(context).size.width * 0.8 : 140,
                constraints: BoxConstraints(
                  minHeight: 180,
                  maxHeight: isExpanded ? MediaQuery.of(context).size.height * 0.5 : 180,
                ),
                margin: isExpanded ? EdgeInsets.zero : const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: elevation,
                      spreadRadius: elevation / 2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        physics: isExpanded
                            ? null
                            : const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AddInHeader(
                                addIn: widget.addIn,
                                isExpanded: isExpanded,
                              ),
                              if (isExpanded)
                                AddInFeatures(addIn: widget.addIn),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AddInFooter(
                      onPressed: () {
                        if (!isExpanded) {
                          widget.onToggleExpand();
                        }
                        widget.onGet();
                      },
                      isExpanded: isExpanded,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
