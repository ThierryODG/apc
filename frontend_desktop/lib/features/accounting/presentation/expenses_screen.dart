import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Map<String, dynamic>> _expenses = [];
  bool _loading = true;
  String? _error;
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'Papier & Supports',
    'Encres & Toners',
    'Bâches & Vinyles',
    'Plaques & Produits chimiques',
    'Maintenance & Pièces',
    'Loyer & Électricité',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient().get(ApiEndpoints.accountingExpenses);
      final list = ApiClient.extractList(res, 'expenses');
      setState(() { _expenses = list.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  String _fmt(dynamic v) {
    final n = (double.tryParse('$v') ?? 0).toInt();
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = n % 1000;
      return '$thousands ${remainder.toString().padLeft(3, '0')} F';
    }
    return '$n F';
  }

  String _shortDate(dynamic dt) {
    if (dt == null) return '—';
    try {
      final d = DateTime.parse(dt.toString());
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) { return dt.toString().substring(0, 10); }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_selectedCategory == 'all') return _expenses;
    return _expenses.where((e) => (e['category'] ?? '').toString().toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  double get _totalStockOut => _filtered.fold(0, (s, e) => s + (double.tryParse('${e['amount']}') ?? 0));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── En-tête Suivi Consommables ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.blanc,
            border: Border(bottom: BorderSide(color: AppColors.bord)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.bleu.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.bleu),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Suivi des Consommables & Matières Premières', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.bleu)),
                  Text('Gestion des achats : papiers, encres, rouleaux de bâche, maintenance', style: TextStyle(fontSize: 11, color: AppColors.gris)),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openCreate(),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Entrée Consommable / Dépense', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleu,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ),

        // ── Filtres par catégorie de consommables ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          color: const Color(0xFFF8FAFC),
          child: Row(
            children: [
              const Text('Catégories :', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gris)),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final active = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat == 'all' ? 'Toutes les matières' : cat),
                          selected: active,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.rouge.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Text('Total engagé : ', style: TextStyle(fontSize: 11, color: AppColors.gris)),
                    Text(_fmt(_totalStockOut), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.rouge)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Liste des consommables et dépenses ──
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
                  : _filtered.isEmpty
                      ? const Center(child: Text('Aucun consommable ou dépense pour cette catégorie.', style: TextStyle(color: AppColors.gris)))
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.blanc,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.bord),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                    border: Border(bottom: BorderSide(color: AppColors.bord)),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(flex: 2, child: Text('DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gris))),
                                      Expanded(flex: 4, child: Text('DÉSIGNATION / CONSOMMABLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gris))),
                                      Expanded(flex: 3, child: Text('CATÉGORIE MATIÈRE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gris))),
                                      Expanded(flex: 2, child: Text('MONTANT DÉPENSÉ', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gris))),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: _filtered.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
                                    itemBuilder: (ctx, i) {
                                      final e = _filtered[i];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: Row(
                                          children: [
                                            Expanded(flex: 2, child: Text(_shortDate(e['date'] ?? e['expense_date']), style: const TextStyle(fontSize: 11, color: AppColors.gris))),
                                            Expanded(flex: 4, child: Text(e['description'] ?? '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.fond,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(e['category'] ?? 'Général', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.bleu)),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                _fmt(e['amount']),
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.rouge),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
        ),
      ],
    );
  }

  Future<void> _openCreate() async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => const _CreateExpenseDialog());
    if (ok == true) _load();
  }
}

class _CreateExpenseDialog extends StatefulWidget {
  const _CreateExpenseDialog();
  @override State<_CreateExpenseDialog> createState() => _CreateExpenseDialogState();
}

class _CreateExpenseDialogState extends State<_CreateExpenseDialog> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _category = 'Papier & Supports';
  bool _loading = false;
  String? _error;

  final List<String> _categoryOptions = [
    'Papier & Supports',
    'Encres & Toners',
    'Bâches & Vinyles',
    'Plaques & Produits chimiques',
    'Maintenance & Pièces',
    'Loyer & Électricité',
    'Autre charge',
  ];

  Future<void> _submit() async {
    if (_descCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Désignation et montant sont obligatoires.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiClient().post(ApiEndpoints.accountingExpenses, {
        'description': _descCtrl.text.trim(),
        'amount': double.tryParse(_amountCtrl.text.trim()) ?? 0,
        'category': _category,
        'date': DateTime.now().toIso8601String().substring(0, 10),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: SizedBox(
      width: 440,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.bleu,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text('Nouvel Achat / Sortie Consommable', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: AppColors.rouge.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                    child: Text(_error!, style: const TextStyle(color: AppColors.rouge, fontSize: 12)),
                  ),
                const Text('Catégorie de consommable *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.bord), borderRadius: BorderRadius.circular(6)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _category,
                      isExpanded: true,
                      items: _categoryOptions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => _category = v ?? _category),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Désignation détaillée du consommable *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
                const SizedBox(height: 6),
                TextField(controller: _descCtrl, decoration: const InputDecoration(hintText: 'Ex: 5 cartons papier couché 150g ou 2 rouleaux bâche 510g')),
                const SizedBox(height: 14),
                const Text('Montant décaissé (FCFA) *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
                const SizedBox(height: 6),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '0', suffixText: 'FCFA'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler'))),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Enregistrer le consommable'),
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
