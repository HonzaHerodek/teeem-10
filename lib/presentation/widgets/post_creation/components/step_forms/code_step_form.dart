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
  String _selectedLanguage = 'dart';
  
  final List<String> _supportedLanguages = [
    'dart',
    'javascript',
    'python',
    'java',
    'kotlin',
    'swift',
    'cpp',
    'csharp',
    'go',
    'rust',
  ];

  @override
  void dispose() {
    _codeController.dispose();
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
        DropdownButtonFormField<String>(
          value: _selectedLanguage,
          decoration: InputDecoration(
            labelText: 'Language',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: _supportedLanguages.map((String language) {
            return DropdownMenuItem<String>(
              value: language,
              child: Text(
                language,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedLanguage = newValue;
              });
            }
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _codeController,
          decoration: InputDecoration(
            hintText: 'Enter your code here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLines: 10,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.5,
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
      'codeLanguage': _selectedLanguage,
    };
  }
}
