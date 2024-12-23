import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';

class CodeStepForm extends StepTypeFormBase {
  const CodeStepForm({
    Key? key,
    required StepTypeModel stepType,
    required VoidCallback onCancel,
    required Function(Map<String, dynamic>) onSave,
  }) : super(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );

  @override
  CodeStepFormState createState() => CodeStepFormState();
}

class CodeStepFormState extends StepTypeFormBaseState<CodeStepForm> {
  final _codeController = TextEditingController();
  final _languageController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'e.g., Implementing a Custom Widget';

  @override
  String get descriptionPlaceholder => 'e.g., Step-by-step guide to creating a reusable Flutter widget';

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _languageController,
          decoration: const InputDecoration(
            labelText: 'Programming Language',
            hintText: 'e.g., dart, javascript, python',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please specify the programming language';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(
            labelText: 'Code',
            hintText: 'Enter your code here...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 15,
          style: const TextStyle(
            fontFamily: 'monospace',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the code';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'codeSnippet': _codeController.text,
      'codeLanguage': _languageController.text,
    };
  }
}
