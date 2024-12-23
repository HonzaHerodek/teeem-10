import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';

class DocumentStepForm extends StepTypeFormBase {
  const DocumentStepForm({
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
  DocumentStepFormState createState() => DocumentStepFormState();
}

class DocumentStepFormState extends StepTypeFormBaseState<DocumentStepForm> {
  String? _selectedDocumentPath;
  final _fileNameController = TextEditingController();
  final _summaryController = TextEditingController();
  String? _fileType;
  String? _fileSize;

  @override
  void dispose() {
    _fileNameController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'e.g., Flutter Architecture Guidelines';

  @override
  String get descriptionPlaceholder => 'e.g., Comprehensive documentation of our Flutter project architecture and best practices';

  Future<void> _pickDocument() async {
    // TODO: Implement document picking functionality
    // This would typically use file_picker package
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Document upload area
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedDocumentPath != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description, size: 32, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text(
                        'Document selected: ${_selectedDocumentPath!}',
                        textAlign: TextAlign.center,
                      ),
                      if (_fileType != null && _fileSize != null)
                        Text(
                          '$_fileType • $_fileSize',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      TextButton(
                        onPressed: _pickDocument,
                        child: const Text('Change Document'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        'Supported formats: PDF, DOC, DOCX, TXT',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickDocument,
                        child: const Text('Select Document'),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        // Document display name
        TextFormField(
          controller: _fileNameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            hintText: 'Enter a name for the document...',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a display name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Document summary
        TextFormField(
          controller: _summaryController,
          decoration: const InputDecoration(
            labelText: 'Summary',
            hintText: 'Enter a brief summary of the document content...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a summary';
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
      'documentUrl': _selectedDocumentPath,
      'fileName': _fileNameController.text,
      'summary': _summaryController.text,
      'fileType': _fileType,
      'fileSize': _fileSize,
    };
  }
}
