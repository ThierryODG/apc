class FiscalYear {
  final int id;
  final String name;
  final String code;
  final String? status;
  final bool isActive;

  FiscalYear({
    required this.id,
    required this.name,
    required this.code,
    this.status,
    this.isActive = true,
  });

  factory FiscalYear.fromJson(Map<String, dynamic> json) {
    return FiscalYear(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      status: json['status'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}

