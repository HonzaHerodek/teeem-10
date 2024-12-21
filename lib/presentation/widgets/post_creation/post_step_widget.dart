import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/step_type_model.dart';
import '../../../core/utils/step_type_utils.dart';
import '../common/honeycomb_grid.dart';

class PostStepWidget extends StatefulWidget {
  final VoidCallback onRemove;
  final int stepNumber;
  final bool enabled;
  final List<StepTypeModel> stepTypes;

  const PostStepWidget({
    super.key,
    required this.onRemove,
    required this.stepNumber,
    required this.stepTypes,
    this.enabled = true,
  });

  PostStep? toPostStep() {
    if (key is GlobalKey<PostStepWidgetState>) {
      final state = (key as GlobalKey<PostStepWidgetState>).currentState;
      if (state != null) {
        return state.getStepData();
      }
    }
    return null;
  }

  @override
  State<PostStepWidget> createState() => PostStepWidgetState();
}

class PostStepWidgetState extends State<PostStepWidget>
    with AutomaticKeepAliveClientMixin {
  StepTypeModel? _selectedStepType;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Map<String, TextEditingController> _optionControllers = {};

  @override
  bool get wantKeepAlive => true;

  bool get hasSelectedStepType => _selectedStepType != null;

  StepTypeModel? getSelectedStepType() {
    return _selectedStepType;
  }

  StepType _getStepTypeFromId(String id) {
    return StepType.values.firstWhere(
      (type) => type.toString().split('.').last == id,
      orElse: () => StepType.text,
    );
  }

  @override
  void initState() {
    super.initState();
    // Auto-select the first step type if available
    if (widget.stepTypes.isNotEmpty) {
      _onStepTypeSelected(widget.stepTypes.first);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _optionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeOptionControllers() {
    if (_selectedStepType == null) return;
    for (final option in _selectedStepType!.options) {
      _optionControllers[option.id] = TextEditingController();
    }
  }

  void _restoreOptionValues() {
    if (_selectedStepType == null) return;
    for (final option in _selectedStepType!.options) {
      if (_optionControllers.containsKey(option.id)) {
        // Restore value if available
        // _optionControllers[option.id]!.text = _optionValues[option.id] ?? '';
      }
    }
  }

  void _onStepTypeSelected(StepTypeModel type) {
    setState(() {
      _selectedStepType = type;
      // Clear and reinitialize option controllers
      for (final controller in _optionControllers.values) {
        controller.dispose();
      }
      _optionControllers.clear();
      _initializeOptionControllers();
      _restoreOptionValues();
      updateKeepAlive();
    });
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  PostStep getStepData() {
    if (_selectedStepType == null) {
      throw Exception('Step type not selected');
    }

    final content = <String, dynamic>{};
    for (final option in _selectedStepType!.options) {
      content[option.id] = _optionControllers[option.id]?.text ?? '';
    }

    return PostStep(
      id: 'step_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      description: _descriptionController.text,
      type: _getStepTypeFromId(_selectedStepType!.id),
      content: content,
    );
  }

  Widget _buildStepTypeMiniature(StepTypeModel type) {
    final stepType = _getStepTypeFromId(type.id);
    final color = StepTypeUtils.getColorForStepType(stepType);

    return GestureDetector(
      onTap: widget.enabled ? () => _onStepTypeSelected(type) : null,
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
                  size: 32,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    type.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  Widget _buildStepForm() {
    final stepType = _selectedStepType != null ? _getStepTypeFromId(_selectedStepType!.id) : null;
    final color = stepType != null ? StepTypeUtils.getColorForStepType(stepType) : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Text(
                  'Step ${widget.stepNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (stepType != null) ...[
                  Icon(
                    StepTypeUtils.getIconForStepType(stepType),
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    StepTypeUtils.getStepTypeDisplayName(stepType),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: widget.enabled ? widget.onRemove : null,
                  tooltip: 'Remove step',
                ),
              ],
            ),
          ),
          // Step form
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    enabled: widget.enabled,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Step Title',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      hintText: 'e.g., Mix the ingredients',
                      hintStyle: TextStyle(color: Colors.white30),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a step title';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      updateKeepAlive();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    enabled: widget.enabled,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Step Description',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      hintText: 'Brief description of this step',
                      hintStyle: TextStyle(color: Colors.white30),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a step description';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      updateKeepAlive();
                    },
                  ),
                  ..._selectedStepType!.options.map((option) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextFormField(
                          controller: _optionControllers[option.id],
                          enabled: widget.enabled,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: option.label,
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            hintStyle: const TextStyle(color: Colors.white30),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please fill in this field';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            updateKeepAlive();
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: _selectedStepType == null
          ? LayoutBuilder(
              builder: (context, constraints) {
                return HoneycombGrid(
                  cellSize: 100,
                  spacing: 8,
                  config: HoneycombConfig.area(
                    maxWidth: constraints.maxWidth,
                    maxItemsPerRow: 3,
                  ),
                  children: widget.stepTypes
                      .map((type) => _buildStepTypeMiniature(type))
                      .toList(),
                );
              },
            )
          : _buildStepForm(),
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
