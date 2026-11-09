class ProductCategory {
  final int id;
  final String code;
  final String name;

  ProductCategory({required this.id, required this.code, required this.name});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }
}

class Product {
  final int id;
  final int? categoryId;
  final String code;
  final String name;
  final String unit;
  final double unitPrice;
  final double taxRate;
  final String? emoji;

  Product({
    required this.id,
    this.categoryId,
    required this.code,
    required this.name,
    this.unit = 'unité',
    required this.unitPrice,
    this.taxRate = 0,
    this.emoji,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String emoji = '📄';
    final nameLower = (json['name'] as String? ?? '').toLowerCase();
    if (nameLower.contains('bâche') || nameLower.contains('banderole')) {
      emoji = '📰';
    } else if (nameLower.contains('roll') || nameLower.contains('rollup')) {
      emoji = '🪧';
    } else if (nameLower.contains('carte')) {
      emoji = '💼';
    } else if (nameLower.contains('tasse') || nameLower.contains('mug')) {
      emoji = '☕';
    } else if (nameLower.contains('flyer') || nameLower.contains('affiche')) {
      emoji = '🖼';
    } else if (nameLower.contains('reliure') || nameLower.contains('registre')) {
      emoji = '📒';
    } else if (nameLower.contains('stylo')) {
      emoji = '🖊';
    } else if (nameLower.contains('vinyle') || nameLower.contains('autocollant')) {
      emoji = '🏷';
    }

    return Product(
      id: json['id'] as int,
      categoryId: json['category_id'] as int?,
      code: json['code'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String? ?? 'unité',
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      taxRate: double.tryParse(json['tax_rate']?.toString() ?? '0') ?? 0.0,
      emoji: emoji,
    );
  }
}

