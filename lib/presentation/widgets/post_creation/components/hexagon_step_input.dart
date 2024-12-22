import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../domain/repositories/step_type_repository.dart';
import '../../../../data/models/step_type_model.dart';
import 'hexagon_grid_page.dart';
import '../../../widgets/common/hexagon_central_tiles.dart';
import '../../../widgets/common/shadowed_shape.dart';

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
  static const Color defaultColor = Colors.grey; // Changed from blue to grey
  static const int numberOfCentralHexagons = 3;

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
      for (var i = 0;
          i < _stepTypes!.length && i < centralIndices.length;
          i++) {
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
    final row = index ~/ GridInitializer.nrX;
    final col = index % GridInitializer.nrX;
    const centerRow = 4;
    const centerCol = 4;

    if (row == centerRow && col == centerCol) {
      return Colors.grey; // Center tile color will be handled by gradient
    }

    if (HexagonCentralTiles.isCentralHexagon(row, col, GridInitializer.nrY,
        GridInitializer.nrX, numberOfCentralHexagons)) {
      if (_hexagonSteps.containsKey(index)) {
        return _hexagonSteps[index]!.color;
      }
      return Colors.grey[300]!; // Light grey for yellow tiles
    }

    return Colors.grey; // Grey for outer tiles
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
    final path = createHexagonPath();

    // Draw hexagon with gradient and opacity
    if (showSearchIcon) {
      // Center tile with search icon - gradient grey and white stroke
      final gradient = RadialGradient(
        center: Alignment.topLeft,
        radius: 1.5,
        colors: [Colors.grey[300]!, Colors.grey[600]!],
      );
      final paint = Paint()
        ..shader = gradient.createShader(path.getBounds())
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      // White stroke for center tile
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(path, strokePaint);
    } else {
      final paint = Paint()..style = PaintingStyle.fill;
      if (hexagonColor == Colors.grey) {
        // Outer tiles - lighter gradient with 65% opacity
        final gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(220, 220, 220, 0.65),  // Very light grey
            Color.fromRGBO(180, 180, 180, 0.65),  // Light grey
          ],
        );
        paint.shader = gradient.createShader(path.getBounds());
      } else if (hexagonColor == Colors.grey[300]) {
        // Central tiles - pronounced gradient with 40% opacity
        final gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(180, 180, 180, 0.4),  // Light grey
            Color.fromRGBO(100, 100, 100, 0.4),  // Dark grey
          ],
        );
        paint.shader = gradient.createShader(path.getBounds());
      } else {
        // Step type colored tiles or clicked state
        paint.color = clicked ? Colors.pink : hexagonColor;
      }
      canvas.drawPath(path, paint);
    }

    if (showSearchIcon) {
      // Draw shadowed search icon
      final iconSize = radius * 0.8;
      final iconRect = Rect.fromCenter(
        center: center,
        width: iconSize,
        height: iconSize,
      );

      // Use custom shadowed shape for search icon
      canvas.save();
      canvas.translate(center.dx - iconSize / 2, center.dy - iconSize / 2);
      canvas.scale(iconSize / 24); // Scale to match the icon size
      paintShadowedIcon(canvas, Icons.search, Colors.white);
      canvas.restore();
    } else if (stepInfo != null) {
      // Draw step info
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

      iconPainter.paint(
        canvas,
        Offset(
          center.dx - iconPainter.width / 2,
          center.dy - textPainter.height - iconPainter.height / 2,
        ),
      );

      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy + iconPainter.height / 4,
        ),
      );
    } else if (hexagonColor == Colors.grey[300]) {
      // Draw question mark icon for yellow replacement tiles
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.help_outline.codePoint),
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: radius * 0.5,
            fontFamily: 'MaterialIcons',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(
          center.dx - iconPainter.width / 2,
          center.dy - iconPainter.height / 2,
        ),
      );
    }
  }

  void paintShadowedIcon(Canvas canvas, IconData icon, Color color) {
    const shadowOffsets = [
      Offset(3, 3),
      Offset(-3, -3),
      Offset(3, -3),
      Offset(-3, 3),
      Offset(2, 2),
      Offset(-2, -2),
      Offset(2, -2),
      Offset(-2, 2),
      Offset(1, 1),
      Offset(-1, -1),
      Offset(1, -1),
      Offset(-1, 1),
      Offset(0, 0),
    ];

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'MaterialIcons',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();

    for (var i = 0; i < shadowOffsets.length - 1; i++) {
      final opacity = 0.2 * (1 - (i / shadowOffsets.length));
      iconPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'MaterialIcons',
          color: Colors.black.withOpacity(opacity),
        ),
      );
      iconPainter.layout();
      iconPainter.paint(canvas, shadowOffsets[i]);
    }

    // Main icon
    iconPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 24,
        fontFamily: 'MaterialIcons',
        color: color,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(canvas, shadowOffsets.last);
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
