import 'package:flutter/material.dart';
import '../../../../data/models/step_type_model.dart';
import 'hexagon_grid_page.dart';
import 'hexagon_step_input.dart';
import '../../../../domain/repositories/step_type_repository.dart';
import 'step_forms/dynamic_step_form.dart';

class HexagonStepSelector extends StatefulWidget {
  final StepTypeRepository stepTypeRepository;
  final Function(StepTypeModel, Map<String, dynamic>) onStepFormSubmitted;

  const HexagonStepSelector({
    Key? key,
    required this.stepTypeRepository,
    required this.onStepFormSubmitted,
  }) : super(key: key);

  @override
  State<HexagonStepSelector> createState() => _HexagonStepSelectorState();
}

class _HexagonStepSelectorState extends State<HexagonStepSelector> {
  late final HexagonStepInput stepInput;
  StepTypeModel? _selectedStepType;
  bool _isLoading = true;
  final GlobalKey<DynamicStepFormState> _formKey = GlobalKey<DynamicStepFormState>();

  @override
  void initState() {
    super.initState();
    stepInput = HexagonStepInput(widget.stepTypeRepository);
    _initializeStepInput();
  }

  Future<void> _initializeStepInput() async {
    try {
      await stepInput.initialize();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleHexagonClick() {
    final stepInfo = stepInput.getSelectedStepInfo();
    if (stepInfo != null) {
      setState(() {
        _selectedStepType = stepInput.getStepTypeFromInfo(stepInfo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        HexagonGridPage(
          onHexagonClicked: _handleHexagonClick,
          stepInput: stepInput,
        ),
        if (_selectedStepType != null)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: DynamicStepForm(
              key: _formKey,
              stepType: _selectedStepType!,
              onCancel: () => setState(() => _selectedStepType = null),
              onSave: () {
                final formState = _formKey.currentState;
                if (formState != null && formState.validate()) {
                  final formData = formState.getFormData();
                  widget.onStepFormSubmitted(_selectedStepType!, formData.formData);
                  setState(() => _selectedStepType = null);
                }
              },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
