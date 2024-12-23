import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';

class VrStepForm extends StepTypeFormBase {
  const VrStepForm({
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
  VrStepFormState createState() => VrStepFormState();
}

class VrStepFormState extends StepTypeFormBaseState<VrStepForm> {
  String? _scenePath;
  String? _previewImagePath;
  final _instructionsController = TextEditingController();
  final _requirementsController = TextEditingController();
  bool _requires3dof = true;
  bool _requires6dof = false;
  bool _requiresControllers = false;
  String _selectedViewMode = 'mono'; // mono, stereo

  @override
  void dispose() {
    _instructionsController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'e.g., Virtual Flutter Workspace';

  @override
  String get descriptionPlaceholder => 'e.g., Immersive VR environment showcasing Flutter development workspace';

  Future<void> _pickScene() async {
    // TODO: Implement VR scene picking functionality
    // This would typically use file_picker package to select .fbx, .unity, etc.
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
        // VR Scene upload area
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _scenePath != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.vrpano, size: 32, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text(
                        'Scene selected: ${_scenePath!}',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _pickScene,
                        child: const Text('Change Scene'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.vrpano, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        'Supported formats: FBX, Unity Package, WebXR',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickScene,
                        child: const Text('Select VR Scene'),
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
        // View Mode Selection
        DropdownButtonFormField<String>(
          value: _selectedViewMode,
          decoration: const InputDecoration(
            labelText: 'View Mode',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'mono',
              child: Text('Monoscopic (Single View)'),
            ),
            DropdownMenuItem(
              value: 'stereo',
              child: Text('Stereoscopic (Split View)'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedViewMode = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        // Instructions
        TextFormField(
          controller: _instructionsController,
          decoration: const InputDecoration(
            labelText: 'Instructions',
            hintText: 'Enter instructions for navigating the VR environment...',
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
            hintText: 'Enter any specific VR headset requirements...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        // Required features
        CheckboxListTile(
          title: const Text('Requires 3DOF (Rotation Only)'),
          value: _requires3dof,
          onChanged: (value) {
            setState(() {
              _requires3dof = value ?? true;
              if (value == true) {
                _requires6dof = false;
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Requires 6DOF (Full Movement)'),
          value: _requires6dof,
          onChanged: (value) {
            setState(() {
              _requires6dof = value ?? false;
              if (value == true) {
                _requires3dof = false;
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Requires VR Controllers'),
          value: _requiresControllers,
          onChanged: (value) {
            setState(() {
              _requiresControllers = value ?? false;
            });
          },
        ),
      ],
    );
  }

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'sceneUrl': _scenePath,
      'previewImageUrl': _previewImagePath,
      'viewMode': _selectedViewMode,
      'instructions': _instructionsController.text,
      'requirements': _requirementsController.text,
      'requires3dof': _requires3dof,
      'requires6dof': _requires6dof,
      'requiresControllers': _requiresControllers,
    };
  }
}
