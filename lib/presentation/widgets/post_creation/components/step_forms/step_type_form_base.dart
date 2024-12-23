import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';

abstract class StepTypeFormBase extends StatefulWidget {
  final StepTypeModel stepType;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const StepTypeFormBase({
    Key? key,
    required this.stepType,
    required this.onCancel,
    required this.onSave,
  }) : super(key: key);
}

abstract class StepTypeFormBaseState<T extends StepTypeFormBase>
    extends State<T> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Configure ${widget.stepType.name} Step',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                buildFormFields(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _formKey.currentState?.save();
                          widget.onSave();
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFormFields();
}
