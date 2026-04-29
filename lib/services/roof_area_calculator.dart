import 'dart:math';

class RoofAreaCalculator {
  const RoofAreaCalculator();

  double rafterLength({
    required double span,
    required double pitch,
    required double overhang,
  }) {
    final run = span / 2;
    final pitchRad = (pitch * pi) / 180;
    return run / cos(pitchRad) + overhang;
  }

  double roofArea({
    required String roofType,
    required double length,
    required double span,
    required double pitch,
    required double overhang,
    double lapAllowance = 0,
  }) {
    final slopeLength = rafterLength(
      span: span,
      pitch: pitch,
      overhang: overhang,
    );
    final effectiveLength = length + lapAllowance;
    final sides = roofType == 'mono-pitch' ? 1 : 2;
    final baseArea = effectiveLength * slopeLength * sides;

    return roofType == 'hip' ? baseArea * 1.08 : baseArea;
  }
}
