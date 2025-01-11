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
              onPressed: _pickScene,
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
        // Scene preview area
        if (_scenePath != null) ...[
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
                  const Icon(Icons.vrpano, size: 32, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    'Scene selected: ${_scenePath!}',
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
                  Icon(Icons.vrpano, size: 48, color: Colors.grey.withOpacity(0.7)),
                  const SizedBox(height: 8),
                  Text(
                    'Supported formats: FBX, Unity Package, WebXR',
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
            hintText: 'Enter instructions for navigating the VR environment...',
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
          // View Mode Selection
          DropdownButtonFormField<String>(
            value: _selectedViewMode,
            decoration: InputDecoration(
              labelText: 'View Mode',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
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
          const SizedBox(height: 12),
          // Device requirements
          TextFormField(
            controller: _requirementsController,
            decoration: InputDecoration(
              labelText: 'Device Requirements',
              hintText: 'Enter any specific VR headset requirements...',
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
            title: const Text('Requires 3DOF (Rotation Only)', style: TextStyle(fontSize: 14)),
            value: _requires3dof,
            onChanged: (value) {
              setState(() {
                _requires3dof = value ?? true;
                if (value == true) {
                  _requires6dof = false;
                }
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text('Requires 6DOF (Full Movement)', style: TextStyle(fontSize: 14)),
            value: _requires6dof,
            onChanged: (value) {
              setState(() {
                _requires6dof = value ?? false;
                if (value == true) {
                  _requires3dof = false;
                }
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text('Requires VR Controllers', style: TextStyle(fontSize: 14)),
            value: _requiresControllers,
            onChanged: (value) {
              setState(() {
                _requiresControllers = value ?? false;
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
      'sceneUrl': _scenePath,
      'previewImageUrl': _previewImagePath,
      'viewMode': _selectedViewMode,
      'instructions': _instructionsController.text,
      'requirements': _requirementsController.text,
      'requires3dof': _requires3dof,
      'requires6dof': _requires6dof,
      'requiresControllers': _requiresControllers,
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
