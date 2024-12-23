import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';
import 'dart:math' as math;

class AudioWaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final barWidth = 3.0;
    final spacing = 2.0;
    final numBars = (size.width / (barWidth + spacing)).floor();
    
    // Create a random waveform pattern
    final random = math.Random(42); // Fixed seed for consistent pattern
    
    for (var i = 0; i < numBars; i++) {
      final x = i * (barWidth + spacing);
      final normalizedHeight = math.sin(i * 0.2) * 0.5 + 0.5; // Smooth wave pattern
      final randomFactor = 0.7 + random.nextDouble() * 0.3; // Random variation
      final height = size.height * normalizedHeight * randomFactor;
      
      final barHeight = height.clamp(size.height * 0.1, size.height * 0.8);
      final y = (size.height - barHeight) / 2;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(1.0),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


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
        // Audio upload area with waveform visualization
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedAudioPath != null
              ? Stack(
                  children: [
                    // Waveform visualization placeholder
                    Center(
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: CustomPaint(
                          size: const Size(double.infinity, 40),
                          painter: AudioWaveformPainter(),
                        ),
                      ),
                    ),
                    // Audio info overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, 
                            color: Colors.green[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Audio Selected',
                            style: TextStyle(fontSize: 12),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: _pickAudio,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.audiotrack,
                        size: 32,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickAudio,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Select Audio',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
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
            hintText: 'Enter a caption for the audio...',
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
            hintText: 'Enter audio transcript for accessibility...',
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
      'audioUrl': _selectedAudioPath,
      'duration': _durationController.text,
      'caption': _captionController.text,
      'transcript': _transcriptController.text,
    };
  }
}
