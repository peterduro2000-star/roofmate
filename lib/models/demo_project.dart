import 'calculator_mode.dart';
import 'project_model.dart';
import 'roof_section_model.dart';

class DemoProject {
  const DemoProject._();

  static ProjectModel sample() {
    final now = DateTime.now();

    return ProjectModel(
      id: 'demo-project',
      clientName: 'Demo Client',
      siteAddress: 'Sample Site, Lagos',
      name: 'Demo L-Shaped Bungalow',
      roofType: 'gable',
      mode: CalculatorMode.professional,
      labourCost: 180000,
      transportCost: 65000,
      profitMargin: 0.15,
      createdAt: now,
      updatedAt: now,
      roofSections: const [
        RoofSectionModel(
          id: 'demo-main',
          name: 'Main roof',
          roofType: 'gable',
          length: 12,
          span: 8,
          pitch: 25,
          overhang: 0.45,
          rafterSpacing: 0.9,
          battenSpacing: 0.3,
          purlinSpacing: 0.3,
          sheetType: 'Longspan sheet',
          pricePerSheet: 8500,
        ),
        RoofSectionModel(
          id: 'demo-wing',
          name: 'Kitchen extension',
          roofType: 'mono-pitch',
          length: 6,
          span: 4,
          pitch: 18,
          overhang: 0.3,
          rafterSpacing: 0.9,
          battenSpacing: 0.4,
          purlinSpacing: 0.4,
          sheetType: 'Longspan sheet',
          pricePerSheet: 8500,
        ),
      ],
    );
  }
}
