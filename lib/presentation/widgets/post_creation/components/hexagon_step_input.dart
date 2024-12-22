import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../domain/repositories/step_type_repository.dart';
import '../../../../data/models/step_type_model.dart';
import 'hexagon_grid_page.dart';
import '../../../widgets/common/hexagon_central_tiles.dart';

class HexagonStepInput {
  final StepTypeRepository _stepTypeRepository;
  List<StepTypeModel>? _stepTypes;
  final Map<int, Color> _hexagonColors = {};
  static const Color defaultColor = Colors.blue;
  static const int numberOfCentralHexagons = 3; // Exactly 3 hexagons, made constant

  // Central indices in 9x9 grid
  static const List<int> centralIndices = [
    39, // Left of center (4,3)
    41, // Right of center (4,5)
    31, // Top of center (3,4)
    49, // Bottom of center (5,4)
  ];

  HexagonStepInput(this._stepTypeRepository);

  Future<void> initialize() async {
    try {
      _stepTypes = await _stepTypeRepository.getStepTypes();
      if (_stepTypes == null || _stepTypes!.isEmpty) {
        throw Exception('No step types found');
      }
      _updateHexagonColors();
    } catch (e) {
      print('Error loading step types: $e');
      rethrow; // Rethrow to let parent handle the error
    }
  }

  void _updateHexagonColors() {
    if (_stepTypes != null) {
      // Assign step type colors to the central positions
      for (var i = 0; i < _stepTypes!.length && i < centralIndices.length; i++) {
        try {
          _hexagonColors[centralIndices[i]] = Color(
            int.parse(_stepTypes![i].color.replaceAll('#', '0xFF')),
          );
        } catch (e) {
          _hexagonColors[centralIndices[i]] = defaultColor;
        }
      }
    }
  }

  Color getColorForHexagon(int index) {
    // Convert index to row and column
    final row = index ~/ GridInitializer.nrX;
    final col = index % GridInitializer.nrX;

    // Center position (4,4)
    const centerRow = 4;
    const centerCol = 4;

    // Center tile with search icon always stays yellow
    if (row == centerRow && col == centerCol) {
      return Colors.yellow;
    }

    // Check if this is within the central area
    if (HexagonCentralTiles.isCentralHexagon(row, col, GridInitializer.nrY,
        GridInitializer.nrX, numberOfCentralHexagons)) {
      // If this is one of our central positions and has a step type color, use it
      if (_hexagonColors.containsKey(index)) {
        return _hexagonColors[index]!;
      }
      // Otherwise use yellow for central area
      return Colors.yellow;
    }

    // Outside central area is blue
    return defaultColor;
  }
}

class StepTypeHexagonPainter extends CustomPainter {
  static const int SIDES_OF_HEXAGON = 6;
  final Offset center;
  final double radius;
  final bool clicked;
  final Color hexagonColor;

  StepTypeHexagonPainter({
    required this.center,
    required this.radius,
    required this.clicked,
    required this.hexagonColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = clicked ? Colors.pink : hexagonColor;
    Path path = createHexagonPath();
    canvas.drawPath(path, paint);
  }

  Path createHexagonPath() {
    final path = Path();
    var startAngle = math.pi / 2;
    var angle = (math.pi * 2) / SIDES_OF_HEXAGON;

    Offset firstPoint =
        Offset(radius * math.cos(startAngle), radius * math.sin(startAngle));
    path.moveTo(firstPoint.dx + center.dx, firstPoint.dy + center.dy);

    for (int i = 1; i <= SIDES_OF_HEXAGON; i++) {
      double x = radius * math.cos(startAngle + angle * i) + center.dx;
      double y = radius * math.sin(startAngle + angle * i) + center.dy;
      path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(StepTypeHexagonPainter oldDelegate) =>
      oldDelegate.clicked != clicked ||
      oldDelegate.hexagonColor != hexagonColor;
}
