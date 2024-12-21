import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/step_type_model.dart';
import '../../../domain/repositories/step_type_repository.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/post_creation/post_step_widget.dart';
import 'managers/post_creation_manager.dart';
import 'models/targeting_criteria_builder.dart';
import 'widgets/post_form_fields.dart';
import 'widgets/project_button.dart';
import 'widgets/project_selection_dialog.dart';
import 'widgets/steps_section.dart';
import 'widgets/targeting_fields.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _interestsController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _locationsController = TextEditingController();
  final _languagesController = TextEditingController();
  final _skillsController = TextEditingController();
  final _industriesController = TextEditingController();
  String? _selectedExperienceLevel;
  
  final List<PostStepWidget> _steps = [];
  final _manager = PostCreationManager();
  final _stepTypeRepository = getIt<StepTypeRepository>();
  bool _isLoading = false;
  List<StepTypeModel> _availableStepTypes = [];
  List<ProjectModel> _userProjects = [];
  ProjectModel? _selectedProject;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState.isAuthenticated && authState.userId != null) {
        // Load projects and step types in parallel
        final results = await Future.wait([
          _manager.loadUserProjects(authState.userId!),
          _stepTypeRepository.getStepTypes(),
        ]);

        if (mounted) {
          setState(() {
            _userProjects = results[0] as List<ProjectModel>;
            _availableStepTypes = results[1] as List<StepTypeModel>;
          });
        }
      }
    } catch (e) {
      _showError('Failed to load initial data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _addStep(StepTypeModel type) {
    setState(() {
      _steps.add(PostStepWidget(
        key: GlobalKey<PostStepWidgetState>(),
        onRemove: () => _removeStep(_steps.length - 1),
        stepNumber: _steps.length + 1,
        enabled: !_isLoading,
        stepTypes: [type, ..._availableStepTypes.where((t) => t.id != type.id)],
      ));
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      for (var i = 0; i < _steps.length; i++) {
        _steps[i] = PostStepWidget(
          key: GlobalKey<PostStepWidgetState>(),
          onRemove: () => _removeStep(i),
          stepNumber: i + 1,
          enabled: !_isLoading,
          stepTypes: _availableStepTypes,
        );
      }
    });
  }

  Future<void> _showProjectDialog() async {
    final authState = context.read<AuthBloc>().state;
    if (!authState.isAuthenticated || authState.userId == null) {
      _showError('Please log in to add projects');
      return;
    }

    final result = await showDialog<ProjectModel?>(
      context: context,
      builder: (context) => ProjectSelectionDialog(
        userProjects: _userProjects,
        userId: authState.userId!,
        onProjectCreated: (project) async {
          await _manager.createProject(project);
        },
      ),
    );

    if (result != null) {
      setState(() {
        if (!_userProjects.any((p) => p.id == result.id)) {
          _userProjects = [..._userProjects, result];
        }
        _selectedProject = result;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post will be added to "${result.name}"')),
        );
      }
    }
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (!authState.isAuthenticated || authState.userId == null) {
        throw Exception('User not authenticated');
      }

      final steps = _steps
          .map((stepWidget) => stepWidget.toPostStep())
          .where((step) => step != null)
          .cast<PostStep>()
          .toList();

      if (steps.isEmpty) {
        throw Exception('Please add at least one step');
      }

      final targetingCriteria = TargetingCriteriaBuilder.build(
        interests: _interestsController.text,
        locations: _locationsController.text,
        languages: _languagesController.text,
        skills: _skillsController.text,
        industries: _industriesController.text,
        minAge: _minAgeController.text,
        maxAge: _maxAgeController.text,
        experienceLevel: _selectedExperienceLevel,
      );

      final post = _manager.createPostModel(
        userId: authState.userId!,
        username: authState.username,
        title: _titleController.text,
        description: _descriptionController.text,
        steps: steps,
        targetingCriteria: targetingCriteria,
      );

      await _manager.savePost(
        post: post,
        selectedProject: _selectedProject,
        onSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_selectedProject != null
                    ? 'Post created and added to "${_selectedProject!.name}"'
                    : 'Post created successfully'),
              ),
            );
            Navigator.pop(context, true);
          }
        },
        onError: _showError,
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _interestsController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _locationsController.dispose();
    _languagesController.dispose();
    _skillsController.dispose();
    _industriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _savePost,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Post'),
            ),
          ],
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Post creation frame
                  PostFormFields(
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 8), // Reduced by 50%
                  // Project button right after post creation frame
                  ProjectButton(
                    selectedProject: _selectedProject,
                    isLoading: _isLoading,
                    onShowDialog: _showProjectDialog,
                    onRemoveProject: () => setState(() => _selectedProject = null),
                  ),
                  const SizedBox(height: 24),
                  // Steps section
                  if (_availableStepTypes.isNotEmpty)
                    StepsSection(
                      steps: _steps,
                      availableStepTypes: _availableStepTypes,
                      isLoading: _isLoading,
                      onRemoveStep: _removeStep,
                      onAddStep: _addStep,
                    ),
                  const SizedBox(height: 24),
                  // Targeting fields
                  TargetingFields(
                    interestsController: _interestsController,
                    minAgeController: _minAgeController,
                    maxAgeController: _maxAgeController,
                    locationsController: _locationsController,
                    languagesController: _languagesController,
                    skillsController: _skillsController,
                    industriesController: _industriesController,
                    selectedExperienceLevel: _selectedExperienceLevel,
                    onExperienceLevelChanged: (value) => 
                        setState(() => _selectedExperienceLevel = value),
                    enabled: !_isLoading,
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
