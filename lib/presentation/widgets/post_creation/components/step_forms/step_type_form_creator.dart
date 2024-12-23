import 'package:flutter/material.dart';
import '../../../../../data/models/post_model.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';
import 'text_step_form.dart';
import 'code_step_form.dart';
import 'image_step_form.dart';
import 'video_step_form.dart';
import 'audio_step_form.dart';
import 'document_step_form.dart';
import 'link_step_form.dart';
import 'quiz_step_form.dart';
import 'ar_step_form.dart';
import 'vr_step_form.dart';

class StepTypeFormCreator {
  static StepTypeFormBase createForm({
    required StepTypeModel stepType,
    required VoidCallback onCancel,
    required Function(Map<String, dynamic>) onSave,
    Key? key,
  }) {
    // Get the enum value from the string name
    final stepTypeEnum = StepType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == stepType.name.toLowerCase(),
      orElse: () => throw Exception('Unknown step type: ${stepType.name}'),
    );

    // Return the appropriate form based on step type
    switch (stepTypeEnum) {
      case StepType.text:
        return TextStepForm(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );
      case StepType.code:
        return CodeStepForm(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );
      case StepType.image:
        return ImageStepForm(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );
      case StepType.video:
        return VideoStepForm(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );
      case StepType.audio:
        return AudioStepForm(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );
      case StepType.document:
        return DocumentStepForm(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );
      case StepType.link:
        return LinkStepForm(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );
      case StepType.quiz:
        return QuizStepForm(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );
      case StepType.ar:
        return ArStepForm(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );
      case StepType.vr:
        return VrStepForm(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );
      default:
        throw Exception('Form not implemented for step type: ${stepType.name}');
    }
  }
}
