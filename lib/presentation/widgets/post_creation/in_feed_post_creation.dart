import 'package:flutter/material.dart';
import '../../widgets/common/glass_container.dart';
import '../../../../core/di/injection.dart';
import '../../../../data/models/step_type_model.dart';
import '../../../../domain/repositories/step_type_repository.dart';
import './post_step_widget.dart';
import './components/post_creation_first_page.dart';
import './components/hexagon_step_selector.dart';
import './components/post_creation_navigation.dart';
import './components/post_creation_step_button.dart';
import './components/post_creation_cancel_button.dart';
import './models/post_creation_state.dart';
import './controllers/in_feed_post_creation_controller.dart';

class InFeedPostCreation extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(bool success) onComplete;
  final Function(bool isHighlighted, Animation<double>? animation)? onTargetHighlightChanged;
  final VoidCallback? onAIRequest;  // New callback for AI functionality

  const InFeedPostCreation({
    super.key,
    required this.onCancel,
    required this.onComplete,
    this.onTargetHighlightChanged,
    this.onAIRequest,
  });

  static PostCreationController? of(BuildContext context) {
    final state = context.findRootAncestorStateOfType<InFeedPostCreationState>();
    if (state == null) return null;
    return LegacyPostCreationController(state);
  }

  @override
  State<InFeedPostCreation> createState() => InFeedPostCreationState();
}

class LegacyPostCreationController implements PostCreationController {
  final InFeedPostCreationState _state;

  LegacyPostCreationController(this._state);

  @override
  Future<List<StepTypeModel>> loadStepTypes() {
    return _state._controller.loadStepTypes();
  }

  @override
  Future<void> save([PostCreationState? state]) {
    return _state._save();
  }
}

