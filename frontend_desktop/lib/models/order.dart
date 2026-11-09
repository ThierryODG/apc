class OrderItem {
  final int? id;
  final int? productId;
  final String designation;
  final String unit;
  double quantity;
  final double unitPrice;
  final double taxRate;
  double discount;

  OrderItem({
    this.id,
    this.productId,
    required this.designation,
    this.unit = 'unité',
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 0,
    this.discount = 0,
  });

  double get subtotal => (quantity * unitPrice) - discount;
  double get taxAmount => subtotal * (taxRate / 100);
  double get total => subtotal + taxAmount;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'designation': designation,
      'unit': unit,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_rate': taxRate,
      'discount_amount': discount,
    };
  }
}

class Order {
  final int id;
  final String orderNumber;
  final DateTime orderDate;
  final String status;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String paymentStatus;
  final String? customerName;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentStatus,
    this.customerName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    String? cName;
    if (json['customer'] != null && json['customer']['name'] != null) {
      cName = json['customer']['name'] as String;
    }

    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      status: json['status'] as String? ?? 'confirmed',
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0,
      dueAmount: double.tryParse(json['due_amount']?.toString() ?? '0') ?? 0,
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      customerName: cName,
    );
  }
}

