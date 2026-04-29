import 'package:flutter_test/flutter_test.dart';
import 'package:roof_estimator/models/calculator_mode.dart';
import 'package:roof_estimator/models/material_model.dart';
import 'package:roof_estimator/models/project_model.dart';
import 'package:roof_estimator/models/roof_section_model.dart';
import 'package:roof_estimator/services/project_calculation_service.dart';
import 'package:roof_estimator/services/roof_input_validator.dart';

void main() {
  group('Real-world roofing scenarios', () {
    test('simple gable bungalow produces practical material quantities', () {
      final project = _project(
        sections: const [
          RoofSectionModel(
            id: 'gable-bungalow',
            name: 'Main roof',
            roofType: 'gable',
            length: 12,
            span: 8,
            pitch: 25,
            overhang: 0.45,
            rafterSpacing: 0.9,
            battenSpacing: 0.3,
            purlinSpacing: 0.3,
          ),
        ],
      );

      final result = ProjectCalculationService.calculateProject(
        project: project,
        materials: const [],
      );

      expect(result.sheets, greaterThan(30));
      expect(result.rafters, greaterThan(20));
      expect(result.roofArea, greaterThan(90));
    });

    test('hip roof bungalow uses more sheets than matching gable roof', () {
      final gable = ProjectCalculationService.calculateSection(
        const RoofSectionModel(
          id: 'gable',
          name: 'Gable roof',
          roofType: 'gable',
          length: 12,
          span: 8,
          pitch: 25,
          overhang: 0.45,
          rafterSpacing: 0.9,
          battenSpacing: 0.3,
        ),
      );
      final hip = ProjectCalculationService.calculateSection(
        const RoofSectionModel(
          id: 'hip',
          name: 'Hip roof',
          roofType: 'hip',
          length: 12,
          span: 8,
          pitch: 25,
          overhang: 0.45,
          rafterSpacing: 0.9,
          battenSpacing: 0.3,
        ),
      );

      expect(hip.sheets, greaterThan(gable.sheets));
      expect(hip.roofArea, greaterThan(gable.roofArea));
    });

    test('multi-section L-shaped roof combines each section separately', () {
      final project = _project(
        sections: const [
          RoofSectionModel(
            id: 'main',
            name: 'Main roof',
            roofType: 'gable',
            length: 12,
            span: 8,
            pitch: 25,
            overhang: 0.45,
            rafterSpacing: 0.9,
            battenSpacing: 0.3,
          ),
          RoofSectionModel(
            id: 'wing',
            name: 'Kitchen wing',
            roofType: 'mono-pitch',
            length: 7,
            span: 4,
            pitch: 18,
            overhang: 0.3,
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

      expect(result.sectionCalculations, hasLength(2));
      expect(
          result.sheets, greaterThan(result.sectionCalculations.first.sheets));
      expect(result.roofArea,
          greaterThan(result.sectionCalculations.first.roofArea));
    });

    test('stone-coated roof can be priced with a narrower effective width', () {
      final project = _project(
        sections: const [
          RoofSectionModel(
            id: 'stone-coated',
            name: 'Stone-coated roof',
            roofType: 'gable',
            length: 10,
            span: 7,
            pitch: 30,
            overhang: 0.4,
            rafterSpacing: 0.9,
            battenSpacing: 0.3,
            sheetEffectiveWidth: 0.37,
            sheetType: 'Stone coated sheet',
          ),
        ],
      );

      final result = ProjectCalculationService.calculateProject(
        project: project,
        materials: const [
          MaterialModel(
            id: 'stone',
            name: 'Stone coated sheet',
            category: 'Roof covering',
            unit: 'per sheet',
            unitPrice: 4200,
            wastePercentage: 0.08,
          ),
        ],
      );

      expect(result.sheets, greaterThan(50));
      expect(result.categoryTotals['Roof covering'], greaterThan(0));
      expect(result.total, greaterThan(0));
    });
  });

  group('RoofInputValidator', () {
    test('rejects zero and negative dimensions', () {
      final message = RoofInputValidator.validateSection(
        const RoofSectionModel(
          id: 'bad',
          name: 'Bad section',
          roofType: 'gable',
          length: 0,
          span: -2,
          pitch: 25,
          overhang: 0.3,
          rafterSpacing: 0.9,
          battenSpacing: 0.3,
        ),
      );

      expect(message, contains('length'));
    });

    test('rejects unrealistic pitch and spacing values', () {
      final pitchMessage = RoofInputValidator.validateSection(
        const RoofSectionModel(
          id: 'bad-pitch',
          name: 'Bad pitch',
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 80,
          overhang: 0.3,
          rafterSpacing: 0.9,
          battenSpacing: 0.3,
        ),
      );
      final spacingMessage = RoofInputValidator.validateSection(
        const RoofSectionModel(
          id: 'bad-spacing',
          name: 'Bad spacing',
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rafterSpacing: 2,
          battenSpacing: 0.3,
          purlinSpacing: 0.3,
        ),
      );

      expect(pitchMessage, contains('pitch'));
      expect(spacingMessage, contains('Rafter spacing'));
    });
  });
}

ProjectModel _project({required List<RoofSectionModel> sections}) {
  return ProjectModel(
    id: 'scenario',
    name: 'Scenario project',
    roofType: 'gable',
    mode: CalculatorMode.professional,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    roofSections: sections,
  );
}
