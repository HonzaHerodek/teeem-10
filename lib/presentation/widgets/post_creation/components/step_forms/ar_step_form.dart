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

  bool _allowMultipleUses = false;

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main options in a row (3 items)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOptionButton(
              icon: Icons.upload_file,
              label: 'Upload',
              onPressed: _pickModel,
            ),
            _buildOptionButton(
              icon: Icons.link,
              label: 'URL',
              onPressed: () {/* TODO: Implement URL input */},
            ),
            _buildOptionButton(
              icon: Icons.preview,
              label: 'Preview',
              onPressed: _pickPreviewImage,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Model preview area
        if (_modelPath != null) ...[
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.view_in_ar, size: 32, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    'Model selected: ${_modelPath!}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.view_in_ar, size: 48, color: Colors.grey.withOpacity(0.7)),
                  const SizedBox(height: 8),
                  Text(
                    'Supported formats: GLB, GLTF, USDZ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        // Basic instructions
        TextFormField(
          controller: _instructionsController,
          decoration: InputDecoration(
            hintText: 'Enter instructions for interacting with the AR content...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          style: const TextStyle(fontSize: 14),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter instructions';
            }
            return null;
          },
        ),
        if (super.showMoreOptions) ...[
          const SizedBox(height: 16),
          // Additional options
          SwitchListTile(
            title: const Text(
              'Respondents can use multiple times',
              style: TextStyle(fontSize: 14),
            ),
            value: _allowMultipleUses,
            onChanged: (bool value) {
              setState(() {
                _allowMultipleUses = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          // Device requirements
          TextFormField(
            controller: _requirementsController,
            decoration: InputDecoration(
              labelText: 'Device Requirements',
              hintText: 'Enter any specific device requirements...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          // Required features
          CheckboxListTile(
            title: const Text('Requires Gyroscope', style: TextStyle(fontSize: 14)),
            value: _requiresGyroscope,
            onChanged: (value) {
              setState(() {
                _requiresGyroscope = value ?? false;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text('Requires Camera', style: TextStyle(fontSize: 14)),
            value: _requiresCamera,
            onChanged: (value) {
              setState(() {
                _requiresCamera = value ?? true;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
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
      'allowMultipleUses': _allowMultipleUses,
    };
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, 
            color: Colors.grey[600],
          ),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[100],
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
