import 'package:flutter/material.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../models/product.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<ProductCategory> _categories = [];
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiClient().get(ApiEndpoints.adminCatalog);
      final rawCategories = res['categories'] ?? <dynamic>[];
      final rawProducts = res['products'] ?? <dynamic>[];

      setState(() {
        _categories = (rawCategories as List)
            .map(
              (e) =>
                  ProductCategory.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
        _products = (rawProducts as List)
            .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openCategoryDialog({ProductCategory? category}) async {
    final codeCtrl = TextEditingController(text: category?.code ?? '');
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final descCtrl = TextEditingController(text: '');
    bool isActive = category?.isActive ?? true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            category == null ? 'Nouvelle catégorie' : 'Modifier la catégorie',
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Code'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: isActive,
                  title: const Text('Catégorie active'),
                  onChanged: (v) => setState(() => isActive = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final payload = {
                  'code': codeCtrl.text.trim(),
                  'name': nameCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'is_active': isActive,
                };

                try {
                  if (category == null) {
                    await ApiClient().post(
                      ApiEndpoints.adminCatalogCategories,
                      payload,
                    );
                  } else {
                    await ApiClient().put(
                      '${ApiEndpoints.adminCatalogCategories}/${category.id}',
                      payload,
                    );
                  }
                  if (mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: AppColors.rouge,
                      ),
                    );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      await _loadCatalog();
    }
  }

  Future<void> _openProductDialog({Product? product}) async {
    final codeCtrl = TextEditingController(text: product?.code ?? '');
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final descCtrl = TextEditingController(text: '');
    final unitCtrl = TextEditingController(text: product?.unit ?? 'm²');
    final priceCtrl = TextEditingController(
      text: (product?.unitPrice ?? 0).toStringAsFixed(2),
    );
    final taxCtrl = TextEditingController(
      text: (product?.taxRate ?? 0).toStringAsFixed(2),
    );
    final lengthCtrl = TextEditingController(
      text: (product?.defaultLength ?? 1.0).toStringAsFixed(2),
    );
    final widthCtrl = TextEditingController(
      text: (product?.defaultWidth ?? 1.0).toStringAsFixed(2),
    );
    int? selectedCategoryId =
        product?.categoryId ?? _categories.firstOrNull?.id;
    bool allowDimensions = product?.allowDimensions ?? false;
    bool lengthField = product?.lengthField ?? true;
    bool widthField = product?.widthField ?? true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            product == null ? 'Nouveau produit' : 'Modifier le produit',
          ),
          content: SizedBox(
            width: 700,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: codeCtrl,
                          decoration: const InputDecoration(labelText: 'Code'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Nom'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Catégorie',
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem<int>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedCategoryId = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: unitCtrl,
                          decoration: const InputDecoration(labelText: 'Unité'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Prix unitaire / unité',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: taxCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Taux TVA (%)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: allowDimensions,
                    title: const Text('Produit avec dimensions / surface (m²)'),
                    onChanged: (value) =>
                        setState(() => allowDimensions = value),
                  ),
                  if (allowDimensions) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: lengthField,
                            title: const Text('Longueur'),
                            onChanged: (value) =>
                                setState(() => lengthField = value ?? false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: widthField,
                            title: const Text('Largeur'),
                            onChanged: (value) =>
                                setState(() => widthField = value ?? false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lengthCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Longueur par défaut (m)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: widthCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Largeur par défaut (m)',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final payload = {
                  'category_id': selectedCategoryId,
                  'code': codeCtrl.text.trim(),
                  'name': nameCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'unit': unitCtrl.text.trim().isEmpty
                      ? 'm²'
                      : unitCtrl.text.trim(),
                  'unit_price':
                      double.tryParse(priceCtrl.text.replaceAll(',', '.')) ?? 0,
                  'tax_rate':
                      double.tryParse(taxCtrl.text.replaceAll(',', '.')) ?? 0,
                  'is_active': true,
                  'allow_dimensions': allowDimensions,
                  'length_field': lengthField,
                  'width_field': widthField,
                  'length_label': 'Longueur (m)',
                  'width_label': 'Largeur (m)',
                  'default_length':
                      double.tryParse(lengthCtrl.text.replaceAll(',', '.')) ??
                      1,
                  'default_width':
                      double.tryParse(widthCtrl.text.replaceAll(',', '.')) ?? 1,
                };

                try {
                  if (product == null) {
                    await ApiClient().post(
                      ApiEndpoints.adminCatalogProducts,
                      payload,
                    );
                  } else {
                    await ApiClient().put(
                      '${ApiEndpoints.adminCatalogProducts}/${product.id}',
                      payload,
                    );
                  }
                  if (mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: AppColors.rouge,
                      ),
                    );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      await _loadCatalog();
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le produit ?'),
        content: Text(
          'Voulez-vous vraiment supprimer “${product.name}” du catalogue ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.rouge),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiClient().delete(
        '${ApiEndpoints.adminCatalogProducts}/${product.id}',
      );
      await _loadCatalog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.blanc,
            border: Border(bottom: BorderSide(color: AppColors.bord)),
          ),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: AppColors.bleu),
              const SizedBox(width: 10),
              const Text(
                'Catalogue Produits & Prestations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.bleu,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openCategoryDialog(),
                icon: const Icon(Icons.category_rounded, size: 16),
                label: const Text('Catégorie'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _openProductDialog(),
                icon: const Icon(Icons.add_circle_rounded, size: 16),
                label: const Text('Produit'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.rouge),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _ListCard(
                          title: 'Catégories',
                          children: _categories.isEmpty
                              ? const [
                                  Center(
                                    child: Text(
                                      'Aucune catégorie',
                                      style: TextStyle(color: AppColors.gris),
                                    ),
                                  ),
                                ]
                              : _categories
                                    .map(
                                      (category) => ListTile(
                                        title: Text(category.name),
                                        subtitle: Text(category.code),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: () => _openCategoryDialog(
                                            category: category,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: _ListCard(
                          title: 'Produits / Prestations',
                          children: _products.isEmpty
                              ? const [
                                  Center(
                                    child: Text(
                                      'Aucun produit',
                                      style: TextStyle(color: AppColors.gris),
                                    ),
                                  ),
                                ]
                              : _products
                                    .map(
                                      (product) => ListTile(
                                        title: Text(product.name),
                                        subtitle: Text(
                                          '${product.code} • ${product.unit} • ${product.unitPrice.toStringAsFixed(2)} FCFA',
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (product.allowDimensions)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.orange
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'Dimension',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.orange2,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                              onPressed: () =>
                                                  _openProductDialog(
                                                    product: product,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: AppColors.rouge,
                                              ),
                                              onPressed: () =>
                                                  _deleteProduct(product),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ListCard({required this.title, required this.children});

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: AppColors.bord)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.bleu,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
