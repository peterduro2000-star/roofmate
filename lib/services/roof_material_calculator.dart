import 'calculation_result.dart';
import 'accessories_calculator.dart';
import 'roof_area_calculator.dart';
import 'roofing_constants.dart';
import 'sheet_calculator.dart';
import 'timber_calculator.dart';

class RoofMaterialCalculator {
  const RoofMaterialCalculator();

  static const _areaCalculator = RoofAreaCalculator();
  static const _sheetCalculator = SheetCalculator();
  static const _timberCalculator = TimberCalculator();
  static const _accessoriesCalculator = AccessoriesCalculator();

  RoofingCalculation calculate({
    required String roofType,
    required double length,
    required double span,
    required double pitch,
    required double overhang,
    required double rafterSpacing,
    required double battenSpacing,
    double purlinSpacing = RoofingConstants.defaultPurlinSpacing,
    double lapAllowance = 0,
    double sheetCoverWidth = RoofingConstants.ibrCoverWidth,
    double wastePercentage = RoofingConstants.defaultWastePercentage,
  }) {
    final rafterLength = _areaCalculator.rafterLength(
      span: span,
      pitch: pitch,
      overhang: overhang,
    );
    final roofArea = _areaCalculator.roofArea(
      roofType: roofType,
      length: length,
      span: span,
      pitch: pitch,
      overhang: overhang,
      lapAllowance: lapAllowance,
    );
    final sheets = _sheetCalculator.sheetsForSection(
      roofType: roofType,
      length: length,
      sheetEffectiveWidth: sheetCoverWidth,
      wastePercentage: wastePercentage,
    );
    final timber = _timberCalculator.calculate(
      roofType: roofType,
      length: length,
      span: span,
      rafterLength: rafterLength,
      rafterSpacing: rafterSpacing,
      purlinSpacing: purlinSpacing == 0 ? battenSpacing : purlinSpacing,
    );

    return RoofingCalculation(
      sheets: sheets,
      rafters: timber.rafters,
      ridgeBoardLength: timber.ridgeBoardLength,
      wallPlatesNeeded: timber.wallPlates,
      battensNeeded: timber.battens,
      rasterLength: rafterLength,
      roofArea: roofArea,
      accessories: _accessoriesCalculator.fastenersForSheets(sheets),
    );
  }
}
