import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';

class HexagonGridPage extends StatelessWidget {
  final grid = HexagonGrid();
  final VoidCallback onHexagonClicked;

  HexagonGridPage({
    Key? key,
    required this.onHexagonClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: LayoutBuilder(builder: (context, constraints) {
        grid.initialize(constraints.maxWidth, constraints.maxHeight, onHexagonClicked);
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Colors.transparent,
          child: grid,
        );
      }),
    );
  }
}

class HexagonGrid extends StatelessWidget {
  final GridInitializer gridInitializer = GridInitializer();
  final List<HexagonPaint> hexagons = [];

  void initialize(final double screenWidth, final double screenHeight, VoidCallback onHexagonClicked) {
    if (hexagons.isEmpty) {
      hexagons.addAll(gridInitializer.getHexagons(screenWidth, screenHeight, onHexagonClicked));
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
  static const int nrX = 9;
  static const int nrY = 6;
  double radius = 0;
  double height = 0;
  double screenWidth = 0;
  double screenHeight = 0;

  List<HexagonPaint> getHexagons(
      final double screenWidth, final double screenHeight, VoidCallback onHexagonClicked) {
    var hexagons = <HexagonPaint>[];
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    radius = computeRadius(screenWidth, screenHeight);
    height = computeHeight(radius);

    for (int y = 0; y < nrY; y++) {
      for (int x = 0; x < nrX; x++) {
        hexagons.add(HexagonPaint(
          model: HexagonModel(computeCenter(x, y), radius),
          onClicked: onHexagonClicked,
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
      math.cos(math.pi / HexagonPainter.SIDES_OF_HEXAGON);

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
  final GlobalKey<_HexagonPaintState> key = GlobalKey<_HexagonPaintState>();

  HexagonPaint({
    required this.model,
    required this.onClicked,
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
              painter: HexagonPainter(
                Offset(widget.model.radius, widget.model.radius),
                widget.model.radius,
                widget.model.clicked,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  static const int SIDES_OF_HEXAGON = 6;
  final double radius;
  final Offset center;
  final bool clicked;

  HexagonPainter(this.center, this.radius, this.clicked);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = clicked ? Colors.pink : Colors.blue;
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
  bool shouldRepaint(HexagonPainter oldDelegate) =>
      oldDelegate.clicked != clicked;
}
