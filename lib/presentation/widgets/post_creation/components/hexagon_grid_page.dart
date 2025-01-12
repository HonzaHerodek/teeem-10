import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'hexagon_step_input.dart';
import 'step_type_hexagon_painter.dart';
import '../../../../domain/repositories/step_type_repository.dart';

class HexagonGridPage extends StatefulWidget {
  final VoidCallback onHexagonClicked;
  final HexagonStepInput stepInput;

  const HexagonGridPage({
    Key? key,
    required this.onHexagonClicked,
    required this.stepInput,
  }) : super(key: key);

  @override
  State<HexagonGridPage> createState() => HexagonGridPageState();
}

class HexagonGridPageState extends State<HexagonGridPage> {
  bool isLoading = false;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _centerOnSearchIcon(BuildContext context, BoxConstraints constraints) {
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;

    final matrix = Matrix4.identity()
      ..translate(
        centerX - (constraints.maxWidth * 2 / 2),
        centerY - (constraints.maxHeight * 2 / 2),
      );

    _transformationController.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _centerOnSearchIcon(context, constraints);
                });

                return InteractiveViewer(
                  transformationController: _transformationController,
                  constrained: false,
                  panEnabled: true,
                  scaleEnabled: false,
                  boundaryMargin: EdgeInsets.all(double.infinity),
                  child: Container(
                    width: constraints.maxWidth * 2,
                    height: constraints.maxHeight * 2,
                    color: Colors.transparent,
                    child: Center(
                      child: HexagonGrid(
                        onHexagonClicked: (index) {
                          widget.stepInput.setSelectedIndex(index);
                          widget.onHexagonClicked();
                        },
                        stepInput: widget.stepInput,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class HexagonGrid extends StatefulWidget {
  final void Function(int) onHexagonClicked;
  final HexagonStepInput stepInput;

  const HexagonGrid({
    Key? key,
    required this.onHexagonClicked,
    required this.stepInput,
  }) : super(key: key);

  @override
  State<HexagonGrid> createState() => HexagonGridState();
}

class HexagonGridState extends State<HexagonGrid> {
  final GridInitializer gridInitializer = GridInitializer();
  List<HexagonPaint> hexagons = [];
  Size? lastSize;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _centerOnSearchIcon(BuildContext context, BoxConstraints constraints) {
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;

    final matrix = Matrix4.identity()
      ..translate(
        centerX - (constraints.maxWidth * 2 / 2),
        centerY - (constraints.maxHeight * 2 / 2),
      );

    _transformationController.value = matrix;
  }

  void _initializeGrid(double screenWidth, double screenHeight) {
    final newSize = Size(screenWidth, screenHeight);
    if (lastSize != newSize || hexagons.isEmpty) {
      hexagons = gridInitializer.getHexagons(
        screenWidth,
        screenHeight,
        widget.onHexagonClicked,
        widget.stepInput,
      );
      lastSize = newSize;
    }
  }

  void refreshGrid() {
    if (lastSize != null) {
      setState(() {
        hexagons = gridInitializer.getHexagons(
          lastSize!.width,
          lastSize!.height,
          widget.onHexagonClicked,
          widget.stepInput,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _centerOnSearchIcon(context, constraints);
          });

          _initializeGrid(constraints.maxWidth, constraints.maxHeight);

          return InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            panEnabled: true,
            scaleEnabled: false,
            boundaryMargin: EdgeInsets.all(double.infinity),
            child: Container(
              width: constraints.maxWidth * 2,
              height: constraints.maxHeight * 2,
              color: Colors.transparent,
              child: Stack(children: hexagons),
            ),
          );
        },
      ),
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
    void Function(int) onHexagonClicked,
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
        final isCenter = y == 4 && x == 4;
        hexagons.add(HexagonPaint(
          model: HexagonModel(computeCenter(x, y), radius),
          onClicked: () => onHexagonClicked(index),
          color: stepInput.getColorForHexagon(index),
          showSearchIcon: isCenter,
          stepInfo: stepInput.getStepInfoForHexagon(index),
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
  final StepInfo? stepInfo;
  final GlobalKey<HexagonPaintState> key = GlobalKey<HexagonPaintState>();

  HexagonPaint({
    required this.model,
    required this.onClicked,
    required this.color,
    this.showSearchIcon = false,
    this.stepInfo,
  }) : super(key: model.key);

  @override
  HexagonPaintState createState() => HexagonPaintState();
}

class HexagonPaintState extends State<HexagonPaint> {
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
                stepInfo: widget.stepInfo,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
