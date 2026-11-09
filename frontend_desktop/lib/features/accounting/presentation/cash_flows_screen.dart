import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class CashFlowsScreen extends StatefulWidget {
  const CashFlowsScreen({super.key});

  @override
  State<CashFlowsScreen> createState() => _CashFlowsScreenState();
}

class _CashFlowsScreenState extends State<CashFlowsScreen> {
  List<Map<String, dynamic>> _flows = [];
  bool _loading = true;
  String? _error;
  String _typeFilter = 'all'; // all | in | out

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient().get(ApiEndpoints.accountingCashFlows);
      final List data = res['data'] ?? res['cash_flows'] ?? [];
      setState(() {
        _flows = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_typeFilter == 'all') return _flows;
    return _flows.where((f) => f['type'] == _typeFilter).toList();
  }

  String _fmt(dynamic v) {
    final n = (double.tryParse('$v') ?? 0).toInt();
    if (n >= 1000) return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3, '0')} F';
    return '$n F';
  }

  String _shortDate(dynamic dt) {
    if (dt == null) return '—';
    try {
      final d = DateTime.parse(dt.toString());
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return dt.toString().substring(0, 10);
    }
  }

  // Totaux
  double get _totalIn => _flows.where((f) => f['type'] == 'in').fold(0, (s, f) => s + (double.tryParse('${f['amount']}') ?? 0));
  double get _totalOut => _flows.where((f) => f['type'] == 'out').fold(0, (s, f) => s + (double.tryParse('${f['amount']}') ?? 0));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── En-tête ──────────────────────────────────────────
        _ScreenHeader(
          title: 'Journal de Trésorerie',
          icon: Icons.account_balance_wallet_rounded,
          actionLabel: '+ Nouveau mouvement',
          onAction: _openCreateDialog,
          child: Row(
            children: [
              _FilterChip(label: 'Tous', active: _typeFilter == 'all', onTap: () => setState(() => _typeFilter = 'all')),
              _FilterChip(label: '📥 Entrées', active: _typeFilter == 'in', onTap: () => setState(() => _typeFilter = 'in')),
              _FilterChip(label: '📤 Sorties', active: _typeFilter == 'out', onTap: () => setState(() => _typeFilter = 'out')),
            ],
          ),
        ),

        // ── Résumé entrées/sorties ────────────────────────────
        if (!_loading && _error == null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                _SummaryBadge(label: 'Total entrées', value: _fmt(_totalIn), color: AppColors.vert),
                const SizedBox(width: 16),
                _SummaryBadge(label: 'Total sorties', value: _fmt(_totalOut), color: AppColors.rouge),
                const SizedBox(width: 16),
                _SummaryBadge(
                  label: 'Solde net',
                  value: _fmt(_totalIn - _totalOut),
                  color: (_totalIn - _totalOut) >= 0 ? AppColors.bleu : AppColors.rouge,
                ),
              ],
            ),
          ),

        // ── Tableau ───────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
                  : _filtered.isEmpty
                      ? const Center(child: Text('Aucun mouvement.', style: TextStyle(color: AppColors.gris)))
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: _DataTable(
                            headers: const ['DATE', 'DESCRIPTION', 'TYPE', 'CATÉGORIE', 'MONTANT'],
                            rows: _filtered.map((f) {
                              final isIn = f['type'] == 'in';
                              return <String>[
                                _shortDate(f['date']),
                                f['description'] ?? '—',
                                isIn ? '📥 Entrée' : '📤 Sortie',
                                f['category'] ?? '—',
                                '${isIn ? '+' : '-'} ${_fmt(f['amount'])}',
                              ];
                            }).toList(),
                            rowColors: _filtered.map((f) {
                              return f['type'] == 'in' ? AppColors.vert : AppColors.rouge;
                            }).toList(),
                            highlightLastCol: true,
                          ),
                        ),
        ),
      ],
    );
  }

  Future<void> _openCreateDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _CreateCashFlowDialog(),
    );
    if (created == true) _load();
  }
}

