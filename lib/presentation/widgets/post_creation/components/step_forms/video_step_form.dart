import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';

class VideoStepForm extends StepTypeFormBase {
  const VideoStepForm({
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
  VideoStepFormState createState() => VideoStepFormState();
}

class VideoStepFormState extends StepTypeFormBaseState<VideoStepForm> {
  String? _selectedVideoPath;
  String? _thumbnailPath;
  final _captionController = TextEditingController();
  final _transcriptController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    _transcriptController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'e.g., Getting Started with Flutter';

  @override
  String get descriptionPlaceholder => 'e.g., A video guide demonstrating how to set up your first Flutter project';

  Future<void> _pickVideo() async {
    // TODO: Implement video picking functionality
    // This would typically use file_picker or image_picker package
  }

  Future<void> _pickThumbnail() async {
    // TODO: Implement thumbnail picking functionality
    // This would typically use image_picker package
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Video preview/upload area
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedVideoPath != null
              ? Center(
                  child: Text('Video selected: ${_selectedVideoPath!}'),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.video_library, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickVideo,
                        child: const Text('Select Video'),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        // Thumbnail preview/upload area
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _thumbnailPath != null
              ? Image.network(
                  _thumbnailPath!,
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.image, size: 32, color: Colors.grey),
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: _pickThumbnail,
                        child: const Text('Select Thumbnail'),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        // Video duration
        TextFormField(
          controller: _durationController,
          decoration: const InputDecoration(
            labelText: 'Duration (mm:ss)',
            hintText: 'e.g., 05:30',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the video duration';
            }
            // TODO: Add duration format validation
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Video caption
        TextFormField(
          controller: _captionController,
          decoration: const InputDecoration(
            labelText: 'Video Caption',
            hintText: 'Enter a caption for the video...',
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
        // Video transcript
        TextFormField(
          controller: _transcriptController,
          decoration: const InputDecoration(
            labelText: 'Transcript',
            hintText: 'Enter video transcript for accessibility...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a transcript';
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
      'videoUrl': _selectedVideoPath,
      'thumbnailUrl': _thumbnailPath,
      'duration': _durationController.text,
      'caption': _captionController.text,
      'transcript': _transcriptController.text,
    };
  }
}
