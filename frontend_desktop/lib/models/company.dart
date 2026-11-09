class Company {
  final String name;
  final String? legalForm;
  final String? ifuNumber;
  final String? rccmNumber;
  final String? phonePrimary;
  final String? phoneSecondary;
  final String? email;
  final String? address;
  final String? city;
  final String currency;
  final String? logoPath;
  final String? receiptFooter;

  Company({
    required this.name,
    this.legalForm,
    this.ifuNumber,
    this.rccmNumber,
    this.phonePrimary,
    this.phoneSecondary,
    this.email,
    this.address,
    this.city,
    this.currency = 'FCFA',
    this.logoPath,
    this.receiptFooter,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] as String? ?? 'Africa Print Communication',
      legalForm: json['legal_form'] as String?,
      ifuNumber: json['ifu_number'] as String?,
      rccmNumber: json['rccm_number'] as String?,
      phonePrimary: json['phone_primary'] as String?,
      phoneSecondary: json['phone_secondary'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      currency: json['currency'] as String? ?? 'FCFA',
      logoPath: json['logo_path'] as String?,
      receiptFooter: json['receipt_footer'] as String?,
    );
  }
}

