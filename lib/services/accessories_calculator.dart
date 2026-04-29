class AccessoriesCalculator {
  const AccessoriesCalculator();

  int fastenersForSheets(int sheets) => sheets * 20;

  int ridgeCapsForLength(double ridgeBoardLength) {
    if (ridgeBoardLength <= 0) return 0;
    return (ridgeBoardLength / 3).ceil();
  }
}
