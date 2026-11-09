class ReceiptData {
  final Map<String, dynamic> header;
  final Map<String, dynamic> ticket;
  final Map<String, dynamic> customer;
  final List<dynamic> items;
  final Map<String, dynamic> totals;
  final List<dynamic> payments;
  final Map<String, dynamic> footer;

  ReceiptData({
    required this.header,
    required this.ticket,
    required this.customer,
    required this.items,
    required this.totals,
    required this.payments,
    required this.footer,
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json) {
    return ReceiptData(
      header: json['header'] as Map<String, dynamic>? ?? {},
      ticket: json['ticket'] as Map<String, dynamic>? ?? {},
      customer: json['customer'] as Map<String, dynamic>? ?? {},
      items: json['items'] as List<dynamic>? ?? [],
      totals: json['totals'] as Map<String, dynamic>? ?? {},
      payments: json['payments'] as List<dynamic>? ?? [],
      footer: json['footer'] as Map<String, dynamic>? ?? {},
    );
  }
}

