import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/step_type_repository.dart';
import '../../../data/models/post_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import './post_step_widget.dart';
import './components/post_creation_first_page.dart';
import './components/post_creation_navigation.dart';
import './components/post_creation_step_button.dart';
import './components/post_creation_cancel_button.dart';
import './models/post_creation_state.dart';

abstract class InFeedPostCreationController {
  Future<void> save();
}

class InFeedPostCreation extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(bool success) onComplete;

  const InFeedPostCreation({
    super.key,
    required this.onCancel,
    required this.onComplete,
  });

  static InFeedPostCreationController? of(BuildContext context) {
    final state = context.findRootAncestorStateOfType<InFeedPostCreationState>();
    return state;
  }

  @override
  State<InFeedPostCreation> createState() => InFeedPostCreationState();
}

class InFeedPostCreationState extends State<InFeedPostCreation>
    implements InFeedPostCreationController {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _postRepository = getIt<PostRepository>();
  final _stepTypeRepository = getIt<StepTypeRepository>();
  final _pageController = PageController();
  
  late PostCreationState _state;

  @override
  void initState() {
    super.initState();
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
      final types = await _stepTypeRepository.getStepTypes();
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
      // Reset step type selection to allow choosing a different type
      setState(() {
        final stepKey = GlobalKey<PostStepWidgetState>();
        final newStepKeys = List<GlobalKey<PostStepWidgetState>>.from(_state.stepKeys);
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
      _removeStep(_state.currentPage - 1);
    }
  }

  @override
  Future<void> save() async {
    if (!_state.hasSteps) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one step'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate() || !_state.validateSteps()) {
      return;
    }

    setState(() {
      _state = _state.copyWith(isLoading: true);
    });

    try {
      final authState = context.read<AuthBloc>().state;
      if (!authState.isAuthenticated || authState.userId == null) {
        throw Exception('User not authenticated');
      }

      final steps = _state.getValidSteps();

      final post = PostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: authState.userId!,
        username: authState.username ?? 'Anonymous',
        userProfileImage: 'https://i.pravatar.cc/150?u=${authState.userId}',
        title: _titleController.text,
        description: _descriptionController.text,
        steps: steps,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likes: [],
        comments: [],
        status: PostStatus.active,
        targetingCriteria: null,
        aiMetadata: {
          'tags': ['tutorial', 'multi-step'],
          'category': 'tutorial',
        },
        ratings: [],
        userTraits: [],
      );

      await _postRepository.createPost(post);
      if (mounted) {
        widget.onComplete(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: Colors.red,
          ),
        );
        widget.onComplete(false);
      }
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
      child: ClipOval(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.15),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 35,
                spreadRadius: 8,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Center(
              child: SizedBox(
                width: size * 0.8,
                height: size * 0.8,
                child: PageView(
                  controller: _pageController,
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
