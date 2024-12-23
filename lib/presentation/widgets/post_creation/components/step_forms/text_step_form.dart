import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';

class TextStepForm extends StepTypeFormBase {
  const TextStepForm({
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
  TextStepFormState createState() => TextStepFormState();
}

class TextStepFormState extends StepTypeFormBaseState<TextStepForm> {
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'e.g., Introduction to Flutter';

  @override
  String get descriptionPlaceholder => 'e.g., A brief overview of what Flutter is and why it\'s great for cross-platform development';

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(
            labelText: 'Content',
            hintText: 'Enter your text content here...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 10,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the content';
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
      'content': _contentController.text,
    };
  }
}
