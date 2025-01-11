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

  bool _mustFinishVideo = false;

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
              icon: Icons.video_library,
              label: 'Gallery',
              onPressed: _pickVideo,
            ),
            _buildOptionButton(
              icon: Icons.videocam,
              label: 'Record',
              onPressed: () {/* TODO: Implement video recording */},
            ),
            _buildOptionButton(
              icon: Icons.link,
              label: 'URL',
              onPressed: () {/* TODO: Implement URL input */},
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Video preview area
        if (_selectedVideoPath != null) ...[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
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
                  if (_thumbnailPath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _thumbnailPath!,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ] else
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.video_library,
                  size: 36,
                  color: Colors.grey.withOpacity(0.7),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        // Basic details
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
        if (super.showMoreOptions) ...[
          const SizedBox(height: 16),
          // Additional options
          SwitchListTile(
            title: const Text(
              'Respondents must finish the video',
              style: TextStyle(fontSize: 14),
            ),
            value: _mustFinishVideo,
            onChanged: (bool value) {
              setState(() {
                _mustFinishVideo = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          // Thumbnail selection
          OutlinedButton.icon(
            onPressed: _pickThumbnail,
            icon: const Icon(Icons.image),
            label: const Text('Set Custom Thumbnail'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(height: 12),
          // Duration field
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
      'mustFinishVideo': _mustFinishVideo,
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
