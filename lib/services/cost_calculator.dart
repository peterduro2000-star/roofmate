import '../models/material_model.dart';
import '../models/project_calculation.dart';

class CostCalculator {
  const CostCalculator();

  Map<String, double> calculateCategoryTotals({
    required ProjectCalculation quantities,
    required List<MaterialModel> materials,
    required double labourCost,
    required double transportCost,
    required double profitMargin,
    double fallbackSheetPrice = 0,
  }) {
    final totals = <String, double>{
      'Roof covering': 0,
      'Timber/steel frame': 0,
      'Accessories': 0,
      'Labour': labourCost,
      'Transport': transportCost,
      'Waste': 0,
      'Profit': 0,
      'Total': 0,
    };

    for (final material in materials) {
      final quantity = _quantityFor(material, quantities);
      final wasteQuantity = quantity * material.wastePercentage;
      final baseCost = quantity * material.unitPrice;
      final wasteCost = wasteQuantity * material.unitPrice;

      totals[material.category] = (totals[material.category] ?? 0) + baseCost;
      totals['Waste'] = (totals['Waste'] ?? 0) + wasteCost;
    }

    if ((totals['Roof covering'] ?? 0) == 0 && fallbackSheetPrice > 0) {
      totals['Roof covering'] = quantities.sheets * fallbackSheetPrice;
    }

    final subtotal = totals.entries
        .where((entry) => entry.key != 'Profit' && entry.key != 'Total')
        .fold<double>(0, (sum, entry) => sum + entry.value);
    final profit = subtotal * profitMargin;

    totals['Profit'] = profit;
    totals['Total'] = subtotal + profit;

    return totals;
  }

  double _quantityFor(MaterialModel material, ProjectCalculation quantities) {
    final name = material.name.toLowerCase();

    if (name.contains('sheet') || name.contains('longspan')) {
      return quantities.sheets.toDouble();
    }
    if (name.contains('ridge')) return quantities.ridgeBoardLength;
    if (name.contains('2x3') || name.contains('batten')) {
      return quantities.battensNeeded.toDouble();
    }
    if (name.contains('2x4') || name.contains('rafter')) {
      return quantities.rafters.toDouble();
    }
    if (name.contains('wall plate')) {
      return quantities.wallPlatesNeeded.toDouble();
    }
    if (name.contains('screw')) {
      return (quantities.fasteners / 100).ceilToDouble();
    }
    if (name.contains('fascia')) return quantities.ridgeBoardLength;

    return 0;
  }
}
