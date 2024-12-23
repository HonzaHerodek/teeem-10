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
        // Text content area with formatting toolbar
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Formatting toolbar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.format_bold, size: 18),
                      onPressed: () {/* TODO: Implement formatting */},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Bold',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.format_italic, size: 18),
                      onPressed: () {/* TODO: Implement formatting */},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Italic',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.format_list_bulleted, size: 18),
                      onPressed: () {/* TODO: Implement formatting */},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Bullet List',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.format_list_numbered, size: 18),
                      onPressed: () {/* TODO: Implement formatting */},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Numbered List',
                    ),
                  ],
                ),
              ),
              // Text input area
              TextFormField(
                controller: _contentController,
                style: const TextStyle(fontSize: 14, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'Enter your text content here...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the content';
                  }
                  return null;
                },
              ),
              // Character count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                ),
                child: Text(
                  '${_contentController.text.length} characters',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
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
