import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';

class TextStepForm extends StepTypeFormBase {
  const TextStepForm({
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
  TextStepFormState createState() => TextStepFormState();
}

class TextStepFormState extends StepTypeFormBaseState<TextStepForm> {
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'e.g., Introduction to Flutter';

  @override
  String get descriptionPlaceholder => 'e.g., A brief overview of what Flutter is and why it\'s great for cross-platform development';

  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main formatting options in a row (3 items)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFormatButton(
              icon: Icons.format_bold,
              label: 'Bold',
              isSelected: _isBold,
              onPressed: () => setState(() => _isBold = !_isBold),
            ),
            _buildFormatButton(
              icon: Icons.format_italic,
              label: 'Italic',
              isSelected: _isItalic,
              onPressed: () => setState(() => _isItalic = !_isItalic),
            ),
            _buildFormatButton(
              icon: Icons.format_underline,
              label: 'Underline',
              isSelected: _isUnderline,
              onPressed: () => setState(() => _isUnderline = !_isUnderline),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Text input area
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _contentController,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                  decoration: _isUnderline ? TextDecoration.underline : null,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your text content here...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the content';
                  }
                  return null;
                },
              ),
              // Character count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                ),
                child: Text(
                  '${_contentController.text.length} characters',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (super.showMoreOptions) ...[
          const SizedBox(height: 16),
          // Additional formatting options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFormatButton(
                icon: Icons.format_list_bulleted,
                label: 'Bullet List',
                onPressed: () {/* TODO: Implement */},
              ),
              _buildFormatButton(
                icon: Icons.format_list_numbered,
                label: 'Numbered',
                onPressed: () {/* TODO: Implement */},
              ),
              _buildFormatButton(
                icon: Icons.link,
                label: 'Link',
                onPressed: () {/* TODO: Implement */},
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Background option
          OutlinedButton.icon(
            onPressed: () {/* TODO: Implement background selection */},
            icon: const Icon(Icons.image_outlined),
            label: const Text('Set Step Background'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, 
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
          ),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1) 
              : Colors.transparent,
          ),
        ),
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

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'content': _contentController.text,
    };
  }
}
