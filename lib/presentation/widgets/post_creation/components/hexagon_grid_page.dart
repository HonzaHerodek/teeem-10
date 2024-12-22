import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'hexagon_step_input.dart';
import '../../../../domain/repositories/step_type_repository.dart';

class HexagonGridPage extends StatefulWidget {
  final VoidCallback onHexagonClicked;
  final StepTypeRepository stepTypeRepository;

  const HexagonGridPage({
    Key? key,
    required this.onHexagonClicked,
    required this.stepTypeRepository,
  }) : super(key: key);

  @override
  State<HexagonGridPage> createState() => _HexagonGridPageState();
}

class _HexagonGridPageState extends State<HexagonGridPage> {
  late final HexagonStepInput stepInput;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    stepInput = HexagonStepInput(widget.stepTypeRepository);
    _initializeStepInput();
  }

  Future<void> _initializeStepInput() async {
    try {
      await stepInput.initialize();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: isLoading 
        ? Center(child: CircularProgressIndicator())
        : LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: Colors.transparent,
                child: HexagonGrid(
                  onHexagonClicked: widget.onHexagonClicked,
                  stepInput: stepInput,
                ),
              );
            },
          ),
    );
  }
}

class HexagonGrid extends StatefulWidget {
  final VoidCallback onHexagonClicked;
  final HexagonStepInput stepInput;

  const HexagonGrid({
    Key? key,
    required this.onHexagonClicked,
    required this.stepInput,
  }) : super(key: key);

  @override
  State<HexagonGrid> createState() => _HexagonGridState();
}

class _HexagonGridState extends State<HexagonGrid> {
  final GridInitializer gridInitializer = GridInitializer();
  final List<HexagonPaint> hexagons = [];
  bool _initialized = false;

  void _initializeGrid(final double screenWidth, final double screenHeight) {
    if (!_initialized) {
      hexagons.clear();
      hexagons.addAll(gridInitializer.getHexagons(
        screenWidth,
        screenHeight,
        widget.onHexagonClicked,
        widget.stepInput,
      ));
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(HexagonGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepInput != widget.stepInput) {
      _initialized = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initializeGrid(constraints.maxWidth, constraints.maxHeight);
        return Stack(children: hexagons);
      },
    );
  }
}

class GridInitializer {
  static const int marginY = 5;
  static const int marginX = 5;
  static const int nrX = 9;
  static const int nrY = 9;
  double radius = 0;
  double height = 0;
  double screenWidth = 0;
  double screenHeight = 0;

  List<HexagonPaint> getHexagons(
    final double screenWidth,
    final double screenHeight,
    VoidCallback onHexagonClicked,
    HexagonStepInput stepInput,
  ) {
    var hexagons = <HexagonPaint>[];
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    radius = computeRadius(screenWidth, screenHeight);
    height = computeHeight(radius);

    for (int y = 0; y < nrY; y++) {
      for (int x = 0; x < nrX; x++) {
        final index = y * nrX + x;
        final isCenter = y == 4 && x == 4; // Center hexagon at (4,4)
        hexagons.add(HexagonPaint(
          model: HexagonModel(computeCenter(x, y), radius),
          onClicked: onHexagonClicked,
          color: stepInput.getColorForHexagon(index),
          showSearchIcon: isCenter,
        ));
      }
    }
    return hexagons;
  }

  static double computeRadius(double screenWidth, double screenHeight) {
    var maxWidth = (screenWidth - totalMarginX()) / (((nrX - 1) * 1.5) + 2);
    var maxHeight = 0.5 *
        (screenHeight - totalMarginY()) /
        (heightRatioOfRadius() * (nrY + 0.5));
    return math.min(maxWidth, maxHeight);
  }

  static double heightRatioOfRadius() =>
      math.cos(math.pi / StepTypeHexagonPainter.SIDES_OF_HEXAGON);

  static double totalMarginY() => (nrY - 0.5) * marginY;

  static int totalMarginX() => (nrX - 1) * marginX;

  static double computeHeight(double radius) {
    return heightRatioOfRadius() * radius * 2;
  }

  Offset computeCenter(int x, int y) {
    var centerX = computeX(x, y);
    var centerY = computeY(x, y);
    return Offset(centerX, centerY);
  }

  double computeX(int x, int y) {
    double centerX;
    if (y % 2 == 0) {
      centerX = x * height + x * marginX + height / 2;
    } else {
      centerX = x * height + (x + 0.5) * marginX + height;
    }
    double marginsHorizontal = computeEmptySpaceX() / 2;
    return centerX + marginsHorizontal;
  }

  double computeY(int x, int y) {
    double marginsVertical = computeEmptySpaceY() / 2;
    return y * marginY + y * 1.5 * radius + radius + marginsVertical;
  }

  double computeEmptySpaceX() {
    return screenWidth - ((nrX - 1) * height + 1.5 * height + totalMarginX());
  }

  double computeEmptySpaceY() {
    return screenHeight -
        (totalMarginY() + (nrY - 1) * 1.5 * radius + 2 * radius);
  }
}

class HexagonModel {
  final Offset center;
  final double radius;
  final GlobalKey key = GlobalKey();
  bool clicked = false;
  HexagonModel(this.center, this.radius);
}

class HexagonPaint extends StatefulWidget {
  final HexagonModel model;
  final VoidCallback onClicked;
  final Color color;
  final bool showSearchIcon;
  final GlobalKey<_HexagonPaintState> key = GlobalKey<_HexagonPaintState>();

  HexagonPaint({
    required this.model,
    required this.onClicked,
    required this.color,
    this.showSearchIcon = false,
  }) : super(key: model.key);

  @override
  _HexagonPaintState createState() => _HexagonPaintState();
}

class _HexagonPaintState extends State<HexagonPaint> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.model.center.dx - widget.model.radius,
      top: widget.model.center.dy - widget.model.radius,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() {
              widget.model.clicked = true;
            });
            widget.onClicked();
          },
          child: Container(
            width: widget.model.radius * 2,
            height: widget.model.radius * 2,
            color: Colors.transparent,
            child: CustomPaint(
              painter: StepTypeHexagonPainter(
                center: Offset(widget.model.radius, widget.model.radius),
                radius: widget.model.radius,
                clicked: widget.model.clicked,
                hexagonColor: widget.color,
                showSearchIcon: widget.showSearchIcon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StepTypeHexagonPainter extends CustomPainter {
  static const int SIDES_OF_HEXAGON = 6;
  final Offset center;
  final double radius;
  final bool clicked;
  final Color hexagonColor;
  final bool showSearchIcon;

  StepTypeHexagonPainter({
    required this.center,
    required this.radius,
    required this.clicked,
    required this.hexagonColor,
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
      oldDelegate.showSearchIcon != showSearchIcon;
}
