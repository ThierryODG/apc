import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.bord),
      ),
      child: Column(
        children: [
          // En-tête + filtres par catégorie
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFBFC),
              border: Border(bottom: BorderSide(color: AppColors.bord)),
            ),
            child: Row(
              children: [
                const Text(
                  'CATALOGUE PRESTATIONS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.bleu),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: 'Toutes',
                          isActive: selectedCategoryId == null,
                          onTap: () => onCategoryChanged(null),
                        ),
                        ...categories.map((cat) => _CategoryChip(
                          label: cat.name,
                          isActive: selectedCategoryId == cat.id,
                          onTap: () => onCategoryChanged(cat.id),
                        )),
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
                    child: Text(
                      'Aucun produit dans cette catégorie.',
                      style: TextStyle(color: AppColors.gris, fontSize: 13),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 180,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
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

  const _CategoryChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.bleu : AppColors.fond,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isActive ? AppColors.bleu : AppColors.bord),
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
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.blanc : AppColors.fond,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _hovered ? AppColors.orange : AppColors.bord,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: AppColors.orange.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))]
                : null,
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.product.emoji ?? '📄', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                widget.product.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.texte),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatPrice(widget.product.unitPrice)} F/${widget.product.unit}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.orange2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    // Format simple ex: 6 500
    if (price >= 1000) {
      return '${(price ~/ 1000)} ${(price % 1000 == 0 ? '000' : (price % 1000).toInt())}';
    }
    return price.toInt().toString();
  }
}

