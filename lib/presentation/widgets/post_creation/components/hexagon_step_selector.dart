import 'package:flutter/material.dart';
import '../../../../data/models/step_type_model.dart';
import 'hexagon_grid_page.dart';
import 'hexagon_step_input.dart';
import '../../../../domain/repositories/step_type_repository.dart';
import 'step_forms/step_type_form_creator.dart';

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
            child: StepTypeFormCreator.createForm(
              stepType: _selectedStepType!,
              onCancel: () => setState(() => _selectedStepType = null),
              onSave: (formData) {
                // Each form implementation will handle its own validation
                // and call onSave only when validation passes
                widget.onStepFormSubmitted(_selectedStepType!, formData);
                setState(() => _selectedStepType = null);
              },
            ),
          ),
      ],
    );
  }
}
