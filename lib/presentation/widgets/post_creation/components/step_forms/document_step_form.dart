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

  IconData _getFileIcon() {
    if (_fileType == null) return Icons.description;
    switch (_fileType!.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.article;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.description;
    }
  }

  String? _getFileName() {
    if (_selectedDocumentPath == null) return null;
    return _selectedDocumentPath!.split('/').last;
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Document upload/preview area
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          padding: const EdgeInsets.all(12),
          child: _selectedDocumentPath != null
              ? Row(
                  children: [
                    Container(
                      width: 40,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        _getFileIcon(),
                        color: Colors.blue[400],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getFileName() ?? 'Document Selected',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_fileType != null && _fileSize != null)
                            Text(
                              '$_fileType • $_fileSize',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: _pickDocument,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                )
              : InkWell(
                  onTap: _pickDocument,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 32,
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PDF, DOC, DOCX, TXT',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        // Display name field
        TextFormField(
          controller: _fileNameController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Display name for the document...',
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
              return 'Please enter a display name';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        // Summary field
        TextFormField(
          controller: _summaryController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Brief summary of the document content...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          maxLines: 2,
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
