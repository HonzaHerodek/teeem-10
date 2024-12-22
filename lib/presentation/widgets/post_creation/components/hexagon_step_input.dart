import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../domain/repositories/step_type_repository.dart';
import '../../../../data/models/step_type_model.dart';
import 'hexagon_grid_page.dart';
import '../../../widgets/common/hexagon_central_tiles.dart';

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
  static const Color defaultColor = Colors.blue;
  static const int numberOfCentralHexagons = 3; // Exactly 3 hexagons, made constant

  // Central indices in 9x9 grid
  static const List<int> centralIndices = [
    39, // Left of center (4,3)
    41, // Right of center (4,5)
    31, // Top of center (3,4)
    49, // Bottom of center (5,4)
  ];

  // Convert icon name to IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'text_fields': return Icons.text_fields;
      case 'image': return Icons.image;
      case 'code': return Icons.code;
      case 'video_library': return Icons.video_library;
      default: return Icons.help_outline;
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
      rethrow; // Rethrow to let parent handle the error
    }
  }

  void _updateHexagonSteps() {
    if (_stepTypes != null) {
      // Assign step type info to the central positions
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
            color: defaultColor,
            name: '',
            icon: Icons.help_outline,
          );
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
      if (_hexagonSteps.containsKey(index)) {
        return _hexagonSteps[index]!.color;
      }
      // Otherwise use yellow for central area
      return Colors.yellow;
    }

    // Outside central area is blue
    return defaultColor;
  }

  StepInfo? getStepInfoForHexagon(int index) {
    return _hexagonSteps[index];
  }
}

class StepTypeHexagonPainter extends CustomPainter {
  static const int SIDES_OF_HEXAGON = 6;
  final Offset center;
  final double radius;
  final bool clicked;
  final Color hexagonColor;
  final StepInfo? stepInfo;
  final bool showSearchIcon;

  StepTypeHexagonPainter({
    required this.center,
    required this.radius,
    required this.clicked,
    required this.hexagonColor,
    this.stepInfo,
    this.showSearchIcon = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw hexagon
    Paint paint = Paint()..color = clicked ? Colors.pink : hexagonColor;
    Path path = createHexagonPath();
    canvas.drawPath(path, paint);

    // Draw search icon if needed
    if (showSearchIcon) {
      final iconPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw search circle
      final circleRadius = radius * 0.4;
      canvas.drawCircle(
        Offset(center.dx, center.dy),
        circleRadius,
        iconPaint,
      );

      // Draw search handle
      final handleStart = Offset(
        center.dx + circleRadius * math.cos(math.pi / 4),
        center.dy + circleRadius * math.sin(math.pi / 4),
      );
      final handleEnd = Offset(
        center.dx + radius * 0.7 * math.cos(math.pi / 4),
        center.dy + radius * 0.7 * math.sin(math.pi / 4),
      );
      canvas.drawLine(handleStart, handleEnd, iconPaint);
    }

    // Draw step info if available
    if (stepInfo != null) {
      // Draw name
      final textPainter = TextPainter(
        text: TextSpan(
          text: stepInfo!.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.25,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Draw icon using Material Icons
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(stepInfo!.icon.codePoint),
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.5,
            fontFamily: 'MaterialIcons',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();

      // Position icon above name
      iconPainter.paint(
        canvas,
        Offset(
          center.dx - iconPainter.width / 2,
          center.dy - textPainter.height - iconPainter.height / 2,
        ),
      );

      // Position name below icon
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy + iconPainter.height / 4,
        ),
      );
    }
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
      oldDelegate.hexagonColor != hexagonColor ||
      oldDelegate.stepInfo != stepInfo ||
      oldDelegate.showSearchIcon != showSearchIcon;
}
