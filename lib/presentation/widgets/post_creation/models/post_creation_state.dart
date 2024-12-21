import 'package:flutter/material.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/step_type_model.dart';
import '../post_step_widget.dart';

@immutable
class PostCreationState {
  final List<GlobalKey<PostStepWidgetState>> stepKeys;
  final List<PostStepWidget> steps;
  final List<StepTypeModel> availableStepTypes;
  final bool isLoading;
  final int currentPage;

  const PostCreationState({
    required this.stepKeys,
    required this.steps,
    required this.availableStepTypes,
    required this.isLoading,
    required this.currentPage,
  });

  bool get isFirstPage => currentPage == 0;
  bool get hasSteps => steps.isNotEmpty;
  bool get hasSelectedStepType {
    if (currentPage <= 0 || currentPage > stepKeys.length) return false;
    final state = stepKeys[currentPage - 1].currentState;
    return state?.hasSelectedStepType ?? false;
  }

  List<PostStep> getValidSteps() {
    final validSteps = <PostStep>[];
    for (var i = 0; i < stepKeys.length; i++) {
      final state = stepKeys[i].currentState;
      if (state != null && state.validate()) {
        final step = state.getStepData();
        validSteps.add(step);
      }
    }
    return validSteps;
  }

  bool validateSteps() {
    if (steps.isEmpty) return false;
    for (var key in stepKeys) {
      final state = key.currentState;
      if (state == null || !state.validate()) return false;
    }
    return true;
  }

  PostCreationState copyWith({
    List<GlobalKey<PostStepWidgetState>>? stepKeys,
    List<PostStepWidget>? steps,
    List<StepTypeModel>? availableStepTypes,
    bool? isLoading,
    int? currentPage,
  }) {
    return PostCreationState(
      stepKeys: stepKeys ?? this.stepKeys,
      steps: steps ?? this.steps,
      availableStepTypes: availableStepTypes ?? this.availableStepTypes,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
