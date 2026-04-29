enum CalculatorMode {
  simple,
  professional;

  String get label {
    return switch (this) {
      CalculatorMode.simple => 'Simple Mode',
      CalculatorMode.professional => 'Professional Mode',
    };
  }

  static CalculatorMode fromName(String? name) {
    return CalculatorMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => CalculatorMode.professional,
    );
  }
}
