import 'package:flutter/material.dart';
import 'step_type_form_base.dart';
import '../../../../../data/models/step_type_model.dart';

class ShareLocationStepForm extends StepTypeFormBase {
  const ShareLocationStepForm({
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
  ShareLocationStepFormState createState() => ShareLocationStepFormState();
}

class ShareLocationStepFormState extends StepTypeFormBaseState<ShareLocationStepForm> {
  bool _isRoute = false;
  final _locationController = TextEditingController();
  final _trackingTimeController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    _trackingTimeController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'Share Location Title';

  @override
  String get descriptionPlaceholder => 'Instructions for sharing location';

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'isRoute': _isRoute,
      'requiredLocation': _locationController.text,
      'trackingTime': int.tryParse(_trackingTimeController.text) ?? 0,
    };
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          title: const Text('Share Route'),
          subtitle: Text(_isRoute ? 'Users will share their route' : 'Users will share their current location'),
          value: _isRoute,
          onChanged: (value) {
            setState(() {
              _isRoute = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Required Location',
            border: OutlineInputBorder(),
            helperText: 'Enter coordinates or location name',
          ),
        ),
        if (_isRoute) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _trackingTimeController,
            decoration: const InputDecoration(
              labelText: 'Tracking Time (minutes)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ],
    );
  }
}
