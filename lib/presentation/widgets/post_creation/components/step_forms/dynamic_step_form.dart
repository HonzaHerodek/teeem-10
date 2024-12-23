import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';
import 'step_form_data.dart';

class DynamicStepForm extends StepTypeFormBase {
  const DynamicStepForm({
    Key? key,
    required StepTypeModel stepType,
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) : super(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );

  @override
  DynamicStepFormState createState() => DynamicStepFormState();
}

class DynamicStepFormState extends StepTypeFormBaseState<DynamicStepForm> {
  final Map<String, dynamic> _formData = {};
  List<String> _errors = [];

  @override
  Widget buildFormFields() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
        if (_errors.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _errors.map((error) => Text(
                error,
                style: TextStyle(color: Colors.red.shade700),
              )).toList(),
            ),
          ),
        ],
        ...widget.stepType.options.map((option) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildFormField(option),
          );
        }).toList(),
        ],
      ),
    );
  }

  Widget _buildFormField(StepTypeOption option) {
    switch (option.type) {
      case 'text':
        return TextFormField(
          decoration: InputDecoration(
            labelText: option.label,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '${option.label} is required';
            }
            return null;
          },
          onSaved: (value) {
            _formData[option.id] = value;
          },
        );

      case 'number':
        return TextFormField(
          decoration: InputDecoration(
            labelText: option.label,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '${option.label} is required';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          onSaved: (value) {
            _formData[option.id] = double.tryParse(value ?? '0');
          },
        );

      case 'select':
        final List<String> options = 
            (option.config?['options'] as List<dynamic>?)?.cast<String>() ?? [];
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: option.label,
            border: const OutlineInputBorder(),
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select ${option.label}';
            }
            return null;
          },
          onChanged: (String? value) {
            setState(() {
              _formData[option.id] = value;
            });
          },
          onSaved: (value) {
            _formData[option.id] = value;
          },
        );

      default:
        return Text('Unsupported field type: ${option.type}');
    }
  }

  StepFormData getFormData() {
    return StepFormData(
      stepType: widget.stepType,
      formData: Map<String, dynamic>.from(_formData),
    );
  }

  bool validate() {
    final formData = getFormData();
    _errors = formData.validate();
    setState(() {});
    return _errors.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    _errors = [];
  }
}
