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
        // Image preview/upload area
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedImagePath != null
              ? Image.network(
                  _selectedImagePath!,
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text('Select Image'),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        // Image caption
        TextFormField(
          controller: _captionController,
          decoration: const InputDecoration(
            labelText: 'Image Caption',
            hintText: 'Enter a caption for the image...',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a caption';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Alt text for accessibility
        TextFormField(
          controller: _altTextController,
          decoration: const InputDecoration(
            labelText: 'Alt Text',
            hintText: 'Describe the image for screen readers...',
            border: OutlineInputBorder(),
          ),
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
}
