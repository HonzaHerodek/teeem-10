import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';

class LinkStepForm extends StepTypeFormBase {
  const LinkStepForm({
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
  LinkStepFormState createState() => LinkStepFormState();
}

class LinkStepFormState extends StepTypeFormBaseState<LinkStepForm> {
  final _urlController = TextEditingController();
  final _previewTitleController = TextEditingController();
  final _previewDescriptionController = TextEditingController();
  String? _thumbnailUrl;

  @override
  void dispose() {
    _urlController.dispose();
    _previewTitleController.dispose();
    _previewDescriptionController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'e.g., Flutter Documentation';

  @override
  String get descriptionPlaceholder => 'e.g., Official Flutter documentation for widgets and development';

  Future<void> _fetchLinkPreview() async {
    // TODO: Implement link preview fetching
    // This would typically use a package like metadata_fetch or url_preview
    // to get title, description, and thumbnail from the URL
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // URL input with fetch button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'Enter the link URL...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  // TODO: Add URL format validation
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _fetchLinkPreview,
              child: const Text('Fetch Preview'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Link preview section
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Link Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Preview thumbnail
              if (_thumbnailUrl != null)
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_thumbnailUrl!),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              const SizedBox(height: 16),
              // Preview title
              TextFormField(
                controller: _previewTitleController,
                decoration: const InputDecoration(
                  labelText: 'Preview Title',
                  hintText: 'Enter a title for the link preview...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a preview title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Preview description
              TextFormField(
                controller: _previewDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Preview Description',
                  hintText: 'Enter a description for the link preview...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a preview description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'linkUrl': _urlController.text,
      'previewTitle': _previewTitleController.text,
      'previewDescription': _previewDescriptionController.text,
      'previewThumbnail': _thumbnailUrl,
    };
  }
}
