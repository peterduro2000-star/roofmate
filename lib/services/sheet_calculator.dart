class SheetCalculator {
  const SheetCalculator();

  int sheetsForSection({
    required String roofType,
    required double length,
    required double sheetEffectiveWidth,
    required double wastePercentage,
  }) {
    final sheetsPerSide = (length / sheetEffectiveWidth).ceil();
    final totalSheets = switch (roofType) {
      'hip' => (sheetsPerSide * 2 * 1.2).ceil(),
      'mono-pitch' => sheetsPerSide,
      _ => sheetsPerSide * 2,
    };

    return (totalSheets * (1 + wastePercentage)).ceil();
  }
}
