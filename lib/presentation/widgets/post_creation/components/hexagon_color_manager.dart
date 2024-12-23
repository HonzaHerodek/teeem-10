import 'package:flutter/material.dart';
import '../../../widgets/common/hexagon_central_tiles.dart';
import 'hexagon_step_input.dart';
import 'hexagon_grid_page.dart';

class HexagonColorManager {
  static const Color defaultColor = Colors.grey;

  static Shader getHexagonShader(Path path, Color hexagonColor, bool isSearchIcon) {
    if (isSearchIcon) {
      return RadialGradient(
        center: Alignment.topLeft,
        radius: 1.5,
        colors: [Colors.grey[300]!, Colors.grey[600]!],
      ).createShader(path.getBounds());
    }

    if (hexagonColor == Colors.grey) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(220, 220, 220, 0.65),
          Color.fromRGBO(180, 180, 180, 0.65),
        ],
      ).createShader(path.getBounds());
    }

    if (hexagonColor == Colors.grey[300]) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(180, 180, 180, 0.4),
          Color.fromRGBO(100, 100, 100, 0.4),
        ],
      ).createShader(path.getBounds());
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [hexagonColor, hexagonColor],
    ).createShader(path.getBounds());
  }

  static Color getColorForHexagon(int index, Map<int, StepInfo> hexagonSteps, int nrX) {
    final row = index ~/ nrX;
    final col = index % nrX;
    const centerRow = 4;
    const centerCol = 4;
    const numberOfCentralHexagons = 3;

    if (row == centerRow && col == centerCol) {
      return Colors.grey;
    }

    if (HexagonCentralTiles.isCentralHexagon(row, col, nrX, nrX, numberOfCentralHexagons)) {
      if (hexagonSteps.containsKey(index)) {
        return hexagonSteps[index]!.color;
      }
      return Colors.grey[300]!;
    }

    return Colors.grey;
  }
}
