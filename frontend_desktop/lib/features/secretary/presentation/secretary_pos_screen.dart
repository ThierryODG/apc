import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../models/product.dart';
import '../../../../models/customer.dart';
import 'widgets/product_catalog_panel.dart';
import 'widgets/live_ticket_panel.dart';
import 'widgets/kpi_strip.dart';
import 'widgets/pos_topbar.dart';

class SecretaryPosScreen extends StatefulWidget {
  const SecretaryPosScreen({super.key});

  @override
  State<SecretaryPosScreen> createState() => _SecretaryPosScreenState();
}

class _SecretaryPosScreenState extends State<SecretaryPosScreen> {
  // ── Recherche ───────────────────────────────────────────
  final _searchCtrl = TextEditingController();

  // ── Données ──────────────────────────────────────────────
  List<ProductCategory> _categories = [];
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  int? _selectedCategoryId;

  // ── Ticket ───────────────────────────────────────────────
  final List<TicketLine> _lines = [];
  Customer? _selectedCustomer;
  double _discountPercent = 0;

  // ── KPI ──────────────────────────────────────────────────
  int _ventesCount = 0;
  double _caDuJour = 0;
  int _enProduction = 0;
  double _creances = 0;

  // ── État ─────────────────────────────────────────────────
  bool _loadingProducts = true;
  bool _loadingKpi = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadProducts(), _loadKpi()]);
  }

  Future<void> _loadProducts() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.secretaryProducts);
      final List cats = res['categories'] ?? [];
      final List prods = res['products'] ?? [];
      setState(() {
        _categories = cats.map((c) => ProductCategory.fromJson(c)).toList();
        _allProducts = prods.map((p) => Product.fromJson(p)).toList();
        _filteredProducts = List.from(_allProducts);
        _loadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur chargement produits: $e';
        _loadingProducts = false;
      });
    }
  }

  Future<void> _loadKpi() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.secretaryDashboard);
      setState(() {
        _ventesCount = (res['today_orders_count'] ?? 0) as int;
        _caDuJour = double.tryParse('${res['today_revenue'] ?? 0}') ?? 0;
        _enProduction = (res['in_production_count'] ?? 0) as int;
        _creances = double.tryParse('${res['total_receivables'] ?? 0}') ?? 0;
        _loadingKpi = false;
      });
    } catch (_) {
      setState(() => _loadingKpi = false);
    }
  }

  void _filterByCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _filteredProducts = categoryId == null
          ? List.from(_allProducts)
          : _allProducts.where((p) => p.categoryId == categoryId).toList();
    });
  }

  void _addProduct(Product product) {
    setState(() {
      final idx = _lines.indexWhere((l) => l.productId == product.id);
      if (idx >= 0) {
        _lines[idx].qty++;
      } else {
        _lines.add(TicketLine(
          productId: product.id,
          productName: product.name,
          unit: product.unit,
          unitPrice: product.unitPrice,
        ));
      }
    });
  }

  void _removeLine(int index) {
    setState(() => _lines.removeAt(index));
  }

  void _updateQty(int index, int qty) {
    setState(() => _lines[index].qty = qty);
  }

  void _cancelTicket() {
    setState(() {
      _lines.clear();
      _selectedCustomer = null;
      _discountPercent = 0;
    });
  }

  void _holdTicket() {
    // TODO: sauvegarder en mémoire pour reprise
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ticket mis en attente.'), backgroundColor: AppColors.gris),
    );
  }

  void _openCheckout() {
    if (_lines.isEmpty) return;

    final subTotal = _lines.fold<double>(0, (s, l) => s + l.lineTotal);
    final discount = subTotal * _discountPercent / 100;
    final total = subTotal - discount;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CheckoutDialog(
        total: total,
        customer: _selectedCustomer,
        lines: _lines,
        discountPercent: _discountPercent,
        onConfirm: (paymentMethod, amountReceived) => _confirmPayment(paymentMethod, amountReceived, total),
      ),
    );
  }

  Future<void> _confirmPayment(String method, double amountReceived, double total) async {
    try {
      final orderLines = _lines.map((l) => {
        'product_id': l.productId,
        'quantity': l.qty,
        'unit_price': l.unitPrice,
      }).toList();

      final body = {
        'customer_id': _selectedCustomer?.id,
        'discount_percent': _discountPercent,
        'payment_method': method,
        'amount_received': amountReceived,
        'items': orderLines,
        'fiscal_year_id': AuthState().activeFiscalYear?.id,
      };

      await ApiClient().post(ApiEndpoints.secretaryOrders, body);

      if (!mounted) return;
      Navigator.pop(context); // ferme checkout dialog

      // Mise à jour KPI
      setState(() {
        _ventesCount++;
        _caDuJour += total;
        _lines.clear();
        _selectedCustomer = null;
        _discountPercent = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Vente enregistrée avec succès !'),
          backgroundColor: AppColors.vert,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.rouge),
      );
    }
  }

  Future<void> _openSelectCustomer() async {
    final selected = await showDialog<Customer>(
      context: context,
      builder: (ctx) => _CustomerPickerDialog(),
    );
    if (selected != null) {
      setState(() => _selectedCustomer = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.f4) _openCheckout();
        }
      },
      child: Column(
        children: [
          // Topbar
          PosTopbar(
            searchController: _searchCtrl,
            onSearchChanged: (q) {
              final query = q.toLowerCase();
              setState(() {
                _filteredProducts = _allProducts.where((p) =>
                  p.name.toLowerCase().contains(query) ||
                  (p.code?.toLowerCase().contains(query) ?? false)
                ).toList();
              });
            },
          ),

          // Corps principal
          Expanded(
            child: _loadingProducts
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Catalogue produits (flex)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ProductCatalogPanel(
                                categories: _categories,
                                products: _filteredProducts,
                                selectedCategoryId: _selectedCategoryId,
                                onCategoryChanged: _filterByCategory,
                                onProductTapped: _addProduct,
                              ),
                            ),
                          ),
                          // Ticket en cours (fixe 350px)
                          LiveTicketPanel(
                            lines: _lines,
                            selectedCustomer: _selectedCustomer,
                            discountPercent: _discountPercent,
                            onCancel: _cancelTicket,
                            onHold: _holdTicket,
                            onCheckout: _openCheckout,
                            onSelectCustomer: _openSelectCustomer,
                            onRemoveLine: _removeLine,
                            onUpdateQty: _updateQty,
                            onDiscountChanged: (p) => setState(() => _discountPercent = p),
                          ),
                        ],
                      ),
          ),

          // KPI strip en bas
          KpiStrip(
            ventesCount: _ventesCount,
            caDuJour: _caDuJour,
            enProduction: _enProduction,
            creances: _creances,
            isLoading: _loadingKpi,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog Encaissement
// ─────────────────────────────────────────────────────────────────────────────

class _CheckoutDialog extends StatefulWidget {
  final double total;
  final Customer? customer;
  final List<TicketLine> lines;
  final double discountPercent;
  final Function(String method, double amountReceived) onConfirm;

  const _CheckoutDialog({
    required this.total,
    required this.customer,
    required this.lines,
    required this.discountPercent,
    required this.onConfirm,
  });

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  String _method = 'cash';
  final _amountCtrl = TextEditingController();
  bool _isLoading = false;

  double get _amountReceived => double.tryParse(_amountCtrl.text.replaceAll(' ', '').replaceAll(',', '.')) ?? 0;
  double get _change => _amountReceived - widget.total;

  String _fmt(double v) {
    final n = v.toInt();
    if (n >= 1000) return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3, '0')} FCFA';
    return '$n FCFA';
  }

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.total.toInt().toString();
    _amountCtrl.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.bleu,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'ENCAISSEMENT',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  Text(
                    _fmt(widget.total),
                    style: const TextStyle(color: AppColors.orange, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé
                  if (widget.customer != null)
                    Text('Client : ${widget.customer!.name}',
                        style: const TextStyle(fontSize: 12, color: AppColors.gris)),
                  Text('${widget.lines.length} article(s) — Remise ${widget.discountPercent.toInt()}%',
                      style: const TextStyle(fontSize: 12, color: AppColors.gris)),
                  const SizedBox(height: 20),

                  // Mode de paiement
                  const Text('Mode de paiement :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _PayMethodChip(label: '💵 Espèces', value: 'cash', selected: _method == 'cash',
                          onTap: () => setState(() => _method = 'cash')),
                      _PayMethodChip(label: '📱 Mobile Money', value: 'mobile_money', selected: _method == 'mobile_money',
                          onTap: () => setState(() => _method = 'mobile_money')),
                      _PayMethodChip(label: '🏦 Virement', value: 'bank_transfer', selected: _method == 'bank_transfer',
                          onTap: () => setState(() => _method = 'bank_transfer')),
                      _PayMethodChip(label: '📄 Chèque', value: 'check', selected: _method == 'check',
                          onTap: () => setState(() => _method = 'check')),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Montant reçu
                  if (_method == 'cash') ...[
                    const Text('Montant reçu (FCFA) :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      decoration: InputDecoration(
                        suffixText: 'FCFA',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_amountReceived >= widget.total)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.vert.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.vert.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Monnaie à rendre :', style: TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                              _fmt(_change),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.vert),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.rouge.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.rouge.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Reste dû :', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.rouge)),
                            Text(
                              _fmt(widget.total - _amountReceived),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.rouge),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gris,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() => _isLoading = true);
                              widget.onConfirm(
                                _method,
                                _method == 'cash' ? _amountReceived : widget.total,
                              );
                            },
                      icon: _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_outline_rounded, size: 16),
                      label: const Text('VALIDER & IMPRIMER', style: TextStyle(fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vert,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayMethodChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _PayMethodChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.bleu : AppColors.fond,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? AppColors.bleu : AppColors.bord),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.texte,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog sélection client
// ─────────────────────────────────────────────────────────────────────────────

class _CustomerPickerDialog extends StatefulWidget {
  @override
  State<_CustomerPickerDialog> createState() => _CustomerPickerDialogState();
}

class _CustomerPickerDialogState extends State<_CustomerPickerDialog> {
  List<Customer> _customers = [];
  List<Customer> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = _customers.where((c) =>
          c.name.toLowerCase().contains(q) ||
          (c.phone ?? '').contains(q)
        ).toList();
      });
    });
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.secretaryCustomers);
      final List data = res['data'] ?? res['customers'] ?? [];
      setState(() {
        _customers = data.map((c) => Customer.fromJson(c)).toList();
        _filtered = List.from(_customers);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 400,
        height: 480,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.bleu,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_alt_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text('Sélectionner un client', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom ou téléphone...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final c = _filtered[i];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.bleu,
                            radius: 16,
                            child: Text(
                              c.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                            ),
                          ),
                          title: Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          subtitle: Text(c.phone ?? c.email ?? '', style: const TextStyle(fontSize: 11)),
                          onTap: () => Navigator.pop(context, c),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('Client Comptoir'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

