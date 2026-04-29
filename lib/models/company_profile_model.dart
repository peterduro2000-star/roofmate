class CompanyProfileModel {
  final String companyName;
  final String phoneNumber;
  final String email;
  final String address;
  final String? logoPath;

  const CompanyProfileModel({
    this.companyName = 'RoofMate',
    this.phoneNumber = '',
    this.email = '',
    this.address = '',
    this.logoPath,
  });

  CompanyProfileModel copyWith({
    String? companyName,
    String? phoneNumber,
    String? email,
    String? address,
    String? logoPath,
  }) {
    return CompanyProfileModel(
      companyName: companyName ?? this.companyName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      logoPath: logoPath ?? this.logoPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'logoPath': logoPath,
    };
  }

  factory CompanyProfileModel.fromJson(Map<dynamic, dynamic> json) {
    return CompanyProfileModel(
      companyName: json['companyName'] as String? ?? 'RoofMate',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      logoPath: json['logoPath'] as String?,
    );
  }
}
