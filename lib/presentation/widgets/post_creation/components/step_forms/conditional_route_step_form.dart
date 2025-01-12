import 'package:flutter/material.dart';
import 'step_type_form_base.dart';
import '../../../../../data/models/step_type_model.dart';

class ConditionalRouteStepForm extends StepTypeFormBase {
  const ConditionalRouteStepForm({
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
  ConditionalRouteStepFormState createState() => ConditionalRouteStepFormState();
}

class ConditionalRouteStepFormState extends StepTypeFormBaseState<ConditionalRouteStepForm> {
  final _activityController = TextEditingController();
  final _valueController = TextEditingController();
  bool _repeatable = false;

  @override
  void dispose() {
    _activityController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'Conditional Route Title';

  @override
  String get descriptionPlaceholder => 'Instructions for route conditions';

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'previousActivity': _activityController.text,
      'previousValue': _valueController.text,
      'repeatable': _repeatable,
    };
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Activity Selection
        TextFormField(
          controller: _activityController,
          decoration: const InputDecoration(
            labelText: 'Previous Step Activity',
            border: OutlineInputBorder(),
            helperText: 'Select the activity to check from previous step',
            prefixIcon: Icon(Icons.track_changes),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please specify the activity to check';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Value Selection
        TextFormField(
          controller: _valueController,
          decoration: const InputDecoration(
            labelText: 'Required Value',
            border: OutlineInputBorder(),
            helperText: 'Specify the value that triggers this route',
            prefixIcon: Icon(Icons.rule),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please specify the required value';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Repeatable Toggle
        SwitchListTile(
          title: const Text('Allow Repeat'),
          subtitle: const Text('Users can repeat this conditional route'),
          value: _repeatable,
          onChanged: (value) {
            setState(() {
              _repeatable = value;
            });
          },
        ),
        const SizedBox(height: 8),
        // Help Card
        Card(
          color: Colors.grey[50],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'How it works',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Activity: The action to check (e.g., "completed", "selected")\n'
                  '• Value: The specific value to match (e.g., "option1", "true")\n'
                  '• Route triggers when activity value matches the specified value',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
