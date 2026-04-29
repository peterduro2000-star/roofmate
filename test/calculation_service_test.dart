import 'package:flutter_test/flutter_test.dart';
import 'package:roof_estimator/services/calculation_service.dart';

void main() {
  group('Roofing Material Calculations', () {
    group('Gable Roof Calculations', () {
      test(
          'should calculate materials for a standard 10m × 7m gable roof at 25°',
          () {
        final result = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        expect(result.sheets, greaterThan(0));
        expect(result.rafters, greaterThan(0));
        expect(result.ridgeBoardLength, equals(10));
        expect(result.wallPlatesNeeded, greaterThan(0));
        expect(result.battensNeeded, greaterThan(0));
        expect(result.rasterLength, greaterThan(0));
      });

      test('should calculate correct rafter length using trigonometry', () {
        final result = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        // For 25° pitch, span 7m, overhang 0.3m
        // run = 3.5m, cos(25°) ≈ 0.906
        // rasterLength = 3.5 / 0.906 + 0.3 ≈ 4.16m
        expect(result.rasterLength, closeTo(4.16, 0.1));
      });

      test('should include waste allowance in sheet count', () {
        final resultWithWaste = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
          wastePercentage: 0.1,
        );

        final resultNoWaste = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
          wastePercentage: 0,
        );

        expect(resultWithWaste.sheets, greaterThan(resultNoWaste.sheets));
      });

      test('should calculate sheets per side correctly', () {
        final result = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        // 10m / 0.686m ≈ 14.58, rounded up = 15 sheets per side
        // With 10% waste: 30 * 1.1 = 33 sheets
        expect(result.sheets, equals(33));
      });

      test('should calculate correct number of rafters', () {
        final result = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        // 10m / 0.9m ≈ 11.11, rounded up = 12 rafters per side
        // For gable: 12 * 2 = 24 rafters
        expect(result.rafters, equals(24));
      });

      test('should calculate wall plates needed', () {
        final result = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        // Perimeter = 2 * (10 + 7) = 34m
        // 34 / 6 ≈ 5.67, rounded up = 6 pieces
        expect(result.wallPlatesNeeded, equals(6));
      });
    });

    group('Hip Roof Calculations', () {
      test('should calculate 20% more materials for hip roof', () {
        final gableResult = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        final hipResult = CalculationService.calculateRoofingMaterials(
          roofType: 'hip',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        expect(hipResult.sheets, greaterThan(gableResult.sheets));
      });
    });

    group('Mono-Pitch Roof Calculations', () {
      test('should calculate materials for mono-pitch roof', () {
        final result = CalculationService.calculateRoofingMaterials(
          roofType: 'mono-pitch',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        expect(result.sheets, greaterThan(0));
        expect(result.rafters, greaterThan(0));
      });

      test('should have fewer sheets than gable roof', () {
        final gableResult = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        final monoPitchResult = CalculationService.calculateRoofingMaterials(
          roofType: 'mono-pitch',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        expect(monoPitchResult.sheets, lessThan(gableResult.sheets));
      });
    });

    group('Edge Cases and Validation', () {
      test('should handle different pitch angles', () {
        final lowPitch = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 15,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        final highPitch = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 45,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        expect(highPitch.rasterLength, greaterThan(lowPitch.rasterLength));
      });

      test('should handle different rafter spacing', () {
        final tightSpacing = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.6,
          battenSpacing: 0.3,
        );

        final wideSpacing = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        expect(tightSpacing.rafters, greaterThan(wideSpacing.rafters));
      });

      test('should handle different overhang lengths', () {
        final smallOverhang = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.2,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        final largeOverhang = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.5,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        expect(largeOverhang.rasterLength,
            greaterThan(smallOverhang.rasterLength));
      });

      test('should handle different sheet cover widths', () {
        final ibrSheets = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
          sheetCoverWidth: 0.686,
        );

        final corrugatedSheets = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
          sheetCoverWidth: 0.762,
        );

        expect(corrugatedSheets.sheets, lessThan(ibrSheets.sheets));
      });
    });

    group('Real-World Examples', () {
      test('should match manual calculation for example house', () {
        final result = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 10,
          span: 7,
          pitch: 25,
          overhang: 0.3,
          rasterSpacing: 0.9,
          battenSpacing: 0.3,
        );

        expect(result.sheets, equals(33));
        expect(result.rafters, equals(24));
        expect(result.ridgeBoardLength, equals(10));
        expect(result.wallPlatesNeeded, equals(6));
      });

      test('should handle large commercial building', () {
        final result = CalculationService.calculateRoofingMaterials(
          roofType: 'gable',
          length: 30,
          span: 20,
          pitch: 30,
          overhang: 0.4,
          rasterSpacing: 0.6,
          battenSpacing: 0.3,
        );

        expect(result.sheets, greaterThan(80));
        expect(result.rafters, greaterThan(50));
        expect(result.battensNeeded, greaterThan(80));
      });

      test('should handle small residential structure', () {
        final result = CalculationService.calculateRoofingMaterials(
          roofType: 'mono-pitch',
          length: 5,
          span: 4,
          pitch: 20,
          overhang: 0.2,
          rasterSpacing: 0.9,
          battenSpacing: 0.4,
        );

        expect(result.sheets, greaterThan(0));
        expect(result.rafters, greaterThan(0));
        expect(result.battensNeeded, greaterThan(0));
      });
    });
  });
}
