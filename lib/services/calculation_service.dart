export 'calculation_result.dart';

import 'calculation_result.dart';
import 'roof_material_calculator.dart';
import 'roofing_constants.dart';

class CalculationService {
  // ignore: constant_identifier_names
  static const double IBR_COVER_WIDTH = RoofingConstants.ibrCoverWidth;
  // ignore: constant_identifier_names
  static const double WASTE_PERCENTAGE =
      RoofingConstants.defaultWastePercentage;
  // ignore: constant_identifier_names
  static const double WALL_PLATE_LENGTH = RoofingConstants.wallPlateLength;
  // ignore: constant_identifier_names
  static const double BATTEN_LENGTH = RoofingConstants.battenLength;

  static const RoofMaterialCalculator _calculator = RoofMaterialCalculator();

  /// Calculate roofing materials based on dimensions and roof type
  static RoofingCalculation calculateRoofingMaterials({
    required String roofType,
    required double length,
    required double span,
    required double pitch,
    required double overhang,
    required double rasterSpacing,
    required double battenSpacing,
    double sheetCoverWidth = IBR_COVER_WIDTH,
    double wastePercentage = WASTE_PERCENTAGE,
  }) {
    return _calculator.calculate(
      roofType: roofType,
      length: length,
      span: span,
      pitch: pitch,
      overhang: overhang,
      rafterSpacing: rasterSpacing,
      battenSpacing: battenSpacing,
      sheetCoverWidth: sheetCoverWidth,
      wastePercentage: wastePercentage,
    );
  }
}
