import '../models/roof_section_model.dart';

class RoofInputValidator {
  const RoofInputValidator._();

  static String? validateSection(RoofSectionModel section) {
    if (section.length <= 0) {
      return 'Building length must be greater than zero.';
    }
    if (section.span <= 0) {
      return 'Building width must be greater than zero.';
    }
    if (section.pitch < 5 || section.pitch > 60) {
      return 'Roof pitch should be between 5 and 60 degrees.';
    }
    if (section.overhang < 0 || section.overhang > 2) {
      return 'Overhang should be between 0m and 2m.';
    }
    if (section.rafterSpacing < 0.3 || section.rafterSpacing > 1.5) {
      return 'Rafter spacing should be between 0.3m and 1.5m.';
    }
    if (section.purlinSpacing < 0.2 || section.purlinSpacing > 1.2) {
      return 'Purlin spacing should be between 0.2m and 1.2m.';
    }
    if (section.sheetEffectiveWidth <= 0 || section.sheetEffectiveWidth > 1.5) {
      return 'Sheet effective width should be greater than 0m and no more than 1.5m.';
    }
    if (section.wastePercentage < 0 || section.wastePercentage > 0.5) {
      return 'Waste percentage should be between 0% and 50%.';
    }
    if (section.pricePerSheet < 0) {
      return 'Price per sheet cannot be negative.';
    }

    return null;
  }
}
