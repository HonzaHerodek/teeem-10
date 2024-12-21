import 'package:flutter/material.dart';
import '../../../../core/utils/step_type_utils.dart';
import '../../../../data/models/step_type_model.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/step_type_model.dart';

class StepFormHeader extends StatelessWidget {
  final int stepNumber;
  final StepType? stepType;
  final bool enabled;
  final VoidCallback onBack;
  final VoidCallback onRemove;

  const StepFormHeader({
    super.key,
    required this.stepNumber,
    required this.stepType,
    required this.enabled,
    required this.onBack,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final color = stepType != null
        ? StepTypeUtils.getColorForStepType(stepType!)
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          Text(
            'Step $stepNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (stepType != null) ...[
            Icon(
              StepTypeUtils.getIconForStepType(stepType!),
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              StepTypeUtils.getStepTypeDisplayName(stepType!),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: enabled ? onBack : null,
            tooltip: 'Back to step types',
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: enabled ? onRemove : null,
            tooltip: 'Remove step',
          ),
        ],
      ),
    );
  }
}
