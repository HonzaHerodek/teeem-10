import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';

class AudioStepForm extends StepTypeFormBase {
  const AudioStepForm({
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
  AudioStepFormState createState() => AudioStepFormState();
}

class AudioStepFormState extends StepTypeFormBaseState<AudioStepForm> {
  String? _selectedAudioPath;
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
  String get titlePlaceholder => 'e.g., Introduction to Flutter Concepts';

  @override
  String get descriptionPlaceholder => 'e.g., An audio guide explaining key Flutter concepts and terminology';

  Future<void> _pickAudio() async {
    // TODO: Implement audio picking functionality
    // This would typically use file_picker package
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Audio upload area
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedAudioPath != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.audiotrack, size: 32, color: Colors.green),
                      const SizedBox(height: 8),
                      Text(
                        'Audio selected: ${_selectedAudioPath!}',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _pickAudio,
                        child: const Text('Change Audio'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.audiotrack, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickAudio,
                        child: const Text('Select Audio'),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        // Audio duration
        TextFormField(
          controller: _durationController,
          decoration: const InputDecoration(
            labelText: 'Duration (mm:ss)',
            hintText: 'e.g., 05:30',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the audio duration';
            }
            // TODO: Add duration format validation
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Audio caption
        TextFormField(
          controller: _captionController,
          decoration: const InputDecoration(
            labelText: 'Audio Caption',
            hintText: 'Enter a caption for the audio...',
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
        // Audio transcript
        TextFormField(
          controller: _transcriptController,
          decoration: const InputDecoration(
            labelText: 'Transcript',
            hintText: 'Enter audio transcript for accessibility...',
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
      'audioUrl': _selectedAudioPath,
      'duration': _durationController.text,
      'caption': _captionController.text,
      'transcript': _transcriptController.text,
    };
  }
}
