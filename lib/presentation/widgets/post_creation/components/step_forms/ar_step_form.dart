import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';

class ArStepForm extends StepTypeFormBase {
  const ArStepForm({
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
  ArStepFormState createState() => ArStepFormState();
}

class ArStepFormState extends StepTypeFormBaseState<ArStepForm> {
  String? _modelPath;
  String? _previewImagePath;
  final _instructionsController = TextEditingController();
  final _requirementsController = TextEditingController();
  bool _requiresGyroscope = false;
  bool _requiresCamera = true;

  @override
  void dispose() {
    _instructionsController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'e.g., 3D Flutter Logo';

  @override
  String get descriptionPlaceholder =>
      'e.g., Interactive 3D model of the Flutter logo with animations';

  Future<void> _pickModel() async {
    // TODO: Implement 3D model picking functionality
    // This would typically use file_picker package to select .glb, .gltf, etc.
  }

  Future<void> _pickPreviewImage() async {
    // TODO: Implement preview image picking functionality
    // This would typically use image_picker package
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 3D Model upload area
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _modelPath != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.view_in_ar,
                          size: 32, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text(
                        'Model selected: ${_modelPath!}',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _pickModel,
                        child: const Text('Change Model'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.view_in_ar,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        'Supported formats: GLB, GLTF, USDZ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickModel,
                        child: const Text('Select 3D Model'),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        // Preview image upload
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _previewImagePath != null
              ? Image.network(
                  _previewImagePath!,
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, size: 32, color: Colors.grey),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickPreviewImage,
                        child: const Text('Select Preview Image'),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        // Instructions
        TextFormField(
          controller: _instructionsController,
          decoration: const InputDecoration(
            labelText: 'Instructions',
            hintText:
                'Enter instructions for interacting with the AR content...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter instructions';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Device requirements
        TextFormField(
          controller: _requirementsController,
          decoration: const InputDecoration(
            labelText: 'Device Requirements',
            hintText: 'Enter any specific device requirements...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        // Required features
        CheckboxListTile(
          title: const Text('Requires Gyroscope'),
          value: _requiresGyroscope,
          onChanged: (value) {
            setState(() {
              _requiresGyroscope = value ?? false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Requires Camera'),
          value: _requiresCamera,
          onChanged: (value) {
            setState(() {
              _requiresCamera = value ?? true;
            });
          },
        ),
      ],
    );
  }

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'modelUrl': _modelPath,
      'previewImageUrl': _previewImagePath,
      'instructions': _instructionsController.text,
      'requirements': _requirementsController.text,
      'requiresGyroscope': _requiresGyroscope,
      'requiresCamera': _requiresCamera,
    };
  }
}
