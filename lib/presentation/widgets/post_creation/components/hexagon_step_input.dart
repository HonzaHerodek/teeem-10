import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../domain/repositories/step_type_repository.dart';
import '../../../../data/models/step_type_model.dart';
import 'hexagon_grid_page.dart';

class HexagonStepInput {
  final StepTypeRepository _stepTypeRepository;
  List<StepTypeModel>? _stepTypes;
  final Map<int, Color> _hexagonColors = {};
  static const Color defaultColor = Colors.blue;

  HexagonStepInput(this._stepTypeRepository);

  Future<void> initialize() async {
    try {
      _stepTypes = await _stepTypeRepository.getStepTypes();
      _updateHexagonColors();
    } catch (e) {
      // Handle error appropriately
      print('Error loading step types: $e');
    }
  }

  void _updateHexagonColors() {
    if (_stepTypes != null) {
      for (var i = 0; i < _stepTypes!.length; i++) {
        try {
          _hexagonColors[i] = Color(
            int.parse(_stepTypes![i].color.replaceAll('#', '0xFF')),
          );
        } catch (e) {
          _hexagonColors[i] = defaultColor;
        }
      }
    }
  }

  Color getColorForHexagon(int index) {
    return _hexagonColors[index] ?? defaultColor;
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
      oldDelegate.clicked != clicked || oldDelegate.hexagonColor != hexagonColor;
}
