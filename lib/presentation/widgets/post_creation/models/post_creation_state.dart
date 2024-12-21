import 'package:flutter/material.dart';
import '../../../../data/models/step_type_model.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/project_model.dart';
import '../post_step_widget.dart';

class PostCreationState {
  final List<GlobalKey<PostStepWidgetState>> stepKeys;
  final List<PostStepWidget> steps;
  final List<StepTypeModel> availableStepTypes;
  final bool isLoading;
  final int currentPage;
  final ProjectModel? selectedProject;

  const PostCreationState({
    required this.stepKeys,
    required this.steps,
    required this.availableStepTypes,
    required this.isLoading,
    required this.currentPage,
    this.selectedProject,
  });

  PostCreationState copyWith({
    List<GlobalKey<PostStepWidgetState>>? stepKeys,
    List<PostStepWidget>? steps,
    List<StepTypeModel>? availableStepTypes,
    bool? isLoading,
    int? currentPage,
    ProjectModel? selectedProject,
  }) {
    return PostCreationState(
      stepKeys: stepKeys ?? this.stepKeys,
      steps: steps ?? this.steps,
      availableStepTypes: availableStepTypes ?? this.availableStepTypes,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
      selectedProject: selectedProject ?? this.selectedProject,
    );
  }

  bool get hasSteps => steps.isNotEmpty;
  
  bool get isFirstPage => currentPage == 0;
  
  bool get hasSelectedStepType {
    if (currentPage == 0 || steps.isEmpty || currentPage > steps.length) {
      return false;
    }
    final stepState = stepKeys[currentPage - 1].currentState;
    return stepState?.getSelectedStepType() != null;
  }

  bool validateSteps() {
    bool isValid = true;
    for (var i = 0; i < stepKeys.length; i++) {
      final state = stepKeys[i].currentState;
      if (state == null || !state.validate()) {
        isValid = false;
        print('Step ${i + 1} validation failed');
      }
    }
    return isValid;
  }

  List<PostStep> getValidSteps() {
    return steps
        .map((stepWidget) => stepWidget.toPostStep())
        .where((step) => step != null)
        .cast<PostStep>()
        .toList();
  }
}
