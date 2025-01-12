import 'package:flutter/material.dart';
import 'step_type_form_base.dart';
import '../../../../../data/models/step_type_model.dart';

class TaskAuthorApprovalStepForm extends StepTypeFormBase {
  const TaskAuthorApprovalStepForm({
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
  TaskAuthorApprovalStepFormState createState() => TaskAuthorApprovalStepFormState();
}

class TaskAuthorApprovalStepFormState extends StepTypeFormBaseState<TaskAuthorApprovalStepForm> {
  final _materialTypeController = TextEditingController();
  bool _autoApprove = false;
  final List<String> _materialTypes = [
    'share_material',
    'share_location',
  ];

  @override
  void dispose() {
    _materialTypeController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'Task Author Approval Title';

  @override
  String get descriptionPlaceholder => 'Instructions for approval process';

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'approvedMaterial': _materialTypeController.text,
      'autoApprove': _autoApprove,
    };
  }

  String _getMaterialTypeDisplayName(String type) {
    switch (type) {
      case 'share_material':
        return 'Shared Material';
      case 'share_location':
        return 'Shared Location';
      default:
        return type;
    }
  }

  IconData _getIconForMaterialType(String type) {
    switch (type) {
      case 'share_material':
        return Icons.share;
      case 'share_location':
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
            labelText: 'Material to Approve',
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
              return 'Please select a material type to approve';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Automatic Approval'),
          subtitle: const Text('Automatically approve submissions without review'),
          value: _autoApprove,
          onChanged: (value) {
            setState(() {
              _autoApprove = value;
            });
          },
        ),
        if (_autoApprove) ...[
          const SizedBox(height: 8),
          Card(
            color: Colors.amber[50],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Automatic approval will bypass manual review. Use with caution.',
                      style: TextStyle(color: Colors.orange),
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
