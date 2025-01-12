import 'package:flutter/material.dart';
import 'step_type_form_base.dart';
import '../../../../../data/models/step_type_model.dart';

class UploadStepForm extends StepTypeFormBase {
  const UploadStepForm({
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
  UploadStepFormState createState() => UploadStepFormState();
}

class UploadStepFormState extends StepTypeFormBaseState<UploadStepForm> {
  final _fileTypeController = TextEditingController();
  bool _allowMultipleFiles = false;
  final List<String> _fileTypes = [
    'text',
    'image',
    'video',
    'document',
  ];

  @override
  void dispose() {
    _fileTypeController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'Upload Title';

  @override
  String get descriptionPlaceholder => 'Instructions for uploading';

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'fileType': _fileTypeController.text,
      'allowMultiple': _allowMultipleFiles,
    };
  }

  String _getFileTypeDescription(String type) {
    switch (type) {
      case 'text':
        return '.txt, .doc, .docx, .pdf';
      case 'image':
        return '.jpg, .png, .gif, .webp';
      case 'video':
        return '.mp4, .mov, .avi, .webm';
      case 'document':
        return '.pdf, .doc, .docx, .xls, .xlsx';
      default:
        return '';
    }
  }

  IconData _getIconForFileType(String type) {
    switch (type) {
      case 'text':
        return Icons.text_snippet;
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_library;
      case 'document':
        return Icons.description;
      default:
        return Icons.file_present;
    }
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Required File Type',
            border: OutlineInputBorder(),
          ),
          value: _fileTypeController.text.isEmpty ? null : _fileTypeController.text,
          items: _fileTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getIconForFileType(type)),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(type.toUpperCase()),
                            Text(
                              _getFileTypeDescription(type),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _fileTypeController.text = value;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a file type';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Allow Multiple Files'),
          subtitle: const Text('Users can upload multiple files'),
          value: _allowMultipleFiles,
          onChanged: (value) {
            setState(() {
              _allowMultipleFiles = value;
            });
          },
        ),
      ],
    );
  }
}
