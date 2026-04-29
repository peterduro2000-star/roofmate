import 'package:hive/hive.dart';
import '../services/calculation_result.dart';
import 'roof_section_model.dart';

part 'estimate_model.g.dart';

@HiveType(typeId: 0)
class Estimate extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String roofType;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late double length;

  @HiveField(5)
  late double span;

  @HiveField(6)
  late double pitch;

  @HiveField(7)
  late double overhang;

  @HiveField(8)
  late double rasterSpacing;

  @HiveField(9)
  late double battenSpacing;

  @HiveField(10)
  late int sheets;

  @HiveField(11)
  late int rafters;

  @HiveField(12)
  late double ridgeBoardLength;

  @HiveField(13)
  late int wallPlates;

  @HiveField(14)
  late int battens;

  @HiveField(15)
  late double rasterLength;

  Estimate({
    required this.id,
    required this.name,
    required this.roofType,
    required this.date,
    required this.length,
    required this.span,
    required this.pitch,
    required this.overhang,
    required this.rasterSpacing,
    required this.battenSpacing,
    required this.sheets,
    required this.rafters,
    required this.ridgeBoardLength,
    required this.wallPlates,
    required this.battens,
    required this.rasterLength,
  });

  RoofSectionModel toRoofSectionModel() {
    return RoofSectionModel(
      id: id,
      name: 'Main roof',
      roofType: roofType,
      length: length,
      span: span,
      pitch: pitch,
      overhang: overhang,
      rafterSpacing: rasterSpacing,
      battenSpacing: battenSpacing,
      calculation: RoofingCalculation(
        sheets: sheets,
        rafters: rafters,
        ridgeBoardLength: ridgeBoardLength,
        wallPlatesNeeded: wallPlates,
        battensNeeded: battens,
        rasterLength: rasterLength,
      ),
    );
  }

  factory Estimate.fromRoofSection({
    required String id,
    required String name,
    required DateTime date,
    required RoofSectionModel section,
  }) {
    final calculation = section.calculation;

    if (calculation == null) {
      throw ArgumentError('Roof section must include calculation results.');
    }

    return Estimate(
      id: id,
      name: name,
      roofType: section.roofType,
      date: date,
      length: section.length,
      span: section.span,
      pitch: section.pitch,
      overhang: section.overhang,
      rasterSpacing: section.rafterSpacing,
      battenSpacing: section.battenSpacing,
      sheets: calculation.sheets,
      rafters: calculation.rafters,
      ridgeBoardLength: calculation.ridgeBoardLength,
      wallPlates: calculation.wallPlatesNeeded,
      battens: calculation.battensNeeded,
      rasterLength: calculation.rasterLength,
    );
  }
}
