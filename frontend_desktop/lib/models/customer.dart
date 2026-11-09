class Customer {
  final int id;
  final String code;
  final String name;
  final String? phone;
  final String? email;
  final String? ifuNumber;
  final String? address;

  Customer({
    required this.id,
    required this.code,
    required this.name,
    this.phone,
    this.email,
    this.ifuNumber,
    this.address,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      code: json['code'] as String? ?? 'CLT-000',
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      ifuNumber: json['ifu_number'] as String?,
      address: json['address'] as String?,
    );
  }
}

