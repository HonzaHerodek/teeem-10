import 'package:flutter/material.dart';
import '../../../../data/models/step_type_model.dart';
import 'hexagon_grid_page.dart';
import 'hexagon_step_input.dart';
import '../../../../domain/repositories/step_type_repository.dart';
import 'step_forms/step_type_form_creator.dart';

class HexagonStepSelector extends StatefulWidget {
  final StepTypeRepository stepTypeRepository;
  final Function(StepTypeModel, Map<String, dynamic>) onStepFormSubmitted;
  final Function(bool) onFormVisibilityChanged;

  const HexagonStepSelector({
    super.key,
    required this.stepTypeRepository,
    required this.onStepFormSubmitted,
    required this.onFormVisibilityChanged,
  });

  @override
  HexagonStepSelectorState createState() => HexagonStepSelectorState();
}

class HexagonStepSelectorState extends State<HexagonStepSelector> {
  late final HexagonStepInput stepInput;
  StepTypeModel? _selectedStepType;
  bool _isLoading = true;

  void closeForm() {
    if (_selectedStepType != null) {
      setState(() {
        _selectedStepType = null;
      });
      widget.onFormVisibilityChanged(false);
    }
  }

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

  // Reference to the grid state
  final GlobalKey<HexagonGridState> _gridKey = GlobalKey();

  void _handleHexagonClick(int index) {
    final stepInfo = stepInput.getSelectedStepInfo();
    if (stepInfo != null) {
      final selectedType = stepInput.getStepTypeFromInfo(stepInfo);
      if (selectedType != null) {
        // Add step to grid
        stepInput.addStep(selectedType);
        
        // Force grid refresh
        _gridKey.currentState?.refreshGrid();
        
        // Update selected type and show form
        setState(() {
          _selectedStepType = selectedType;
        });
        widget.onFormVisibilityChanged(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Center(
          child: HexagonGrid(
            key: _gridKey,
            onHexagonClicked: _handleHexagonClick,
            stepInput: stepInput,
          ),
        ),
        if (_selectedStepType != null)
          Positioned.fill(
            child: StepTypeFormCreator.createForm(
              stepType: _selectedStepType!,
              onCancel: () {
                setState(() => _selectedStepType = null);
                widget.onFormVisibilityChanged(false);
              },
              onSave: (formData) {
                widget.onStepFormSubmitted(_selectedStepType!, formData);
                setState(() => _selectedStepType = null);
                widget.onFormVisibilityChanged(false);
              },
            ),
          ),
      ],
    );
  }
}
