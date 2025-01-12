import 'package:flutter/material.dart';
import 'step_type_form_base.dart';
import '../../../../../data/models/step_type_model.dart';

class RespondentApprovalStepForm extends StepTypeFormBase {
  const RespondentApprovalStepForm({
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
  RespondentApprovalStepFormState createState() => RespondentApprovalStepFormState();
}

class RespondentApprovalStepFormState extends StepTypeFormBaseState<RespondentApprovalStepForm> {
  final _materialTypeController = TextEditingController();
  bool _publicApproval = false;
  final List<String> _materialTypes = [
    'text',
    'image',
    'location',
  ];

  @override
  void dispose() {
    _materialTypeController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'Respondent Approval Title';

  @override
  String get descriptionPlaceholder => 'Instructions for respondent approval';

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'approvedMaterial': _materialTypeController.text,
      'publicApproval': _publicApproval,
    };
  }

  String _getMaterialTypeDisplayName(String type) {
    switch (type) {
      case 'text':
        return 'Text Content';
      case 'image':
        return 'Image Content';
      case 'location':
        return 'Location Data';
      default:
        return type;
    }
  }

  IconData _getIconForMaterialType(String type) {
    switch (type) {
      case 'text':
        return Icons.text_fields;
      case 'image':
        return Icons.image;
      case 'location':
        return Icons.location_on;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Content to Approve',
            border: OutlineInputBorder(),
          ),
          value: _materialTypeController.text.isEmpty ? null : _materialTypeController.text,
          items: _materialTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getIconForMaterialType(type)),
                        const SizedBox(width: 8),
                        Text(_getMaterialTypeDisplayName(type)),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _materialTypeController.text = value;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select content type for approval';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Public Approval'),
          subtitle: const Text('Allow all respondents to see approval status'),
          value: _publicApproval,
          onChanged: (value) {
            setState(() {
              _publicApproval = value;
            });
          },
        ),
        if (_publicApproval) ...[
          const SizedBox(height: 8),
          Card(
            color: Colors.blue[50],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Public approval means all respondents can see who approved the content.',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
