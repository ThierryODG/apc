import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/product_icon_helper.dart';
import '../../../../models/product.dart';

class ProductCatalogPanel extends StatelessWidget {
  final List<ProductCategory> categories;
  final List<Product> products;
  final int? selectedCategoryId;
  final Function(int? categoryId) onCategoryChanged;
  final Function(Product product) onProductTapped;

  const ProductCatalogPanel({
    super.key,
    required this.categories,
    required this.products,
    this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.onProductTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.bord),
      ),
      child: Column(
        children: [
          // En-tête + filtres par catégorie
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: AppColors.bord)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.grid_view_rounded,
                  size: 16,
                  color: AppColors.bleu,
                ),
                const SizedBox(width: 8),
                const Text(
                  'CATALOGUE PRESTATIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: AppColors.bleu,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: 'Toutes les catégories',
                          isActive: selectedCategoryId == null,
                          onTap: () => onCategoryChanged(null),
                        ),
                        ...categories.map(
                          (cat) => _CategoryChip(
                            label: cat.name,
                            isActive: selectedCategoryId == cat.id,
                            onTap: () => onCategoryChanged(cat.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grille produits style Aronium
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 40,
                          color: AppColors.bord,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Aucune prestation dans cette catégorie.',
                          style: TextStyle(color: AppColors.gris, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 190,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.05,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return _ProductCard(
                          product: products[index],
                          onTap: () => onProductTapped(products[index]),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isActive ? AppColors.bleu : AppColors.fond,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.bleu : AppColors.bord,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : AppColors.gris,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final icon = ProductIconHelper.getIcon(
      widget.product.name,
      widget.product.unit,
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white : const Color(0xFFFBFDFF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? AppColors.orange : AppColors.bord,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: (_hovered ? AppColors.orange : AppColors.bleu)
                      .withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: _hovered ? AppColors.orange : AppColors.bleu,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.texte,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.fond,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '${_formatPrice(widget.product.unitPrice)} F / ${widget.product.unit}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.orange2,
                        ),
                      ),
                    ),
                    if (widget.product.allowDimensions) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'm²',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppColors.orange2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      final t = price.toInt();
      return '${(t ~/ 1000)} ${(t % 1000).toString().padLeft(3, '0')}';
    }
    return price.toInt().toString();
  }
}
