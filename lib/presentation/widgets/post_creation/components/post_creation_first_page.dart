import 'package:flutter/material.dart';
import 'package:myapp/presentation/widgets/common/shadowed_text.dart';
import 'package:myapp/presentation/widgets/common/shadowed_shape.dart';
import 'package:myapp/presentation/widgets/common/add_hexagon_icon.dart';
import 'package:myapp/presentation/widgets/post_creation/components/ai_button_shape.dart';

class PostCreationFirstPage extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool isLoading;
  final VoidCallback onAddStep;
  final List<Widget> steps;
  final PageController pageController;

  const PostCreationFirstPage({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.isLoading,
    required this.onAddStep,
    required this.steps,
    required this.pageController,
  }) : super(key: key);

  @override
  State<PostCreationFirstPage> createState() => _PostCreationFirstPageState();
}

class _PostCreationFirstPageState extends State<PostCreationFirstPage> {
  bool _titleHasText = false;
  bool _descriptionHasText = false;

  @override
  void initState() {
    super.initState();
    widget.titleController.addListener(_updateTitleState);
    widget.descriptionController.addListener(_updateDescriptionState);
  }

  @override
  void dispose() {
    widget.titleController.removeListener(_updateTitleState);
    widget.descriptionController.removeListener(_updateDescriptionState);
    super.dispose();
  }

  void _updateTitleState() {
    final hasText = widget.titleController.text.isNotEmpty;
    if (hasText != _titleHasText) {
      setState(() {
        _titleHasText = hasText;
      });
    }
  }

  void _updateDescriptionState() {
    final hasText = widget.descriptionController.text.isNotEmpty;
    if (hasText != _descriptionHasText) {
      setState(() {
        _descriptionHasText = hasText;
      });
    }
  }

  Widget _buildActionButton({
    required Widget Function() iconBuilder,
    required VoidCallback onPressed,
    String? label,
    bool isLarger = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconBuilder(),
          if (label != null) ...[
            const SizedBox(height: 4),
            ShadowedText(
              text: label,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              shadowOpacity: 0.35,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextFormField(
                controller: widget.titleController,
                enabled: !widget.isLoading,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 3,
                      color: Colors.black,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                decoration: InputDecoration(
                  label: _titleHasText
                      ? null
                      : const Center(
                          child: ShadowedText(
                            text: 'Title',
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _titleHasText
                              ? Colors.transparent
                              : Colors.white30)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _titleHasText
                              ? Colors.transparent
                              : Colors.white30)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              _titleHasText ? Colors.transparent : Colors.white)),
                  hintText: 'Title of Task',
                  hintStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextFormField(
                controller: widget.descriptionController,
                enabled: !widget.isLoading,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 3,
                      color: Colors.black,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                decoration: InputDecoration(
                  label: _descriptionHasText
                      ? null
                      : const Center(
                          child: ShadowedText(
                            text: 'Description',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _descriptionHasText
                              ? Colors.transparent
                              : Colors.white30)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _descriptionHasText
                              ? Colors.transparent
                              : Colors.white30)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: _descriptionHasText
                              ? Colors.transparent
                              : Colors.white)),
                  hintText: 'short summary of the goal',
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 3,
                        color: Colors.black,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 140),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(200),
                bottomRight: Radius.circular(200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  iconBuilder: () => ShadowedShape(
                    icon: Icons.settings,
                    size: 24,
                    shadowOpacity: 0.2,
                  ),
                  onPressed: () {
                    // TODO: Implement settings action
                  },
                  label: 'Settings',
                ),
                Transform.translate(
                  offset: const Offset(0, 30),
                  child: _buildActionButton(
                    iconBuilder: () => AIButtonShape(
                      icon: Icons.auto_awesome,
                      size: 48,
                    ),
                    onPressed: () {
                      widget.pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    label: 'AI',
                    isLarger: true,
                  ),
                ),
                _buildActionButton(
                  iconBuilder: () => widget.steps.isEmpty
                      ? AddHexagonIcon(
                          size: 24,
                          shadowOpacity: 0.2,
                        )
                      : ShadowedShape(
                          icon: Icons.format_list_numbered,
                          size: 24,
                          shadowOpacity: 0.2,
                        ),
                  onPressed: widget.steps.isEmpty
                      ? widget.onAddStep
                      : () {
                          if (widget.steps.isNotEmpty) {
                            widget.pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                  label: widget.steps.isEmpty ? 'Add Step' : 'Steps',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
