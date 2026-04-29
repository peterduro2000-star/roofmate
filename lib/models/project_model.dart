import 'calculator_mode.dart';
import 'estimate_model.dart';
import 'roof_section_model.dart';

class ProjectModel {
  final String id;
  final String clientName;
  final String siteAddress;
  final String name;
  final String roofType;
  final CalculatorMode mode;
  final double labourCost;
  final double transportCost;
  final double profitMargin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RoofSectionModel> roofSections;

  const ProjectModel({
    required this.id,
    this.clientName = '',
    this.siteAddress = '',
    required this.name,
    this.roofType = 'gable',
    this.mode = CalculatorMode.professional,
    this.labourCost = 0,
    this.transportCost = 0,
    this.profitMargin = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.roofSections,
  });

  RoofSectionModel? get primaryRoofSection =>
      roofSections.isEmpty ? null : roofSections.first;

  ProjectModel copyWith({
    String? id,
    String? clientName,
    String? siteAddress,
    String? name,
    String? roofType,
    CalculatorMode? mode,
    double? labourCost,
    double? transportCost,
    double? profitMargin,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RoofSectionModel>? roofSections,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      siteAddress: siteAddress ?? this.siteAddress,
      name: name ?? this.name,
      roofType: roofType ?? this.roofType,
      mode: mode ?? this.mode,
      labourCost: labourCost ?? this.labourCost,
      transportCost: transportCost ?? this.transportCost,
      profitMargin: profitMargin ?? this.profitMargin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roofSections: roofSections ?? this.roofSections,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'siteAddress': siteAddress,
      'projectName': name,
      'name': name,
      'roofType': roofType,
      'mode': mode.name,
      'labourCost': labourCost,
      'transportCost': transportCost,
      'profitMargin': profitMargin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'roofSections': roofSections.map((section) => section.toJson()).toList(),
    };
  }

  factory ProjectModel.fromJson(Map<dynamic, dynamic> json) {
    final sections = json['roofSections'] as List<dynamic>? ?? const [];

    return ProjectModel(
      id: json['id'] as String,
      clientName: json['clientName'] as String? ?? '',
      siteAddress: json['siteAddress'] as String? ?? '',
      name: json['projectName'] as String? ?? json['name'] as String,
      roofType: json['roofType'] as String? ?? 'gable',
      mode: CalculatorMode.fromName(json['mode'] as String?),
      labourCost: (json['labourCost'] as num? ?? 0).toDouble(),
      transportCost: (json['transportCost'] as num? ?? 0).toDouble(),
      profitMargin: (json['profitMargin'] as num? ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      roofSections: sections
          .map((section) =>
              RoofSectionModel.fromJson(section as Map<dynamic, dynamic>))
          .toList(),
    );
  }

  factory ProjectModel.fromEstimate(Estimate estimate) {
    return ProjectModel(
      id: estimate.id,
      clientName: '',
      siteAddress: '',
      name: estimate.name,
      roofType: estimate.roofType,
      mode: CalculatorMode.professional,
      createdAt: estimate.date,
      updatedAt: estimate.date,
      roofSections: [estimate.toRoofSectionModel()],
    );
  }
}
