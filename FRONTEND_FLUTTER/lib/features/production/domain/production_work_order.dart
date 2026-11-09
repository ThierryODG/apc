class ProductionWorkOrder {
  const ProductionWorkOrder({
    required this.id,
    required this.number,
    required this.orderNumber,
    required this.subject,
    required this.customerName,
    required this.description,
    required this.status,
    required this.departmentName,
  });

  final int id;
  final String number;
  final String orderNumber;
  final String subject;
  final String customerName;
  final String description;
  final String status;
  final String departmentName;

  factory ProductionWorkOrder.fromJson(Map<String, dynamic> json) {
    final order = json['order'] is Map
        ? Map<String, dynamic>.from(json['order'] as Map)
        : const <String, dynamic>{};
    final department = json['department'] is Map
        ? Map<String, dynamic>.from(json['department'] as Map)
        : const <String, dynamic>{};

    return ProductionWorkOrder(
      id: _asInt(json['id']),
      number: '${json['work_order_number'] ?? ''}',
      orderNumber: '${order['order_number'] ?? ''}',
      subject: '${order['subject'] ?? ''}',
      customerName: '${order['customer'] ?? order['contact_name'] ?? ''}',
      description: '${json['description'] ?? ''}',
      status: '${json['status'] ?? 'pending'}',
      departmentName: '${department['name'] ?? ''}',
    );
  }

  static int _asInt(dynamic value) =>
      value is int ? value : int.tryParse('$value') ?? 0;
}