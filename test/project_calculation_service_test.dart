import 'package:flutter_test/flutter_test.dart';
import 'package:roof_estimator/models/calculator_mode.dart';
import 'package:roof_estimator/models/material_model.dart';
import 'package:roof_estimator/models/project_model.dart';
import 'package:roof_estimator/models/roof_section_model.dart';
import 'package:roof_estimator/services/project_calculation_service.dart';

void main() {
  group('ProjectCalculationService', () {
    test('combines quantities across multiple roof sections', () {
      final project = _project(
        sections: const [
          RoofSectionModel(
            id: 'main',
            name: 'Main roof',
            roofType: 'gable',
            length: 10,
            span: 7,
            pitch: 25,
            overhang: 0.3,
            rafterSpacing: 0.9,
            battenSpacing: 0.3,
          ),
          RoofSectionModel(
            id: 'porch',
            name: 'Porch',
            roofType: 'mono-pitch',
            length: 5,
            span: 4,
            pitch: 20,
            overhang: 0.2,
            rafterSpacing: 0.9,
            battenSpacing: 0.4,
            purlinSpacing: 0.4,
          ),
        ],
      );

      final result = ProjectCalculationService.calculateProject(
        project: project,
        materials: const [],
      );
      final sectionTotals = project.roofSections
          .map(ProjectCalculationService.calculateSection)
          .toList();

      expect(result.sectionCalculations, hasLength(2));
      expect(
        result.sheets,
        sectionTotals.fold<int>(0, (sum, section) => sum + section.sheets),
      );
      expect(
        result.rafters,
        sectionTotals.fold<int>(0, (sum, section) => sum + section.rafters),
      );
      expect(
        result.roofArea,
        closeTo(
          sectionTotals.fold<double>(
            0,
            (sum, section) => sum + section.roofArea,
          ),
          0.001,
        ),
      );
    });

    test('calculates price categories with waste, labour, transport and profit',
        () {
      final project = _project(
        labourCost: 1000,
        transportCost: 500,
        profitMargin: 0.1,
        sections: const [
          RoofSectionModel(
            id: 'main',
            name: 'Main roof',
            roofType: 'gable',
            length: 10,
            span: 7,
            pitch: 25,
            overhang: 0.3,
            rafterSpacing: 0.9,
            battenSpacing: 0.3,
          ),
        ],
      );

      final result = ProjectCalculationService.calculateProject(
        project: project,
        materials: const [
          MaterialModel(
            id: 'sheet',
            name: 'Longspan sheet',
            category: 'Roof covering',
            unit: 'per sheet',
            unitPrice: 100,
            wastePercentage: 0.1,
          ),
          MaterialModel(
            id: 'screw',
            name: 'Roofing screw',
            category: 'Accessories',
            unit: 'per pack',
            unitPrice: 50,
            wastePercentage: 0,
          ),
        ],
      );

      final roofCovering = result.sheets * 100;
      final waste = roofCovering * 0.1;
      final screwPacks = (result.fasteners / 100).ceil();
      final accessories = screwPacks * 50;
      final subtotal = roofCovering + waste + accessories + 1000 + 500;
      final profit = subtotal * 0.1;

      expect(result.categoryTotals['Roof covering'], roofCovering);
      expect(result.categoryTotals['Waste'], waste);
      expect(result.categoryTotals['Accessories'], accessories);
      expect(result.categoryTotals['Labour'], 1000);
      expect(result.categoryTotals['Transport'], 500);
      expect(result.categoryTotals['Profit'], closeTo(profit, 0.001));
      expect(result.total, closeTo(subtotal + profit, 0.001));
    });
  });
}

ProjectModel _project({
  required List<RoofSectionModel> sections,
  double labourCost = 0,
  double transportCost = 0,
  double profitMargin = 0,
}) {
  return ProjectModel(
    id: 'project-1',
    name: 'Test project',
    roofType: 'gable',
    mode: CalculatorMode.professional,
    labourCost: labourCost,
    transportCost: transportCost,
    profitMargin: profitMargin,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    roofSections: sections,
  );
}
