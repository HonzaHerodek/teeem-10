import 'package:flutter/material.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/step_type_model.dart';
import '../../../../core/utils/step_type_utils.dart';
import '../../../widgets/post_creation/post_step_widget.dart';
import '../../../widgets/common/honeycomb_grid.dart';

class StepsSection extends StatelessWidget {
  final List<PostStepWidget> steps;
  final List<StepTypeModel> availableStepTypes;
  final bool isLoading;
  final Function(int) onRemoveStep;
  final Function(StepTypeModel) onAddStep;

  const StepsSection({
    super.key,
    required this.steps,
    required this.availableStepTypes,
    required this.isLoading,
    required this.onRemoveStep,
    required this.onAddStep,
  });

  StepType _getStepTypeFromId(String id) {
    return StepType.values.firstWhere(
      (type) => type.toString().split('.').last == id,
      orElse: () => StepType.text,
    );
  }

  Widget _buildStepTypeMiniature(StepTypeModel type) {
    final stepType = _getStepTypeFromId(type.id);
    final color = StepTypeUtils.getColorForStepType(stepType);

    return GestureDetector(
      onTap: isLoading ? null : () => onAddStep(type),
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: ClipPath(
          clipper: HexagonClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  StepTypeUtils.getIconForStepType(stepType),
                  color: Colors.white,
                  size: steps.isEmpty ? 32 : 20,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    type.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: steps.isEmpty ? 12 : 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (steps.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Steps',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => steps[index],
          ),
          const SizedBox(height: 16),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            return HoneycombGrid(
              cellSize: steps.isEmpty ? 100 : 60,
              spacing: steps.isEmpty ? 8 : 4,
              config: HoneycombConfig.area(
                maxWidth: constraints.maxWidth,
                maxItemsPerRow: steps.isEmpty ? 3 : 5,
              ),
              children: availableStepTypes
                  .map((type) => _buildStepTypeMiniature(type))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final h = size.height;
    final w = size.width;

    path.moveTo(w * 0.25, 0);
    path.lineTo(w * 0.75, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.75, h);
    path.lineTo(w * 0.25, h);
    path.lineTo(0, h * 0.5);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
