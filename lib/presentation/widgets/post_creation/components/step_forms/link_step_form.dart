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
        TextFormField(
          controller: _urlController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter URL...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _fetchLinkPreview,
              tooltip: 'Fetch Preview',
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a URL';
            }
            final urlRegex = RegExp(
              r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
            );
            if (!urlRegex.hasMatch(value)) {
              return 'Please enter a valid URL';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        // Preview section
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.preview,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Preview thumbnail with 16:9 aspect ratio
              if (_thumbnailUrl != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      _thumbnailUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (_thumbnailUrl != null)
                const SizedBox(height: 12),
              // Preview title with compact styling
              TextFormField(
                controller: _previewTitleController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Preview title...',
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
                    return 'Please enter a preview title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Preview description with compact styling
              TextFormField(
                controller: _previewDescriptionController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Preview description...',
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
