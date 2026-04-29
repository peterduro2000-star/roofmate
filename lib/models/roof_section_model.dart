import '../services/calculation_result.dart';

class RoofSectionModel {
  final String id;
  final String name;
  final String roofType;
  final double length;
  final double span;
  final double pitch;
  final double overhang;
  final double rafterSpacing;
  final double battenSpacing;
  final double purlinSpacing;
  final double lapAllowance;
  final double sheetEffectiveWidth;
  final double wastePercentage;
  final String sheetType;
  final double pricePerSheet;
  final RoofingCalculation? calculation;

  const RoofSectionModel({
    required this.id,
    required this.name,
    required this.roofType,
    required this.length,
    required this.span,
    required this.pitch,
    required this.overhang,
    required this.rafterSpacing,
    required this.battenSpacing,
    this.purlinSpacing = 0.9,
    this.lapAllowance = 0.15,
    this.sheetEffectiveWidth = 0.686,
    this.wastePercentage = 0.1,
    this.sheetType = 'IBR Sheet',
    this.pricePerSheet = 0,
    this.calculation,
  });

  String get displayName {
    final names = {
      'gable': 'Gable Roof',
      'hip': 'Hip Roof',
      'mono-pitch': 'Mono-Pitch Roof',
    };
    return names[roofType] ?? 'Roof Section';
  }

  double get width => span;

  RoofSectionModel copyWith({
    String? id,
    String? name,
    String? roofType,
    double? length,
    double? span,
    double? pitch,
    double? overhang,
    double? rafterSpacing,
    double? battenSpacing,
    double? purlinSpacing,
    double? lapAllowance,
    double? sheetEffectiveWidth,
    double? wastePercentage,
    String? sheetType,
    double? pricePerSheet,
    RoofingCalculation? calculation,
  }) {
    return RoofSectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      roofType: roofType ?? this.roofType,
      length: length ?? this.length,
      span: span ?? this.span,
      pitch: pitch ?? this.pitch,
      overhang: overhang ?? this.overhang,
      rafterSpacing: rafterSpacing ?? this.rafterSpacing,
      battenSpacing: battenSpacing ?? this.battenSpacing,
      purlinSpacing: purlinSpacing ?? this.purlinSpacing,
      lapAllowance: lapAllowance ?? this.lapAllowance,
      sheetEffectiveWidth: sheetEffectiveWidth ?? this.sheetEffectiveWidth,
      wastePercentage: wastePercentage ?? this.wastePercentage,
      sheetType: sheetType ?? this.sheetType,
      pricePerSheet: pricePerSheet ?? this.pricePerSheet,
      calculation: calculation ?? this.calculation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roofType': roofType,
      'length': length,
      'width': span,
      'span': span,
      'pitch': pitch,
      'overhang': overhang,
      'rafterSpacing': rafterSpacing,
      'battenSpacing': battenSpacing,
      'purlinSpacing': purlinSpacing,
      'lapAllowance': lapAllowance,
      'sheetEffectiveWidth': sheetEffectiveWidth,
      'wastePercentage': wastePercentage,
      'sheetType': sheetType,
      'pricePerSheet': pricePerSheet,
      'calculation': calculation?.toJson(),
    };
  }

  factory RoofSectionModel.fromJson(Map<dynamic, dynamic> json) {
    final calculationJson = json['calculation'];

    return RoofSectionModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Roof Section',
      roofType: json['roofType'] as String,
      length: (json['length'] as num).toDouble(),
      span: ((json['span'] ?? json['width']) as num).toDouble(),
      pitch: (json['pitch'] as num).toDouble(),
      overhang: (json['overhang'] as num).toDouble(),
      rafterSpacing: (json['rafterSpacing'] as num).toDouble(),
      battenSpacing: (json['battenSpacing'] as num).toDouble(),
      purlinSpacing: (json['purlinSpacing'] as num? ?? 0.9).toDouble(),
      lapAllowance: (json['lapAllowance'] as num? ?? 0.15).toDouble(),
      sheetEffectiveWidth:
          (json['sheetEffectiveWidth'] as num? ?? 0.686).toDouble(),
      wastePercentage: (json['wastePercentage'] as num? ?? 0.1).toDouble(),
      sheetType: json['sheetType'] as String? ?? 'IBR Sheet',
      pricePerSheet: (json['pricePerSheet'] as num? ?? 0).toDouble(),
      calculation: calculationJson is Map<dynamic, dynamic>
          ? RoofingCalculation.fromJson(calculationJson)
          : null,
    );
  }
}
