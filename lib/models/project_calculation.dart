import '../services/calculation_result.dart';

class ProjectCalculation {
  final List<RoofingCalculation> sectionCalculations;
  final int sheets;
  final int rafters;
  final double ridgeBoardLength;
  final int wallPlatesNeeded;
  final int battensNeeded;
  final double roofArea;
  final int fasteners;
  final Map<String, double> categoryTotals;

  const ProjectCalculation({
    required this.sectionCalculations,
    required this.sheets,
    required this.rafters,
    required this.ridgeBoardLength,
    required this.wallPlatesNeeded,
    required this.battensNeeded,
    required this.roofArea,
    required this.fasteners,
    required this.categoryTotals,
  });

  double get subtotal => categoryTotals.entries
      .where((entry) => entry.key != 'Profit' && entry.key != 'Total')
      .fold(0, (sum, entry) => sum + entry.value);

  double get total => categoryTotals['Total'] ?? subtotal;

  RoofingCalculation get combinedMaterials {
    final averageRafterLength = sectionCalculations.isEmpty
        ? 0.0
        : sectionCalculations.fold<double>(
              0,
              (sum, calculation) => sum + calculation.rasterLength,
            ) /
            sectionCalculations.length;

    return RoofingCalculation(
      sheets: sheets,
      rafters: rafters,
      ridgeBoardLength: ridgeBoardLength,
      wallPlatesNeeded: wallPlatesNeeded,
      battensNeeded: battensNeeded,
      rasterLength: averageRafterLength,
      roofArea: roofArea,
      accessories: fasteners,
    );
  }
}
