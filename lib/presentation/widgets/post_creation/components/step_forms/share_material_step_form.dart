import 'package:flutter/material.dart';
import 'step_type_form_base.dart';
import '../../../../../data/models/step_type_model.dart';

class ShareMaterialStepForm extends StepTypeFormBase {
  const ShareMaterialStepForm({
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
  ShareMaterialStepFormState createState() => ShareMaterialStepFormState();
}

class ShareMaterialStepFormState extends StepTypeFormBaseState<ShareMaterialStepForm> {
  final _materialTypeController = TextEditingController();
  bool _allowMultipleResponses = false;

  @override
  void dispose() {
    _materialTypeController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'Share Material Title';

  @override
  String get descriptionPlaceholder => 'Instructions for sharing material';

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'materialType': _materialTypeController.text,
      'allowMultiple': _allowMultipleResponses,
    };
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Material Type',
            border: OutlineInputBorder(),
          ),
          value: _materialTypeController.text.isEmpty ? null : _materialTypeController.text,
          items: ['text', 'link', 'image', 'video']
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
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
              return 'Please select a material type';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Allow Multiple Responses'),
          value: _allowMultipleResponses,
          onChanged: (value) {
            setState(() {
              _allowMultipleResponses = value;
            });
          },
        ),
      ],
    );
  }
}
