class ProductCategory {
  final int id;
  final String code;
  final String name;
  final bool isActive;

  ProductCategory({
    required this.id,
    required this.code,
    required this.name,
    this.isActive = true,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      isActive: json['is_active'] == true || json['active'] == true,
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
  final bool allowDimensions;
  final bool lengthField;
  final bool widthField;
  final String lengthLabel;
  final String widthLabel;
  final double defaultLength;
  final double defaultWidth;

  Product({
    required this.id,
    this.categoryId,
    required this.code,
    required this.name,
    this.unit = 'unité',
    required this.unitPrice,
    this.taxRate = 0,
    this.emoji,
    this.allowDimensions = false,
    this.lengthField = false,
    this.widthField = false,
    this.lengthLabel = 'Longueur (m)',
    this.widthLabel = 'Largeur (m)',
    this.defaultLength = 1,
    this.defaultWidth = 1,
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
    } else if (nameLower.contains('reliure') ||
        nameLower.contains('registre')) {
      emoji = '📒';
    } else if (nameLower.contains('stylo')) {
      emoji = '🖊';
    } else if (nameLower.contains('vinyle') ||
        nameLower.contains('autocollant')) {
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
      allowDimensions: json['allow_dimensions'] == true,
      lengthField: json['length_field'] == true,
      widthField: json['width_field'] == true,
      lengthLabel: (json['length_label'] ?? 'Longueur (m)').toString(),
      widthLabel: (json['width_label'] ?? 'Largeur (m)').toString(),
      defaultLength:
          double.tryParse(json['default_length']?.toString() ?? '1') ?? 1.0,
      defaultWidth:
          double.tryParse(json['default_width']?.toString() ?? '1') ?? 1.0,
    );
  }
}
