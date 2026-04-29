import 'package:flutter_test/flutter_test.dart';
import 'package:roof_estimator/models/calculator_mode.dart';
import 'package:roof_estimator/models/company_profile_model.dart';
import 'package:roof_estimator/models/material_model.dart';
import 'package:roof_estimator/models/project_model.dart';
import 'package:roof_estimator/models/roof_section_model.dart';
import 'package:roof_estimator/services/project_calculation_service.dart';
import 'package:roof_estimator/services/quotation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuotationService', () {
    test('builds quotation, BOQ CSV, and share text for a project', () {
      final project = _project();
      final calculation = ProjectCalculationService.calculateProject(
        project: project,
        materials: const [],
      );

      final quotation = const QuotationService().build(
        project: project,
        calculation: calculation,
      );

      expect(quotation.title, contains('Duplex Roof'));
      expect(quotation.quotationText, contains('ROOFING QUOTATION'));
      expect(quotation.quotationText, contains('Client A'));
      expect(quotation.quotationText, contains('Main roof'));
      expect(
          quotation.boqCsv, startsWith('Category,Item,Quantity,Unit,Amount'));
      expect(quotation.boqCsv, contains('Roof covering,Roof sheets'));
      expect(quotation.shareText, contains('Estimated total'));
    });

    test('builds valid PDF bytes for preview and local save flow', () async {
      final project = _project();
      const materials = [
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
      ];
      final calculation = ProjectCalculationService.calculateProject(
        project: project,
        materials: materials,
      );

      final bytes = await const QuotationService().buildPdfBytes(
        project: project,
        calculation: calculation,
        materials: materials,
        companyProfile: const CompanyProfileModel(
          companyName: 'Test Roofing Ltd',
          phoneNumber: '08012345678',
          email: 'info@testroofing.test',
          address: 'Lagos',
        ),
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}

ProjectModel _project() {
  return ProjectModel(
    id: 'quote-1',
    clientName: 'Client A',
    siteAddress: 'Site A',
    name: 'Duplex Roof',
    roofType: 'gable',
    mode: CalculatorMode.professional,
    labourCost: 1000,
    transportCost: 500,
    profitMargin: 0.1,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 2),
    roofSections: const [
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
}
