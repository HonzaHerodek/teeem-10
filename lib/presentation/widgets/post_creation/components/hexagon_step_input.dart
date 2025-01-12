import 'package:flutter/material.dart';
import '../../../../domain/repositories/step_type_repository.dart';
import '../../../../data/models/step_type_model.dart';
import 'hexagon_grid_page.dart';
import 'hexagon_color_manager.dart';

class StepInfo {
  final Color color;
  final String name;
  final IconData icon;

  StepInfo({required this.color, required this.name, required this.icon});
}

class HexagonStepInput {
  final StepTypeRepository _stepTypeRepository;
  List<StepTypeModel>? _stepTypes;
  final Map<int, StepInfo> _hexagonSteps = {};
  static const int numberOfCentralHexagons = 3;
  int? _selectedIndex;

  // Grid layout for step types (9x9 grid)
  static const Map<String, List<int>> gridLayout = {
    // Available step types
    'consuming': [
      22, 23, 24, // Row 2 (shifted left)
      31, 32, 33, // Row 3 (shifted left)
    ],
    'interactive': [
      49, 50, 51, // Row 5 (shifted left)
      58, 59, 60, // Row 6 (shifted left)
    ],
    'admin': [
      41, 42, 43, // Row 4 (same as search)
    ],
    // Core elements
    'search': [40], // Center (4,4)
    'added_steps': [37, 38, 39], // Left of search (4,1-3)
  };

  // Track added steps during post creation
  final List<int> _addedStepIndices = [];

  IconData _getIconData(String iconName) {
    switch (iconName) {
      // Basic content types
      case 'text_fields':
        return Icons.text_fields;
      case 'image':
        return Icons.image;
      case 'code':
        return Icons.code;
      case 'video_library':
        return Icons.video_library;
      // Additional content types
      case 'audiotrack':
        return Icons.audiotrack;
      case 'description':
        return Icons.description;
      case 'link':
        return Icons.link;
      case 'quiz':
        return Icons.quiz;
      // Immersive content types
      case 'view_in_ar':
        return Icons.view_in_ar;
      case 'vrpano':
        return Icons.vrpano;
      default:
        return Icons.help_outline;
    }
  }

  HexagonStepInput(this._stepTypeRepository);

  Future<void> initialize() async {
    try {
      _stepTypes = await _stepTypeRepository.getStepTypes();
      if (_stepTypes == null || _stepTypes!.isEmpty) {
        throw Exception('No step types found');
      }
      _updateHexagonSteps();
    } catch (e) {
      print('Error loading step types: $e');
      rethrow;
    }
  }

  void _updateHexagonSteps() {
    if (_stepTypes != null) {
      // Clear existing steps
      _hexagonSteps.clear();

      // Sort step types by category
      // Get consuming types (content types)
      var consumingTypes = _stepTypes!.where((t) => [
        'text', 'image', 'video', 'link', 'vr', 'ar'
      ].contains(t.id.toLowerCase())).toList();

      // Get interactive types
      var interactiveTypes = _stepTypes!.where((t) => [
        'share_material', 'share_location', 'select', 'quiz', 
        'share_out', 'download', 'upload'
      ].contains(t.id.toLowerCase())).toList();

      // Get admin types
      var adminTypes = _stepTypes!.where((t) => [
        'task_author_approval', 'respondent_approval', 'conditional_route'
      ].contains(t.id.toLowerCase())).toList();

      // Sort types by their order in the overview
      consumingTypes.sort((a, b) => [
        'text', 'image', 'video', 'link', 'vr', 'ar'
      ].indexOf(a.id.toLowerCase()) - 
      ['text', 'image', 'video', 'link', 'vr', 'ar']
      .indexOf(b.id.toLowerCase()));

      interactiveTypes.sort((a, b) => [
        'share_material', 'share_location', 'select', 'quiz', 
        'share_out', 'download', 'upload'
      ].indexOf(a.id.toLowerCase()) - 
      ['share_material', 'share_location', 'select', 'quiz', 
        'share_out', 'download', 'upload']
      .indexOf(b.id.toLowerCase()));

      adminTypes.sort((a, b) => [
        'task_author_approval', 'respondent_approval', 'conditional_route'
      ].indexOf(a.id.toLowerCase()) - 
      ['task_author_approval', 'respondent_approval', 'conditional_route']
      .indexOf(b.id.toLowerCase()));

      // Place consuming types (above search)
      for (var i = 0; i < consumingTypes.length && i < gridLayout['consuming']!.length; i++) {
        _addStepTypeToHexagon(consumingTypes[i], gridLayout['consuming']![i]);
      }

      // Place interactive types (below search)
      for (var i = 0; i < interactiveTypes.length && i < gridLayout['interactive']!.length; i++) {
        _addStepTypeToHexagon(interactiveTypes[i], gridLayout['interactive']![i]);
      }

      // Place admin types (right of search)
      for (var i = 0; i < adminTypes.length && i < gridLayout['admin']!.length; i++) {
        _addStepTypeToHexagon(adminTypes[i], gridLayout['admin']![i]);
      }

      // Add search hexagon
      _hexagonSteps[gridLayout['search']![0]] = StepInfo(
        color: Colors.blue,
        name: 'Search',
        icon: Icons.search,
      );
    }
  }

