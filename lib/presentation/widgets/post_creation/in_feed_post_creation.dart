import 'package:flutter/material.dart';
import '../../widgets/common/glass_container.dart';
import '../../../../data/models/step_type_model.dart';
import './post_step_widget.dart';
import './components/post_creation_first_page.dart';
import './components/post_creation_navigation.dart';
import './components/post_creation_step_button.dart';
import './components/post_creation_cancel_button.dart';
import './models/post_creation_state.dart';
import './controllers/in_feed_post_creation_controller.dart';

class InFeedPostCreation extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(bool success) onComplete;

  const InFeedPostCreation({
    super.key,
    required this.onCancel,
    required this.onComplete,
  });

  static PostCreationController? of(BuildContext context) {
    final state =
        context.findRootAncestorStateOfType<InFeedPostCreationState>();
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
    if (_state.steps.isEmpty || _state.stepKeys.last.currentState?.hasSelectedStepType == true) {
      final stepKey = GlobalKey<PostStepWidgetState>();
      final newStep = PostStepWidget(
        key: stepKey,
        onRemove: () => _removeStep(_state.steps.length - 1),
        stepNumber: _state.steps.length + 1,
        enabled: !_state.isLoading,
        stepTypes: _state.availableStepTypes,
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
      // If the last step hasn't had a type selected yet, just navigate to it
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
    final newStepKeys =
        List<GlobalKey<PostStepWidgetState>>.from(_state.stepKeys);

    newSteps.removeAt(index);
    newStepKeys.removeAt(index);

    // Update step numbers
    for (var i = 0; i < newSteps.length; i++) {
      final stepKey = GlobalKey<PostStepWidgetState>();
      newStepKeys[i] = stepKey;
      newSteps[i] = PostStepWidget(
        key: stepKey,
        onRemove: () => _removeStep(i),
        stepNumber: i + 1,
        enabled: !_state.isLoading,
        stepTypes: _state.availableStepTypes,
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

    final stepState = _state.stepKeys[_state.currentPage - 1].currentState;
    if (stepState != null && stepState.hasSelectedStepType) {
      // If a step type is selected, reset to honeycomb grid
      setState(() {
        final stepKey = GlobalKey<PostStepWidgetState>();
        final newStepKeys =
            List<GlobalKey<PostStepWidgetState>>.from(_state.stepKeys);
        final newSteps = List<PostStepWidget>.from(_state.steps);

        newStepKeys[_state.currentPage - 1] = stepKey;
        newSteps[_state.currentPage - 1] = PostStepWidget(
          key: stepKey,
          onRemove: () => _removeStep(_state.currentPage - 1),
          stepNumber: _state.currentPage,
          enabled: !_state.isLoading,
          stepTypes: _state.availableStepTypes,
        );

        _state = _state.copyWith(
          stepKeys: newStepKeys,
          steps: newSteps,
        );
      });
    } else {
      // If no step type selected yet, remove the step and go back
      _removeStep(_state.currentPage - 1);
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
      margin: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
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
            child: Form(
              key: _formKey,
              child: Center(
                child: SizedBox(
                  width: size * 0.8,
                  height: size * 0.8,
                  child: PageView(
                    controller: _pageController,
                    physics: const ClampingScrollPhysics(), // Allow sliding back
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
                        steps: _state.steps,
                        pageController: _pageController,
                      ),
                      ..._state.steps.map((step) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 40),
                                  step,
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
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
    return Stack(
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
    );
  }
}
