import 'package:flutter/material.dart';
import '../../../../data/models/step_type_model.dart';
import 'hexagon_step_selector.dart';

class StepTypeSelectionPage extends StatelessWidget {
  final List<StepTypeModel> stepTypes;
  final Function(StepTypeModel) onStepTypeSelected;

  const StepTypeSelectionPage({
    Key? key,
    required this.stepTypes,
    required this.onStepTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Step Type',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 3,
                  color: Colors.black,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: HexagonStepSelector(
              stepTypes: stepTypes,
              onStepTypeSelected: onStepTypeSelected,
            ),
          ),
        ],
      ),
    );
  }
}
