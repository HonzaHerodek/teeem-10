import 'package:flutter/material.dart';
import 'step_type_form_base.dart';
import '../../../../../data/models/step_type_model.dart';

class ShareOutStepForm extends StepTypeFormBase {
  const ShareOutStepForm({
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
  ShareOutStepFormState createState() => ShareOutStepFormState();
}

class ShareOutStepFormState extends StepTypeFormBaseState<ShareOutStepForm> {
  final _platformController = TextEditingController();
  bool _requireLink = false;
  final List<String> _platforms = [
    'Facebook',
    'Instagram',
    'Email',
    'WhatsApp',
    'Slack'
  ];

  @override
  void dispose() {
    _platformController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'Share Out Title';

  @override
  String get descriptionPlaceholder => 'Instructions for sharing';

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'platform': _platformController.text,
      'requireLink': _requireLink,
    };
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Sharing Platform',
            border: OutlineInputBorder(),
          ),
          value: _platformController.text.isEmpty ? null : _platformController.text,
          items: _platforms
              .map((platform) => DropdownMenuItem(
                    value: platform,
                    child: Row(
                      children: [
                        Icon(_getIconForPlatform(platform)),
                        const SizedBox(width: 8),
                        Text(platform),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _platformController.text = value;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a sharing platform';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Require Link'),
          subtitle: const Text('Users must include a link when sharing'),
          value: _requireLink,
          onChanged: (value) {
            setState(() {
              _requireLink = value;
            });
          },
        ),
      ],
    );
  }

  IconData _getIconForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'email':
        return Icons.email;
      case 'whatsapp':
        return Icons.message;
      case 'slack':
        return Icons.work;
      default:
        return Icons.share;
    }
  }
}
