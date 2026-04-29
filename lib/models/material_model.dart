class MaterialModel {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double unitPrice;
  final double wastePercentage;

  const MaterialModel({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.unitPrice,
    required this.wastePercentage,
  });

  MaterialModel copyWith({
    String? id,
    String? name,
    String? category,
    String? unit,
    double? unitPrice,
    double? wastePercentage,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      wastePercentage: wastePercentage ?? this.wastePercentage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'unitPrice': unitPrice,
      'wastePercentage': wastePercentage,
    };
  }

  factory MaterialModel.fromJson(Map<dynamic, dynamic> json) {
    return MaterialModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      wastePercentage: (json['wastePercentage'] as num).toDouble(),
    );
  }
}
