import 'roofing_constants.dart';

class TimberCalculation {
  final int rafters;
  final int battens;
  final int wallPlates;
  final double ridgeBoardLength;

  const TimberCalculation({
    required this.rafters,
    required this.battens,
    required this.wallPlates,
    required this.ridgeBoardLength,
  });
}

class TimberCalculator {
  const TimberCalculator();

  TimberCalculation calculate({
    required String roofType,
    required double length,
    required double span,
    required double rafterLength,
    required double rafterSpacing,
    required double purlinSpacing,
  }) {
    final raftersPerSide = (length / rafterSpacing).ceil();
    final totalRafters =
        roofType == 'mono-pitch' ? raftersPerSide : raftersPerSide * 2;

    final perimeter = 2 * (length + span);
    final wallPlates = (perimeter / RoofingConstants.wallPlateLength).ceil();

    final purlinsPerRafter = (rafterLength / purlinSpacing).ceil();
    final totalPurlinRun = purlinsPerRafter * totalRafters * purlinSpacing;
    final battens = (totalPurlinRun / RoofingConstants.battenLength).ceil();

    return TimberCalculation(
      rafters: totalRafters,
      battens: battens,
      wallPlates: wallPlates,
      ridgeBoardLength: roofType == 'mono-pitch' ? 0 : length,
    );
  }
}
