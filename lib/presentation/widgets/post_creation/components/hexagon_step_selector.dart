import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import '../../../../data/models/step_type_model.dart';
import '../../../../data/models/post_model.dart';
import '../../../../core/utils/step_type_utils.dart';

class HexagonStepSelector extends StatelessWidget {
  final List<StepTypeModel> stepTypes;
  final Function(StepTypeModel) onStepTypeSelected;

  const HexagonStepSelector({
    Key? key,
    required this.stepTypes,
    required this.onStepTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final grid = HexagonGrid(
          stepTypes: stepTypes,
          onStepTypeSelected: onStepTypeSelected,
        );
        grid.initialize(constraints.maxWidth, constraints.maxHeight);
        return Listener(
          onPointerDown: (event) => grid.handleClick(event),
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            color: Colors.transparent,
            child: grid,
          ),
        );
      },
    );
  }
}

class HexagonGrid extends StatelessWidget {
  final List<StepTypeModel> stepTypes;
  final Function(StepTypeModel) onStepTypeSelected;
  final List<HexagonPaint> hexagons = [];

  HexagonGrid({
    Key? key,
    required this.stepTypes,
    required this.onStepTypeSelected,
  }) : super(key: key);

  void initialize(double screenWidth, double screenHeight) {
    if (hexagons.isEmpty) {
      final initializer = GridInitializer();
      hexagons.addAll(
        initializer.getHexagons(screenWidth, screenHeight, stepTypes),
      );
    }
  }

  void handleClick(PointerEvent details) {
    for (var hexagon in hexagons) {
      if (hexagon.determineClick(details)) {
        hexagon.key.currentState?.updateSelected();
        if (hexagon.stepType != null) {
          onStepTypeSelected(hexagon.stepType!);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: hexagons);
  }
}

class GridInitializer {
  static const int marginY = 5;
  static const int marginX = 5;
  static const int nrX = 3; // Reduced from 6 to fit in circular frame
  static const int nrY = 4; // Reduced from 9 to fit in circular frame
  double radius = 0;
  double height = 0;
  double screenWidth = 0;
  double screenHeight = 0;

  List<HexagonPaint> getHexagons(
    double screenWidth,
    double screenHeight,
    List<StepTypeModel> stepTypes,
  ) {
    var hexagons = <HexagonPaint>[];
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    radius = computeRadius(screenWidth, screenHeight);
    height = computeHeight(radius);

    int stepTypeIndex = 0;
    for (int x = 0; x < nrX; x++) {
      for (int y = 0; y < nrY; y++) {
        if (stepTypeIndex < stepTypes.length) {
          hexagons.add(
            HexagonPaint(
              HexagonModel(
                center: computeCenter(x, y),
                radius: radius,
                stepType: stepTypes[stepTypeIndex],
              ),
            ),
          );
          stepTypeIndex++;
        }
      }
    }
    return hexagons;
  }

  double computeRadius(double screenWidth, double screenHeight) {
    var maxWidth = (screenWidth - totalMarginX()) / (((nrX - 1) * 1.5) + 2);
    var maxHeight = 0.5 *
        (screenHeight - totalMarginY()) /
        (heightRatioOfRadius() * (nrY + 0.5));
    return math.min(maxWidth, maxHeight);
  }

  static double heightRatioOfRadius() =>
      math.cos(math.pi / HexagonPainter.SIDES_OF_HEXAGON);

  static double totalMarginY() => (nrY - 0.5) * marginY;

  static int totalMarginX() => (nrX - 1) * marginX;

  static double computeHeight(double radius) {
    return heightRatioOfRadius() * radius * 2;
  }

  Offset computeCenter(int x, int y) {
    var centerX = computeX(x);
    var centerY = computeY(x, y);
    return Offset(centerX, centerY);
  }

  double computeY(int x, int y) {
    double centerY;
    if (x % 2 == 0) {
      centerY = y * height + y * marginY + height / 2;
    } else {
      centerY = y * height + (y + 0.5) * marginY + height;
    }
    double marginsVertical = computeEmptySpaceY() / 2;
    return centerY + marginsVertical;
  }

  double computeEmptySpaceY() {
    return screenHeight - ((nrY - 1) * height + 1.5 * height + totalMarginY());
  }

  double computeX(int x) {
    double marginsHorizontal = computeEmptySpaceX() / 2;
    return x * marginX + x * 1.5 * radius + radius + marginsHorizontal;
  }

  double computeEmptySpaceX() {
    return screenWidth -
        (totalMarginX() + (nrX - 1) * 1.5 * radius + 2 * radius);
  }
}

class HexagonModel {
  final Offset center;
  final double radius;
  final StepTypeModel? stepType;
  final GlobalKey key = GlobalKey();
  bool isSelected = false;

  HexagonModel({
    required this.center,
    required this.radius,
    this.stepType,
  });
}

class HexagonPaint extends StatefulWidget {
  final HexagonModel model;
  final GlobalKey<_HexagonPaintState> key = GlobalKey<_HexagonPaintState>();
  final StepTypeModel? stepType;

  HexagonPaint(this.model) : stepType = model.stepType, super(key: model.key);

  bool determineClick(PointerEvent details) {
    final RenderBox? hexagonBox =
        model.key.currentContext?.findRenderObject() as RenderBox?;
    if (hexagonBox == null) return false;
    
    final result = BoxHitTestResult();
    Offset localClick = hexagonBox.globalToLocal(details.position);
    return hexagonBox.hitTest(result, position: localClick);
  }

  @override
  _HexagonPaintState createState() => _HexagonPaintState();
}

class _HexagonPaintState extends State<HexagonPaint> {
  void updateSelected() {
    setState(() {
      widget.model.isSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HexagonPainter(
        center: widget.model.center,
        radius: widget.model.radius,
        isSelected: widget.model.isSelected,
        stepType: widget.stepType,
      ),
      child: Container(),
    );
  }
}

class HexagonPainter extends CustomPainter {
  static const int SIDES_OF_HEXAGON = 6;
  final double radius;
  final Offset center;
  final bool isSelected;
  final StepTypeModel? stepType;

  HexagonPainter({
    required this.center,
    required this.radius,
    required this.isSelected,
    this.stepType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected
          ? Colors.blue
          : (stepType != null
              ? Color(int.parse(stepType!.color.replaceAll('#', '0xFF')))
              : Colors.grey);

    final path = createHexagonPath();
    canvas.drawPath(path, paint);

    if (stepType != null) {
      // Draw step type icon
      final icon = StepTypeUtils.getIconForStepType(StepType.values
          .firstWhere((e) => e.toString().split('.').last == stepType!.name));
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: radius * 0.8,
            fontFamily: icon.fontFamily,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  Path createHexagonPath() {
    final path = Path();
    var angle = (math.pi * 2) / SIDES_OF_HEXAGON;
    Offset firstPoint = Offset(radius * math.cos(0.0), radius * math.sin(0.0));
    path.moveTo(firstPoint.dx + center.dx, firstPoint.dy + center.dy);
    for (int i = 1; i <= SIDES_OF_HEXAGON; i++) {
      double x = radius * math.cos(angle * i) + center.dx;
      double y = radius * math.sin(angle * i) + center.dy;
      path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(HexagonPainter oldDelegate) =>
      oldDelegate.isSelected != isSelected;

  @override
  bool hitTest(Offset position) {
    final Path path = createHexagonPath();
    return path.contains(position);
  }
}
