import 'package:flutter/material.dart';
import 'step_type_form_base.dart';
import '../../../../../data/models/step_type_model.dart';

class SelectStepForm extends StepTypeFormBase {
  const SelectStepForm({
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
  SelectStepFormState createState() => SelectStepFormState();
}

class Option {
  String content;
  String type;

  Option({required this.content, required this.type});

  Map<String, dynamic> toJson() => {
        'content': content,
        'type': type,
      };
}

class SelectStepFormState extends StepTypeFormBaseState<SelectStepForm> {
  final List<Option> _options = [];
  bool _allowMultipleSelections = false;
  final _contentController = TextEditingController();
  String _selectedType = 'text';

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'Selection Title';

  @override
  String get descriptionPlaceholder => 'Instructions for selection';

  void _addOption() {
    if (_contentController.text.isNotEmpty) {
      setState(() {
        _options.add(Option(
          content: _contentController.text,
          type: _selectedType,
        ));
        _contentController.clear();
      });
    }
  }

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'options': _options.map((o) => o.toJson()).toList(),
      'allowMultiple': _allowMultipleSelections,
    };
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Option Content',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedType,
              items: ['text', 'image', 'video', 'link']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addOption,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_options.isNotEmpty) ...[
          const Text('Added Options:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List.generate(_options.length, (index) {
            final option = _options[index];
            return ListTile(
              dense: true,
              title: Text(option.content),
              subtitle: Text(option.type.toUpperCase()),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () {
                  setState(() {
                    _options.removeAt(index);
                  });
                },
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
        SwitchListTile(
          title: const Text('Allow Multiple Selections'),
          value: _allowMultipleSelections,
          onChanged: (value) {
            setState(() {
              _allowMultipleSelections = value;
            });
          },
        ),
      ],
    );
  }
}
