import 'package:flutter/material.dart';
import 'package:myapp/presentation/widgets/common/shadowed_text.dart';
import 'package:myapp/presentation/widgets/common/shadowed_shape.dart';
import 'package:myapp/presentation/widgets/common/add_hexagon_icon.dart';
import 'package:myapp/presentation/widgets/post_creation/components/ai_button_with_mic.dart';

class PostCreationFirstPage extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool isLoading;
  final VoidCallback onAddStep;
  final VoidCallback? onAIRequest;
  final List<Widget> steps;
  final PageController pageController;
  final Function(bool isHighlighted, Animation<double>? animation)?
      onTargetHighlightChanged;

  const PostCreationFirstPage({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.isLoading,
    required this.onAddStep,
    this.onAIRequest,
    required this.steps,
    required this.pageController,
    this.onTargetHighlightChanged,
  }) : super(key: key);

  @override
  State<PostCreationFirstPage> createState() => _PostCreationFirstPageState();
}

class _PostCreationFirstPageState extends State<PostCreationFirstPage>
    with TickerProviderStateMixin {
  bool _titleHasText = false;
  bool _descriptionHasText = false;
  bool _isSettingsEnlarged = false;
  DateTime? _dueDateTime;
  String _backgroundType = 'color';
  bool _responseVisibility = false;
  bool _completionLimit = false;

  // Animation controllers and animations
  late AnimationController _settingsAnimationController;
  late Animation<double> _settingsScaleAnimation;
  late Animation<double> _settingsHeightAnimation;

  // New state variables for AI button and highlighting
  bool _isAIHighlighted = false;
  int _currentHighlightIndex = -1;
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;
  String _aiButtonText = 'AI';

  // Colors for the highlight animation sequence
  final List<Color> _highlightColors = [
    Colors.purple,
    Colors.yellow,
    Colors.blue,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    widget.titleController.addListener(_updateTitleState);
    widget.descriptionController.addListener(_updateDescriptionState);

    _settingsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _settingsScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _settingsAnimationController,
      curve: Curves.elasticOut,
    ));

    _settingsHeightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _settingsAnimationController,
      curve: Curves.easeOutBack,
    ));

    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _highlightAnimation = CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOutCubic,
    );

    _highlightController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        if (_currentHighlightIndex < 3) {
          setState(() {
            _currentHighlightIndex++;
            // Update text based on what we're about to highlight
            if (_currentHighlightIndex == 0 || _currentHighlightIndex == 1) {
              _aiButtonText = 'checking task';
            } else if (_currentHighlightIndex == 2) {
              _aiButtonText = 'checking settings';
            } else if (_currentHighlightIndex == 3) {
              _aiButtonText = 'checking steps';
            }
          });

          _highlightController.reset();
          _highlightController.forward();
        } else if (_currentHighlightIndex == 3) {
          // After highlighting Steps, trigger target highlight with animation
          widget.onTargetHighlightChanged?.call(true, _highlightAnimation);
          _highlightController.repeat(reverse: true);
          setState(() {
            _aiButtonText = 'checking target';
          });

          // Clean up target highlight after 2 seconds and start AI highlight
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted) {
              widget.onTargetHighlightChanged?.call(false, null);
              _highlightController.stop();

              // Start AI highlight sequence
              setState(() {
                _isAIHighlighted = true;
                _currentHighlightIndex = -1; // Reset highlight index
                _aiButtonText = 'hold to speak';
              });
              widget.onAIRequest?.call();

              // Turn off AI button highlight after 5 seconds
              Future.delayed(const Duration(milliseconds: 5000), () {
                if (mounted) {
                  setState(() {
                    _isAIHighlighted = false;
                    _aiButtonText = 'AI';
                  });
                }
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // Clean up target highlight when disposing
    widget.onTargetHighlightChanged?.call(false, null);
    widget.titleController.removeListener(_updateTitleState);
    widget.descriptionController.removeListener(_updateDescriptionState);
    _settingsAnimationController.dispose();
    _highlightController.dispose();
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

  void _handleAIButtonPress() {
    if (_highlightController.isAnimating) {
      // If animation is running, stop it and clean up
      _highlightController.stop();
      widget.onTargetHighlightChanged?.call(false, null);
    }
    setState(() {
      _currentHighlightIndex =
          -1; // Start at -1 since we increment before highlighting
      _aiButtonText = 'checking task';
    });
    _highlightController.forward();
  }

  void _handleStepsButtonPress() {
    if (widget.steps.isNotEmpty) {
      widget.pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onAddStep();
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

  Widget _buildHighlightBorder(Widget child, int index) {
    final isHighlighted = _currentHighlightIndex == index;
    return Stack(
      children: [
        child,
        if (isHighlighted)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _highlightAnimation,
              builder: (context, child) {
                final currentColor = _highlightColors[index];
                final nextColor =
                    _highlightColors[(index + 1) % _highlightColors.length];

                // Use circular shape for settings, steps, and target buttons
                final bool useCircularShape = index == 2 || index == 3;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.lerp(
                        currentColor,
                        nextColor,
                        _highlightAnimation.value,
                      )!
                          .withOpacity(0.8),
                      width: 4.0,
                    ),
                    shape:
                        useCircularShape ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius:
                        useCircularShape ? null : BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: currentColor
                            .withOpacity(0.3 * _highlightAnimation.value),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFormFields() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        top: _isSettingsEnlarged ? 24 : 0,
        bottom: _isSettingsEnlarged ? 24 : 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildHighlightBorder(
              TextFormField(
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
                          color: _titleHasText
                              ? Colors.transparent
                              : Colors.white)),
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
              0,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildHighlightBorder(
              TextFormField(
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
              1,
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
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          transform: Matrix4.translationValues(0, -12, 0),
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
                                child: _buildHighlightBorder(
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Opacity(
                                        opacity: 0.45,
                                        child: ShadowedText(
                                          text: 'TASK SETTINGS',
                                          fontSize: 28,
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.white,
                                        ),
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
                                                final time =
                                                    await showTimePicker(
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
                                  2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height - 180,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    transform: Matrix4.translationValues(0, -35, 0),
                    child: Center(child: _buildFormFields()),
                  ),
                ),
        ),
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
                          _buildHighlightBorder(
                            _buildActionButton(
                              iconBuilder: () => AnimatedBuilder(
                                animation: _settingsScaleAnimation,
                                builder: (context, child) => Transform.scale(
                                  scale: _settingsScaleAnimation.value,
                                  child: Transform.rotate(
                                    angle: _settingsAnimationController.value *
                                        -1.0,
                                    child: ShadowedShape(
                                      icon: Icons.settings,
                                      size: 24,
                                      shadowOpacity: 0.2,
                                    ),
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
                            2,
                          ),
                        if (!_isSettingsEnlarged) ...[
                          Transform.translate(
                            offset: const Offset(0, 30),
                            child: _buildActionButton(
                              iconBuilder: () => AIButtonWithMic(
                                size: 48,
                                isHighlighted: _isAIHighlighted,
                                onPressed: _handleAIButtonPress,
                              ),
                              onPressed: _handleAIButtonPress,
                              label: _aiButtonText,
                              isLarger: true,
                            ),
                          ),
                          _buildHighlightBorder(
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
                              onPressed: _handleStepsButtonPress,
                              label:
                                  widget.steps.isEmpty ? 'Add Step' : 'Steps',
                            ),
                            3,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
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
                          child: Transform.rotate(
                            angle: _settingsAnimationController.value * -1.0,
                            child: ShadowedShape(
                              icon: Icons.settings,
                              size: 24,
                              shadowOpacity: 0.2,
                            ),
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
