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

class _PostCreationFirstPageState extends State<PostCreationFirstPage>
    with SingleTickerProviderStateMixin {
  bool _titleHasText = false;
  bool _descriptionHasText = false;
  bool _isSettingsEnlarged = false;
  DateTime? _dueDateTime;
  String _backgroundType = 'color';
  bool _responseVisibility = false;
  bool _completionLimit = false;
  late AnimationController _settingsAnimationController;
  late Animation<double> _settingsScaleAnimation;
  late Animation<double> _settingsHeightAnimation;

  @override
  void initState() {
    super.initState();
    widget.titleController.addListener(_updateTitleState);
    widget.descriptionController.addListener(_updateDescriptionState);

    _settingsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _settingsScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _settingsAnimationController,
      curve: Curves.easeInOut,
    ));

    _settingsHeightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _settingsAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    widget.titleController.removeListener(_updateTitleState);
    widget.descriptionController.removeListener(_updateDescriptionState);
    _settingsAnimationController.dispose();
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

  Widget _buildFormFields() {
    return Padding(
      padding: EdgeInsets.only(
        top: _isSettingsEnlarged ? 24 : 0,
        bottom: _isSettingsEnlarged ? 24 : 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // Prevent scroll events from propagating to parent
            return true;
          },
          child: _isSettingsEnlarged
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -12),
                          child: _buildFormFields(),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: SizeTransition(
                            sizeFactor: _settingsHeightAnimation,
                            child: FadeTransition(
                              opacity: _settingsHeightAnimation,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ShadowedText(
                                      text: 'Post Settings',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      textColor: Colors.grey[700]!,
                                    ),
                                    const SizedBox(height: 16),
                                    // Due Date/Time
                                    Column(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            color: Colors.white, size: 28),
                                        const SizedBox(height: 8),
                                        const ShadowedText(
                                          text: 'Due Date/Time',
                                          fontSize: 16,
                                        ),
                                        const SizedBox(height: 12),
                                        GestureDetector(
                                          onTap: () async {
                                            final date = await showDatePicker(
                                              context: context,
                                              initialDate: _dueDateTime ??
                                                  DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime.now().add(
                                                  const Duration(days: 365)),
                                            );
                                            if (date != null) {
                                              final time = await showTimePicker(
                                                context: context,
                                                initialTime:
                                                    TimeOfDay.fromDateTime(
                                                        _dueDateTime ??
                                                            DateTime.now()),
                                              );
                                              if (time != null) {
                                                setState(() {
                                                  _dueDateTime = DateTime(
                                                    date.year,
                                                    date.month,
                                                    date.day,
                                                    time.hour,
                                                    time.minute,
                                                  );
                                                });
                                              }
                                            }
                                          },
                                          child: ShadowedText(
                                            text: _dueDateTime?.toString() ??
                                                'Not set',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(color: Colors.white30),
                                    // Background Customization
                                    Column(
                                      children: [
                                        const Icon(Icons.palette,
                                            color: Colors.white, size: 28),
                                        const SizedBox(height: 8),
                                        const ShadowedText(
                                          text: 'Background Type',
                                          fontSize: 16,
                                        ),
                                        const SizedBox(height: 12),
                                        DropdownButton<String>(
                                          value: _backgroundType,
                                          dropdownColor: Colors.black87,
                                          underline: Container(
                                            height: 1,
                                            color: Colors.white30,
                                          ),
                                          style: const TextStyle(
                                              color: Colors.white),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                _backgroundType = newValue;
                                              });
                                            }
                                          },
                                          items: <String>[
                                            'color',
                                            'image',
                                            'video'
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: ShadowedText(
                                                text: value
                                                        .substring(0, 1)
                                                        .toUpperCase() +
                                                    value.substring(1),
                                                fontSize: 14,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                    const Divider(color: Colors.white30),
                                    // Response Visibility Toggle
                                    Column(
                                      children: [
                                        const Icon(Icons.visibility,
                                            color: Colors.white, size: 28),
                                        const SizedBox(height: 8),
                                        const ShadowedText(
                                          text:
                                              'Respondents see other responses',
                                          fontSize: 16,
                                        ),
                                        const SizedBox(height: 12),
                                        Switch(
                                          value: _responseVisibility,
                                          onChanged: (bool value) {
                                            setState(() {
                                              _responseVisibility = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const Divider(color: Colors.white30),
                                    // Completion Limit Toggle
                                    Column(
                                      children: [
                                        const Icon(Icons.lock_clock,
                                            color: Colors.white, size: 28),
                                        const SizedBox(height: 8),
                                        const ShadowedText(
                                          text: 'Complete only once',
                                          fontSize: 16,
                                        ),
                                        const SizedBox(height: 12),
                                        Switch(
                                          value: _completionLimit,
                                          onChanged: (bool value) {
                                            setState(() {
                                              _completionLimit = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height - 180,
                  child: Transform.translate(
                    offset: const Offset(0, -35),
                    child: Center(child: _buildFormFields()),
                  ),
                ),
        ),
        // Bottom container with IgnorePointer
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Stack(
            children: [
              IgnorePointer(
                ignoring: _isSettingsEnlarged,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    // Forward vertical drag to the SingleChildScrollView
                    final scrollable = PrimaryScrollController.of(context);
                    if (scrollable != null) {
                      scrollable.position.jumpTo(
                        scrollable.position.pixels - details.delta.dy,
                      );
                    }
                  },
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
                      mainAxisAlignment: _isSettingsEnlarged
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.spaceEvenly,
                      children: [
                        if (_isSettingsEnlarged)
                          const SizedBox(width: 72)
                        else
                          _buildActionButton(
                            iconBuilder: () => AnimatedBuilder(
                              animation: _settingsScaleAnimation,
                              builder: (context, child) => Transform.scale(
                                scale: _settingsScaleAnimation.value,
                                child: ShadowedShape(
                                  icon: Icons.settings,
                                  size: 24,
                                  shadowOpacity: 0.2,
                                ),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isSettingsEnlarged = !_isSettingsEnlarged;
                                if (_isSettingsEnlarged) {
                                  _settingsAnimationController.forward();
                                } else {
                                  _settingsAnimationController.reverse();
                                }
                              });
                            },
                            label: _isSettingsEnlarged ? null : 'Settings',
                          ),
                        if (!_isSettingsEnlarged) ...[
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
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                            label: widget.steps.isEmpty ? 'Add Step' : 'Steps',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              // Settings button when expanded
              if (_isSettingsEnlarged)
                Positioned(
                  left: 24,
                  child: Container(
                    height: 180,
                    alignment: Alignment.centerLeft,
                    child: _buildActionButton(
                      iconBuilder: () => AnimatedBuilder(
                        animation: _settingsScaleAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _settingsScaleAnimation.value,
                          child: ShadowedShape(
                            icon: Icons.settings,
                            size: 24,
                            shadowOpacity: 0.2,
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isSettingsEnlarged = !_isSettingsEnlarged;
                          if (_isSettingsEnlarged) {
                            _settingsAnimationController.forward();
                          } else {
                            _settingsAnimationController.reverse();
                          }
                        });
                      },
                      label: null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
