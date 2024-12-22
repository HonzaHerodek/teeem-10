/// Utility class for finding and managing central tiles in a pointy-top hexagon grid
class HexagonCentralTiles {
  /// Returns whether the given grid position represents one of the central hexagons
  static bool isCentralHexagon(int row, int col, int totalRows, int totalCols, int n) {
    // Center hexagon at (4,4) in 9x9 grid
    final centerRow = 4;
    final centerCol = 4;

    // Calculate distance from center (in hex grid steps)
    int rowDiff = (row - centerRow).abs();
    int colDiff = (col - centerCol).abs();
    
    // Adjust for hex grid offset
    if (row % 2 != centerRow % 2) {
      // For odd rows when center is even, or even rows when center is odd
      colDiff = ((col * 2 + 1) - (centerCol * 2)).abs() ~/ 2;
    }

    // Calculate hex distance (considering hex grid geometry)
    int hexDistance = (rowDiff + colDiff + (rowDiff - colDiff).abs()) ~/ 2;

    // Return true for:
    // - Center hexagon (distance 0)
    // - First ring (distance 1)
    // - Second ring (distance 2)
    return hexDistance <= 2;
  }
}