class _SummaryBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryBadge({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text('$label : ', style: const TextStyle(fontSize: 11, color: AppColors.gris)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}

class _CreateCashFlowDialog extends StatefulWidget {
  const _CreateCashFlowDialog();

  @override
  State<_CreateCashFlowDialog> createState() => _CreateCashFlowDialogState();
}

class _CreateCashFlowDialogState extends State<_CreateCashFlowDialog> {
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  String _type = 'in';
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_descCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Description et montant sont obligatoires.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiClient().post(ApiEndpoints.accountingCashFlows, {
        'type': _type,
        'description': _descCtrl.text.trim(),
        'amount': double.tryParse(_amountCtrl.text.trim()) ?? 0,
        'category': _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
        'date': DateTime.now().toIso8601String().substring(0, 10),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(title: 'Nouveau mouvement de trésorerie', icon: Icons.account_balance_wallet_rounded),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) _ErrorBanner(_error!),
                  const _FieldLabel('Type de mouvement *'),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = 'in'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _type == 'in' ? AppColors.vert.withOpacity(0.1) : AppColors.fond,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _type == 'in' ? AppColors.vert : AppColors.bord),
                            ),
                            child: Text(
                              '📥 Entrée',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _type == 'in' ? AppColors.vert : AppColors.gris,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = 'out'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _type == 'out' ? AppColors.rouge.withOpacity(0.1) : AppColors.fond,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _type == 'out' ? AppColors.rouge : AppColors.bord),
                            ),
                            child: Text(
                              '📤 Sortie',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _type == 'out' ? AppColors.rouge : AppColors.gris,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Description *'),
                  _Input(controller: _descCtrl, hint: 'Ex: Paiement fournisseur papier A4'),
                  const SizedBox(height: 14),
                  const _FieldLabel('Montant (FCFA) *'),
                  _Input(controller: _amountCtrl, hint: '0', keyboardType: TextInputType.number),
                  const SizedBox(height: 14),
                  const _FieldLabel('Catégorie'),
                  _Input(controller: _categoryCtrl, hint: 'Ex: Fournitures, Loyer, Ventes...'),
                ],
              ),
            ),
            _DialogActions(onConfirm: _loading ? null : _submit, isLoading: _loading),
          ],
        ),
      ),
    );
  }
}



// ─── Widgets locaux ──────────────────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  final String title; final IconData icon; final String? actionLabel; final VoidCallback? onAction; final Widget? child;
  const _ScreenHeader({required this.title, required this.icon, this.actionLabel, this.onAction, this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(color: AppColors.blanc, border: Border(bottom: BorderSide(color: AppColors.bord))),
    child: Row(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.bleu.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: AppColors.bleu)),
      const SizedBox(width: 12),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.bleu)),
      const SizedBox(width: 20),
      if (child != null) Expanded(child: child!) else const Spacer(),
      if (actionLabel != null && onAction != null) ElevatedButton(onPressed: onAction, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0), child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
    ]),
  );
}

class _FilterChip extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: active ? AppColors.bleu : AppColors.fond, borderRadius: BorderRadius.circular(14), border: Border.all(color: active ? AppColors.bleu : AppColors.bord)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.gris)),
    )),
  );
}

class _DialogHeader extends StatelessWidget {
  final String title; final IconData icon;
  const _DialogHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: const BoxDecoration(color: AppColors.bleu, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
    child: Row(children: [
      Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 10),
      Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
      IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 16), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
    ]),
  );
}

class _ErrorBanner extends StatelessWidget {
  final String message; const _ErrorBanner(this.message);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(color: AppColors.rouge.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.rouge.withOpacity(0.3))),
    child: Text(message, style: const TextStyle(color: AppColors.rouge, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

class _FieldLabel extends StatelessWidget {
  final String label; const _FieldLabel(this.label);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)));
}

class _Input extends StatelessWidget {
  final TextEditingController controller; final String hint; final TextInputType? keyboardType; final int maxLines;
  const _Input({required this.controller, required this.hint, this.keyboardType, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, keyboardType: keyboardType, maxLines: maxLines,
    decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.gris, fontSize: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true),
    style: const TextStyle(fontSize: 13),
  );
}

class _DialogActions extends StatelessWidget {
  final VoidCallback? onConfirm; final String confirmLabel; final bool isLoading;
  const _DialogActions({this.onConfirm, this.confirmLabel = 'Enregistrer', this.isLoading = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: Row(children: [
      Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(foregroundColor: AppColors.gris, side: const BorderSide(color: AppColors.bord), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), child: const Text('Annuler'))),
      const SizedBox(width: 10),
      Expanded(flex: 2, child: ElevatedButton(onPressed: isLoading ? null : onConfirm, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w700)))),
    ]),
  );
}

class _DataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final List<Color>? rowColors;
  final bool highlightLastCol;
  const _DataTable({required this.headers, required this.rows, this.rowColors, this.highlightLastCol = false});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.blanc, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.bord)),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(color: Color(0xFFF8FAFC), border: Border(bottom: BorderSide(color: AppColors.bord)), borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        child: Row(children: headers.map((h) => Expanded(child: Text(h, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gris, letterSpacing: 0.5)))).toList()),
      ),
      Expanded(child: ListView.separated(
        itemCount: rows.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
        itemBuilder: (ctx, i) {
          final row = rows[i]; final color = rowColors?[i] ?? AppColors.texte;
          return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(children: row.asMap().entries.map((e) {
            final isLast = e.key == row.length - 1;
            return Expanded(child: Text(e.value, style: TextStyle(fontSize: 12, fontWeight: (highlightLastCol && isLast) ? FontWeight.w900 : FontWeight.w500, color: (highlightLastCol && isLast) ? color : AppColors.texte), overflow: TextOverflow.ellipsis));
          }).toList()));
        },
      )),
    ]),
  );
}
