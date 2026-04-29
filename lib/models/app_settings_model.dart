class AppSettingsModel {
  final double defaultWastePercentage;
  final String defaultCurrency;
  final String defaultRoofMaterial;
  final String defaultCompanyName;

  const AppSettingsModel({
    this.defaultWastePercentage = 0.1,
    this.defaultCurrency = 'NGN',
    this.defaultRoofMaterial = 'Longspan sheet',
    this.defaultCompanyName = 'RoofMate',
  });

  AppSettingsModel copyWith({
    double? defaultWastePercentage,
    String? defaultCurrency,
    String? defaultRoofMaterial,
    String? defaultCompanyName,
  }) {
    return AppSettingsModel(
      defaultWastePercentage:
          defaultWastePercentage ?? this.defaultWastePercentage,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultRoofMaterial: defaultRoofMaterial ?? this.defaultRoofMaterial,
      defaultCompanyName: defaultCompanyName ?? this.defaultCompanyName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultWastePercentage': defaultWastePercentage,
      'defaultCurrency': defaultCurrency,
      'defaultRoofMaterial': defaultRoofMaterial,
      'defaultCompanyName': defaultCompanyName,
    };
  }

  factory AppSettingsModel.fromJson(Map<dynamic, dynamic> json) {
    return AppSettingsModel(
      defaultWastePercentage:
          (json['defaultWastePercentage'] as num? ?? 0.1).toDouble(),
      defaultCurrency: json['defaultCurrency'] as String? ?? 'NGN',
      defaultRoofMaterial:
          json['defaultRoofMaterial'] as String? ?? 'Longspan sheet',
      defaultCompanyName: json['defaultCompanyName'] as String? ?? 'RoofMate',
    );
  }
}
