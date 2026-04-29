class RoofingCalculation {
  final int sheets;
  final int rafters;
  final double ridgeBoardLength;
  final int wallPlatesNeeded;
  final int battensNeeded;
  final double rasterLength;
  final double roofArea;
  final int accessories;

  const RoofingCalculation({
    required this.sheets,
    required this.rafters,
    required this.ridgeBoardLength,
    required this.wallPlatesNeeded,
    required this.battensNeeded,
    required this.rasterLength,
    this.roofArea = 0,
    this.accessories = 0,
  });

  int get fasteners => accessories == 0 ? sheets * 20 : accessories;

  RoofingCalculation copyWith({
    int? sheets,
    int? rafters,
    double? ridgeBoardLength,
    int? wallPlatesNeeded,
    int? battensNeeded,
    double? rasterLength,
    double? roofArea,
    int? accessories,
  }) {
    return RoofingCalculation(
      sheets: sheets ?? this.sheets,
      rafters: rafters ?? this.rafters,
      ridgeBoardLength: ridgeBoardLength ?? this.ridgeBoardLength,
      wallPlatesNeeded: wallPlatesNeeded ?? this.wallPlatesNeeded,
      battensNeeded: battensNeeded ?? this.battensNeeded,
      rasterLength: rasterLength ?? this.rasterLength,
      roofArea: roofArea ?? this.roofArea,
      accessories: accessories ?? this.accessories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sheets': sheets,
      'rafters': rafters,
      'ridgeBoardLength': ridgeBoardLength,
      'wallPlatesNeeded': wallPlatesNeeded,
      'battensNeeded': battensNeeded,
      'rasterLength': rasterLength,
      'roofArea': roofArea,
      'accessories': accessories,
    };
  }

  factory RoofingCalculation.fromJson(Map<dynamic, dynamic> json) {
    return RoofingCalculation(
      sheets: json['sheets'] as int,
      rafters: json['rafters'] as int,
      ridgeBoardLength: (json['ridgeBoardLength'] as num).toDouble(),
      wallPlatesNeeded: json['wallPlatesNeeded'] as int,
      battensNeeded: json['battensNeeded'] as int,
      rasterLength: (json['rasterLength'] as num).toDouble(),
      roofArea: (json['roofArea'] as num? ?? 0).toDouble(),
      accessories: json['accessories'] as int? ?? 0,
    );
  }
}
