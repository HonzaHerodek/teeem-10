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
        // Video upload area with 16:9 aspect ratio
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _selectedVideoPath != null
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, 
                              color: Colors.green[400],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Video Selected',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: _pickVideo,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library,
                          size: 36,
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _pickVideo,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Select Video',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Thumbnail upload area with 16:9 aspect ratio but smaller height
        SizedBox(
          height: 100,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _thumbnailPath != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _thumbnailPath!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: _pickThumbnail,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 24,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: _pickThumbnail,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Select Thumbnail',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Duration field with validation
        TextFormField(
          controller: _durationController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Duration (mm:ss)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            prefixIcon: const Icon(Icons.timer, size: 18),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the duration';
            }
            final durationRegex = RegExp(r'^\d{2}:\d{2}$');
            if (!durationRegex.hasMatch(value)) {
              return 'Use format: mm:ss';
            }
            final parts = value.split(':');
            final minutes = int.parse(parts[0]);
            final seconds = int.parse(parts[1]);
            if (seconds >= 60) {
              return 'Invalid seconds value';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        // Caption field
        TextFormField(
          controller: _captionController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter a caption for the video...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a caption';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        // Transcript field
        TextFormField(
          controller: _transcriptController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter video transcript for accessibility...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          maxLines: 3,
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
