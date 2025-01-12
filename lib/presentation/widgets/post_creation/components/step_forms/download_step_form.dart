import 'package:flutter/material.dart';
import 'step_type_form_base.dart';
import '../../../../../data/models/step_type_model.dart';

class DownloadStepForm extends StepTypeFormBase {
  const DownloadStepForm({
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
  DownloadStepFormState createState() => DownloadStepFormState();
}

class DownloadStepFormState extends StepTypeFormBaseState<DownloadStepForm> {
  final _fileUrlController = TextEditingController();
  bool _allowMultipleDownloads = false;
  String? _selectedFile;

  @override
  void dispose() {
    _fileUrlController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'Download Title';

  @override
  String get descriptionPlaceholder => 'Instructions for downloading';

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'fileUrl': _fileUrlController.text,
      'allowMultiple': _allowMultipleDownloads,
    };
  }

  Future<void> _selectFile() async {
    // In a real implementation, this would open a file picker
    // For now, we'll just update the text field
    setState(() {
      _selectedFile = 'example_file.pdf';
      _fileUrlController.text = 'https://example.com/files/example_file.pdf';
    });
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fileUrlController,
                decoration: const InputDecoration(
                  labelText: 'File URL',
                  border: OutlineInputBorder(),
                  helperText: 'Enter URL or select file',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a file URL';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: _selectFile,
              tooltip: 'Select File',
            ),
          ],
        ),
        if (_selectedFile != null) ...[
          const SizedBox(height: 8),
          Text(
            'Selected file: $_selectedFile',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Allow Multiple Downloads'),
          subtitle: const Text('Users can download the file multiple times'),
          value: _allowMultipleDownloads,
          onChanged: (value) {
            setState(() {
              _allowMultipleDownloads = value;
            });
          },
        ),
      ],
    );
  }
}
