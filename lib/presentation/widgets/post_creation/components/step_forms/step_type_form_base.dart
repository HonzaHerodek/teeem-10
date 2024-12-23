import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';

abstract class StepTypeFormBase extends StatefulWidget {
  final StepTypeModel stepType;
  final VoidCallback onCancel;
  final Function(Map<String, dynamic>) onSave;

  const StepTypeFormBase({
    Key? key,
    required this.stepType,
    required this.onCancel,
    required this.onSave,
  }) : super(key: key);
}

abstract class StepTypeFormBaseState<T extends StepTypeFormBase>
    extends State<T> {
  @protected
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // To be implemented by each step type form
  String get titlePlaceholder;
  String get descriptionPlaceholder;
  
  // To be implemented by each step type form
  Widget buildStepSpecificFields();

  Map<String, dynamic> getFormData() {
    return {
      'title': titleController.text,
      'description': descriptionController.text,
      ...getStepSpecificFormData(),
    };
  }

  // To be implemented by each step type form
  Map<String, dynamic> getStepSpecificFormData();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with cancel button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Configure ${widget.stepType.name} Step',
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onCancel,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Common fields
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Step Title',
                  hintText: titlePlaceholder,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Step Description',
                  hintText: descriptionPlaceholder,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Step-specific fields in scrollable area
              Expanded(
                child: SingleChildScrollView(
                  child: buildStepSpecificFields(),
                ),
              ),
              // Save button
              ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      final formData = getFormData();
                      widget.onSave(formData);
                    }
                  },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
