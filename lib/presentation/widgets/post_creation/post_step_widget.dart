import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../data/models/post_model.dart';
import '../../../data/models/step_type_model.dart';
import '../../../core/utils/step_type_utils.dart';
import '../common/honeycomb_grid.dart' hide HexagonClipper;
import '../common/hexagon_clipper.dart';
import 'components/step_form_field.dart';
import 'components/step_form_header.dart';

class PostStepWidget extends StatefulWidget {
  final VoidCallback onRemove;
  final int stepNumber;
  final bool enabled;
  final List<StepTypeModel> stepTypes;
  final StepTypeModel? initialStepType;
  final bool showFormInitially;

  const PostStepWidget({
    super.key,
    required this.onRemove,
    required this.stepNumber,
    required this.stepTypes,
    this.enabled = true,
    this.initialStepType,
    this.showFormInitially = false,
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
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _selectedStepType = widget.initialStepType;
    _showForm = widget.showFormInitially;
    if (_selectedStepType != null) {
      _initializeOptionControllers();
    }
  }

  @override
  bool get wantKeepAlive => true;

  bool get hasSelectedStepType => _showForm && _selectedStepType != null;

  StepTypeModel? getSelectedStepType() => _selectedStepType;

  StepType _getStepTypeFromId(String id) {
    return StepType.values.firstWhere(
      (type) => type.toString().split('.').last == id,
      orElse: () => StepType.text,
    );
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

  void _onStepTypeSelected(StepTypeModel type) {
    // Clear existing controllers if selecting a different type
    if (_selectedStepType?.id != type.id) {
      for (final controller in _optionControllers.values) {
        controller.dispose();
      }
      _optionControllers.clear();
    }

    setState(() {
      _selectedStepType = type;
      _showForm = true;
      _initializeOptionControllers();
    });

    updateKeepAlive();
  }

  bool validate() => _formKey.currentState?.validate() ?? false;

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
    final isSelected = _selectedStepType?.id == type.id;

    return ClipPath(
      clipper: HexagonClipper(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.4),
          highlightColor: color.withOpacity(0.3),
          onTap: widget.enabled ? () {
            HapticFeedback.lightImpact();
            _onStepTypeSelected(type);
          } : null,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isSelected ? color : color.withOpacity(0.7),
                  isSelected ? color.withOpacity(0.9) : color.withOpacity(0.5),
                ],
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(isSelected ? 0.3 : 0.15),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.7),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          StepTypeUtils.getIconForStepType(stepType),
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            type.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Icon(
                        Icons.touch_app,
                        color: Colors.white.withOpacity(0.9),
                        size: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepForm() {
    final stepType = _selectedStepType != null
        ? _getStepTypeFromId(_selectedStepType!.id)
        : null;
    final color = stepType != null
        ? StepTypeUtils.getColorForStepType(stepType)
        : Colors.grey;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Container(
        key: ValueKey('form_${_selectedStepType?.id}'),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StepFormHeader(
              stepNumber: widget.stepNumber,
              stepType: stepType,
              enabled: widget.enabled,
              onBack: () => setState(() => _showForm = false),
              onRemove: widget.onRemove,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StepFormField(
                      controller: _titleController,
                      label: 'Step Title',
                      hint: 'e.g., Mix the ingredients',
                      enabled: widget.enabled,
                      onChanged: updateKeepAlive,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a step title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    StepFormField(
                      controller: _descriptionController,
                      label: 'Step Description',
                      hint: 'Brief description of this step',
                      maxLines: 2,
                      enabled: widget.enabled,
                      onChanged: updateKeepAlive,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a step description';
                        }
                        return null;
                      },
                    ),
                    ..._selectedStepType!.options.map((option) => StepFormField(
                          controller: _optionControllers[option.id]!,
                          label: option.label,
                          enabled: widget.enabled,
                          onChanged: updateKeepAlive,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size.width - 32;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: _showForm
                  ? const Offset(-0.3, 0) // Slide from left when showing form
                  : const Offset(0.3, 0), // Slide from right when showing grid
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _showForm
          ? SizedBox(
              width: size,
              child: _buildStepForm(),
            )
          : SizedBox(
              width: size,
              height: size,
              child: HoneycombGrid(
                cellSize: 65,
                spacing: 0,
                config: HoneycombConfig.area(
                  maxWidth: size * 1.0,
                  maxItemsPerRow: math.min(3, widget.stepTypes.length),
                ),
                children: widget.stepTypes
                    .map((type) => _buildStepTypeMiniature(type))
                    .toList(),
              ),
            ),
    );
  }
}
