import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';

class ImageStepForm extends StepTypeFormBase {
  const ImageStepForm({
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
  ImageStepFormState createState() => ImageStepFormState();
}

class ImageStepFormState extends StepTypeFormBaseState<ImageStepForm> {
  String? _selectedImagePath;
  final _captionController = TextEditingController();
  final _altTextController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    _altTextController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'e.g., Project Architecture Diagram';

  @override
  String get descriptionPlaceholder => 'e.g., Visual representation of the application\'s component structure';

  Future<void> _pickImage() async {
    // TODO: Implement image picking functionality
    // This would typically use image_picker package to select from gallery or camera
  }

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
              icon: Icons.photo_library,
              label: 'Gallery',
              onPressed: _pickImage,
            ),
            _buildOptionButton(
              icon: Icons.camera_alt,
              label: 'Camera',
              onPressed: () {/* TODO: Implement camera capture */},
            ),
            _buildOptionButton(
              icon: Icons.link,
              label: 'URL',
              onPressed: () {/* TODO: Implement URL input */},
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Image preview area
        if (_selectedImagePath != null) ...[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _selectedImagePath!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 36,
                  color: Colors.grey.withOpacity(0.7),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        // Image details
        TextFormField(
          controller: _captionController,
          decoration: InputDecoration(
            hintText: 'Enter a caption for the image...',
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a caption';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _altTextController,
          decoration: InputDecoration(
            hintText: 'Describe the image for screen readers...',
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter alt text';
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
      'imageUrl': _selectedImagePath,
      'caption': _captionController.text,
      'altText': _altTextController.text,
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
