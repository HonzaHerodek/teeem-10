import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Defines the layout style for the honeycomb grid
enum HoneycombLayout {
  /// Items arranged in a horizontal line with optional curvature
  horizontalLine,

  /// Items arranged in a vertical line with optional curvature
  verticalLine,

  /// Items arranged in a honeycomb pattern filling an area
  area
}

/// Configuration for the honeycomb grid layout
class HoneycombConfig {
  /// The type of layout to use
  final HoneycombLayout layout;

  /// Curvature amount for line layouts (0.0 to 1.0)
  /// 0.0 = straight line, 1.0 = maximum curve
  final double curvature;

  /// Maximum width for area layout (items will wrap within this width)
  final double? maxWidth;

  /// Maximum number of items per row for area layout
  final int? maxItemsPerRow;

  const HoneycombConfig({
    required this.layout,
    this.curvature = 0.0,
    this.maxWidth,
    this.maxItemsPerRow,
  })  : assert(curvature >= 0.0 && curvature <= 1.0),
        assert(layout != HoneycombLayout.area || maxWidth != null,
            'maxWidth is required for area layout');

  /// Preset for horizontal line with no curve
  static const horizontal = HoneycombConfig(
    layout: HoneycombLayout.horizontalLine,
    curvature: 0.0,
  );

  /// Preset for vertical line with no curve
  static const vertical = HoneycombConfig(
    layout: HoneycombLayout.verticalLine,
    curvature: 0.0,
  );

  /// Creates an area layout configuration
  static HoneycombConfig area({
    required double maxWidth,
    int maxItemsPerRow = 3,
  }) =>
      HoneycombConfig(
        layout: HoneycombLayout.area,
        maxWidth: maxWidth,
        maxItemsPerRow: maxItemsPerRow,
      );
}

class HoneycombGrid extends StatelessWidget {
  final List<Widget> children;
  final double cellSize;
  final double spacing;
  final HoneycombConfig config;

  const HoneycombGrid({
    Key? key,
    required this.children,
    required this.cellSize,
    required this.config,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox();

    switch (config.layout) {
      case HoneycombLayout.horizontalLine:
        return _buildHorizontalLine();
      case HoneycombLayout.verticalLine:
        return _buildVerticalLine();
      case HoneycombLayout.area:
        return _buildArea();
    }
  }

  Widget _buildHorizontalLine() {
    final width = children.length * cellSize;
    final height = cellSize + (config.curvature * cellSize);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: List.generate(children.length, (index) {
          final x = index * cellSize;
          final y = config.curvature *
              cellSize *
              math.sin(index * math.pi / (children.length - 1));

          return Positioned(
            left: x,
            top: y,
            child: SizedBox(
              width: cellSize,
              height: cellSize,
              child: children[index],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVerticalLine() {
    final width = cellSize + (config.curvature * cellSize);
    final height = children.length * cellSize;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: List.generate(children.length, (index) {
          final y = index * cellSize;
          final x = config.curvature *
              cellSize *
              math.sin(index * math.pi / (children.length - 1));

          return Positioned(
            left: x,
            top: y,
            child: SizedBox(
              width: cellSize,
              height: cellSize,
              child: children[index],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildArea() {
    // Calculate hexagon dimensions
    final hexWidth = cellSize * math.sqrt(3);
    final hexHeight = cellSize * 2;

    // Calculate grid dimensions
    final itemsPerRow = math.min(config.maxItemsPerRow ?? 3, children.length);
    final rowCount = (children.length / itemsPerRow).ceil();

    // Calculate total size
    final totalWidth = itemsPerRow * hexWidth;
    final totalHeight = rowCount * hexHeight * 0.75;

    // Center the grid
    final xOffset = (config.maxWidth! - totalWidth) / 2;
    final yOffset = 0.0;

    return SizedBox(
      width: config.maxWidth,
      height: totalHeight,
      child: Stack(
        children: List.generate(children.length, (index) {
          final row = index ~/ itemsPerRow;
          final col = index % itemsPerRow;
          final isOddRow = row.isOdd;

          // Position hexagons directly adjacent
          double x = xOffset + (col * hexWidth);
          if (isOddRow) x += hexWidth / 2;

          final double y = yOffset + (row * hexHeight * 0.75);

          return Positioned(
            left: x,
            top: y,
            child: SizedBox(
              width: hexWidth,
              height: hexHeight,
              child: ClipPath(
                clipper: HexagonClipper(),
                child: children[index],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A clipper that creates a hexagonal shape
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;
    final radius = width / 2;

    // Calculate points for perfect hexagon
    final points = List.generate(6, (i) {
      final angle = (i * 60 - 30) * math.pi / 180;
      return Offset(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );
    });

    // Draw hexagon
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < 6; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