  void _addStepTypeToHexagon(StepTypeModel stepType, int index) {
    try {
      _hexagonSteps[index] = StepInfo(
        color: Color(int.parse(stepType.color.replaceAll('#', '0xFF'))),
        name: stepType.name,
        icon: _getIconData(stepType.icon),
      );
    } catch (e) {
      _hexagonSteps[index] = StepInfo(
        color: HexagonColorManager.defaultColor,
        name: '',
        icon: Icons.help_outline,
      );
    }
  }

  // Add a step during post creation
  void addStep(StepTypeModel stepType) {
    if (_addedStepIndices.length < gridLayout['added_steps']!.length) {
      final index = gridLayout['added_steps']![_addedStepIndices.length];
      _addStepTypeToHexagon(stepType, index);
      _addedStepIndices.add(index);
    }
  }

  // Remove a step during post creation
  void removeStep(int index) {
    if (_addedStepIndices.contains(index)) {
      _hexagonSteps.remove(index);
      _addedStepIndices.remove(index);
      // Shift remaining added steps to maintain contiguous layout
      _reorderAddedSteps();
    }
  }

  // Reorder added steps to maintain contiguous layout from left to right
  void _reorderAddedSteps() {
    final steps = _addedStepIndices
        .map((index) => _hexagonSteps[index])
        .where((step) => step != null)
        .toList();
    
    // Clear existing added steps
    for (var index in List.from(_addedStepIndices)) {
      _hexagonSteps.remove(index);
    }
    _addedStepIndices.clear();

    // Re-add steps in order
    for (var i = 0; i < steps.length; i++) {
      final index = gridLayout['added_steps']![i];
      _hexagonSteps[index] = steps[i]!;
      _addedStepIndices.add(index);
    }
  }

  StepInfo? getSelectedStepInfo() {
    if (_selectedIndex != null) {
      return _hexagonSteps[_selectedIndex];
    }
    return null;
  }

  StepTypeModel? getStepTypeFromInfo(StepInfo info) {
    return _stepTypes?.firstWhere(
      (type) => type.name == info.name,
      orElse: () => throw Exception('Step type not found'),
    );
  }

  void setSelectedIndex(int index) {
    if (_hexagonSteps.containsKey(index)) {
      _selectedIndex = index;
    }
  }

  Color getColorForHexagon(int index) {
    return HexagonColorManager.getColorForHexagon(
      index,
      _hexagonSteps,
      GridInitializer.nrX,
    );
  }

  StepInfo? getStepInfoForHexagon(int index) {
    return _hexagonSteps[index];
  }

  // Get all available step type indices
  List<int> get availableStepTypeIndices {
    return [
      ...gridLayout['consuming']!,
      ...gridLayout['interactive']!,
      ...gridLayout['admin']!,
    ];
  }

  // Check if an index is in the added steps section
  bool isAddedStepIndex(int index) {
    return gridLayout['added_steps']!.contains(index);
  }

  // Check if an index is the search hexagon
  bool isSearchIndex(int index) {
    return gridLayout['search']![0] == index;
  }
}
