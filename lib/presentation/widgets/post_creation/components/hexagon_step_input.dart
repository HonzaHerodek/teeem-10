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

  // Central indices in 9x9 grid
  static const List<int> centralIndices = [
    39, // Left of center (4,3)
    41, // Right of center (4,5)
    31, // Top of center (3,4)
    49, // Bottom of center (5,4)
  ];

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'text_fields':
        return Icons.text_fields;
      case 'image':
        return Icons.image;
      case 'code':
        return Icons.code;
      case 'video_library':
        return Icons.video_library;
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
      for (var i = 0; i < _stepTypes!.length && i < centralIndices.length; i++) {
        try {
          final stepType = _stepTypes![i];
          _hexagonSteps[centralIndices[i]] = StepInfo(
            color: Color(int.parse(stepType.color.replaceAll('#', '0xFF'))),
            name: stepType.name,
            icon: _getIconData(stepType.icon),
          );
        } catch (e) {
          _hexagonSteps[centralIndices[i]] = StepInfo(
            color: HexagonColorManager.defaultColor,
            name: '',
            icon: Icons.help_outline,
          );
        }
      }
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
}