class InFeedPostCreationState extends State<InFeedPostCreation> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pageController = PageController();
  late final PostCreationController _controller;

  late PostCreationState _state;

  void _handleAIRequest() {
    // Get current title and description
    final title = _titleController.text;
    final description = _descriptionController.text;

    // Call the AI request callback
    widget.onAIRequest?.call();
  }

  @override
  void initState() {
    super.initState();
    _controller = DefaultPostCreationController(
      context: context,
      titleController: _titleController,
      descriptionController: _descriptionController,
      formKey: _formKey,
      onComplete: widget.onComplete,
    );

    _state = PostCreationState(
      stepKeys: [],
      steps: [],
      availableStepTypes: [],
      isLoading: false,
      currentPage: 0,
    );
    _loadStepTypes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadStepTypes() async {
    try {
      final types = await _controller.loadStepTypes();
      setState(() {
        _state = _state.copyWith(availableStepTypes: types);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load step types: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addStep() {
    if (_state.steps.isEmpty ||
        _state.stepKeys.last.currentState?.hasSelectedStepType == true) {
      final stepKey = GlobalKey<PostStepWidgetState>();
      final newStep = PostStepWidget(
        key: stepKey,
        onRemove: () => _removeStep(_state.steps.length - 1),
        stepNumber: _state.steps.length + 1,
        enabled: !_state.isLoading,
        stepTypes: _state.availableStepTypes,
        initialStepType: null,
        showFormInitially: false,
      );

      setState(() {
        _state = _state.copyWith(
          stepKeys: [..._state.stepKeys, stepKey],
          steps: [..._state.steps, newStep],
        );
      });

      _pageController.animateToPage(
        _state.steps.length,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        _state.steps.length,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _removeStep(int index) {
    if (index == _state.currentPage - 1) {
      _pageController
          .previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      )
          .then((_) {
        if (mounted) {
          _updateStepsAfterRemoval(index);
        }
      });
    } else {
      _updateStepsAfterRemoval(index);
    }
  }

  void _updateStepsAfterRemoval(int index) {
    final newSteps = List<PostStepWidget>.from(_state.steps);
    final newStepKeys = List<GlobalKey<PostStepWidgetState>>.from(_state.stepKeys);

    final stepStates = <int, Map<String, dynamic>>{};
    for (var i = 0; i < newSteps.length; i++) {
      if (i == index) continue;
      final state = (newSteps[i].key as GlobalKey<PostStepWidgetState>).currentState;
      if (state != null) {
        stepStates[i > index ? i - 1 : i] = {
          'stepType': state.getSelectedStepType(),
          'showForm': state.hasSelectedStepType,
        };
      }
    }

    newSteps.removeAt(index);
    newStepKeys.removeAt(index);

    for (var i = 0; i < newSteps.length; i++) {
      final stepKey = GlobalKey<PostStepWidgetState>();
      newStepKeys[i] = stepKey;
      newSteps[i] = PostStepWidget(
        key: stepKey,
        onRemove: () => _removeStep(i),
        stepNumber: i + 1,
        enabled: !_state.isLoading,
        stepTypes: _state.availableStepTypes,
        initialStepType: stepStates[i]?['stepType'] as StepTypeModel?,
        showFormInitially: stepStates[i]?['showForm'] as bool? ?? false,
      );
    }

    setState(() {
      _state = _state.copyWith(
        steps: newSteps,
        stepKeys: newStepKeys,
      );
    });
  }

  void _handleCancelButtonPress() {
    if (_state.isFirstPage) {
      widget.onCancel();
      return;
    }

    if (_state.currentPage == 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    final stepState = _state.stepKeys[_state.currentPage - 2].currentState;
    if (stepState != null && stepState.hasSelectedStepType) {
      setState(() {
        final stepKey = GlobalKey<PostStepWidgetState>();
        final newStepKeys = List<GlobalKey<PostStepWidgetState>>.from(_state.stepKeys);
        final newSteps = List<PostStepWidget>.from(_state.steps);

        newStepKeys[_state.currentPage - 2] = stepKey;
        newSteps[_state.currentPage - 2] = PostStepWidget(
          key: stepKey,
          onRemove: () => _removeStep(_state.currentPage - 2),
          stepNumber: _state.currentPage - 1,
          enabled: !_state.isLoading,
          stepTypes: _state.availableStepTypes,
          initialStepType: null,
          showFormInitially: false,
        );

        _state = _state.copyWith(
          stepKeys: newStepKeys,
          steps: newSteps,
        );
      });
    } else {
      _removeStep(_state.currentPage - 2);
    }
  }

  Future<void> _save() async {
    setState(() {
      _state = _state.copyWith(isLoading: true);
    });

    try {
      await _controller.save(_state);
    } finally {
      if (mounted) {
        setState(() {
          _state = _state.copyWith(isLoading: false);
        });
      }
    }
  }

  Widget _buildContent(double size) {
    return Container(
      margin: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 35,
              spreadRadius: 8,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 25,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: GlassContainer(
          isCircular: true,
          borderGradientColors: const [],
          gradientColors: const [
            Color.fromRGBO(255, 255, 255, 0.5),
            Color.fromRGBO(255, 255, 255, 0.1),
          ],
          child: SizedBox(
            width: size,
            height: size,
            child: ClipOval(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _state = _state.copyWith(currentPage: index);
                    });
                  },
                  children: [
                    PostCreationFirstPage(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      isLoading: _state.isLoading,
                      onAddStep: _addStep,
                      onAIRequest: _handleAIRequest,
                      steps: _state.steps,
                      pageController: _pageController,
                      onTargetHighlightChanged: widget.onTargetHighlightChanged,
                    ),
                    HexagonStepSelector(
                      stepTypeRepository: getIt<StepTypeRepository>(),
                      onStepFormSubmitted: (stepType, formData) {
                        final stepKey = GlobalKey<PostStepWidgetState>();
                        final newStep = PostStepWidget(
                          key: stepKey,
                          onRemove: () => _removeStep(_state.steps.length - 1),
                          stepNumber: _state.steps.length + 1,
                          enabled: !_state.isLoading,
                          stepTypes: _state.availableStepTypes,
                          initialStepType: stepType,
                          showFormInitially: true,
                        );

                        setState(() {
                          _state = _state.copyWith(
                            stepKeys: [..._state.stepKeys, stepKey],
                            steps: [..._state.steps, newStep],
                          );
                        });

                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    ..._state.steps,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width - 32;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        return true;
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildContent(size),
          if (_state.isFirstPage)
            PostCreationCancelButton(
              isLoading: _state.isLoading,
              onCancel: widget.onCancel,
            ),
          PostCreationNavigation(
            currentPage: _state.currentPage,
            stepsCount: _state.steps.length,
            pageController: _pageController,
            onAddStep: _addStep,
          ),
          if (!_state.isFirstPage)
            PostCreationStepButton(
              isLoading: _state.isLoading,
              onPressed: _handleCancelButtonPress,
              hasSelectedStepType: _state.hasSelectedStepType,
            ),
        ],
      ),
    );
  }
}
