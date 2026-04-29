import '../models/material_model.dart';
import '../models/project_calculation.dart';
import '../models/project_model.dart';
import '../models/roof_section_model.dart';
import 'accessories_calculator.dart';
import 'calculation_result.dart';
import 'cost_calculator.dart';
import 'roof_material_calculator.dart';

class ProjectCalculationService {
  static const _sectionCalculator = RoofMaterialCalculator();
  static const _accessoriesCalculator = AccessoriesCalculator();
  static const _costCalculator = CostCalculator();

  static ProjectCalculation calculateProject({
    required ProjectModel project,
    required List<MaterialModel> materials,
  }) {
    final sectionCalculations =
        project.roofSections.map(calculateSection).toList();
    final sheets = sectionCalculations.fold<int>(
      0,
      (sum, calculation) => sum + calculation.sheets,
    );
    final rafters = sectionCalculations.fold<int>(
      0,
      (sum, calculation) => sum + calculation.rafters,
    );
    final ridgeBoardLength = sectionCalculations.fold<double>(
      0,
      (sum, calculation) => sum + calculation.ridgeBoardLength,
    );
    final wallPlatesNeeded = sectionCalculations.fold<int>(
      0,
      (sum, calculation) => sum + calculation.wallPlatesNeeded,
    );
    final battensNeeded = sectionCalculations.fold<int>(
      0,
      (sum, calculation) => sum + calculation.battensNeeded,
    );
    final roofArea = sectionCalculations.fold<double>(
      0,
      (sum, calculation) => sum + calculation.roofArea,
    );
    final fasteners = sectionCalculations.fold<int>(
        0, (sum, calculation) => sum + calculation.fasteners);

    final withoutCosts = ProjectCalculation(
      sectionCalculations: sectionCalculations,
      sheets: sheets,
      rafters: rafters,
      ridgeBoardLength: ridgeBoardLength,
      wallPlatesNeeded: wallPlatesNeeded,
      battensNeeded: battensNeeded,
      roofArea: roofArea,
      fasteners: fasteners,
      categoryTotals: const {},
    );

    final fallbackSheetPrice = project.roofSections.fold<double>(
      0,
      (sum, section) => sum + section.pricePerSheet,
    );
    final averageFallbackSheetPrice = project.roofSections.isEmpty
        ? 0.0
        : fallbackSheetPrice / project.roofSections.length;

    final categoryTotals = _costCalculator.calculateCategoryTotals(
      quantities: withoutCosts,
      materials: materials,
      labourCost: project.labourCost,
      transportCost: project.transportCost,
      profitMargin: project.profitMargin,
      fallbackSheetPrice: averageFallbackSheetPrice,
    );

    return ProjectCalculation(
      sectionCalculations: sectionCalculations,
      sheets: sheets,
      rafters: rafters,
      ridgeBoardLength: ridgeBoardLength,
      wallPlatesNeeded: wallPlatesNeeded,
      battensNeeded: battensNeeded,
      roofArea: roofArea,
      fasteners: fasteners,
      categoryTotals: categoryTotals,
    );
  }

  static RoofingCalculation calculateSection(RoofSectionModel section) {
    final result = _sectionCalculator.calculate(
      roofType: section.roofType,
      length: section.length,
      span: section.span,
      pitch: section.pitch,
      overhang: section.overhang,
      rafterSpacing: section.rafterSpacing,
      battenSpacing: section.battenSpacing,
      purlinSpacing: section.purlinSpacing,
      lapAllowance: section.lapAllowance,
      sheetCoverWidth: section.sheetEffectiveWidth,
      wastePercentage: section.wastePercentage,
    );

    final accessories = result.fasteners +
        _accessoriesCalculator.ridgeCapsForLength(result.ridgeBoardLength);

    return result.copyWith(accessories: accessories);
  }
}
