import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Map<String, dynamic>> _expenses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient().get(ApiEndpoints.accountingExpenses);
      final List data = res['data'] ?? res['expenses'] ?? [];
      setState(() { _expenses = data.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  String _fmt(dynamic v) {
    final n = (double.tryParse('$v') ?? 0).toInt();
    if (n >= 1000) return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3, '0')} F';
    return '$n F';
  }

  String _shortDate(dynamic dt) {
    if (dt == null) return '—';
    try { final d = DateTime.parse(dt.toString()); return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}'; }
    catch (_) { return dt.toString().substring(0, 10); }
  }

  double get _total => _expenses.fold(0, (s, e) => s + (double.tryParse('${e['amount']}') ?? 0));

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _ScreenHeader(title: 'Dépenses d\'exploitation', icon: Icons.money_off_rounded, actionLabel: '+ Nouvelle dépense', onAction: () => _openCreate()),
      if (!_loading && _error == null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: const Color(0xFFF8FAFC),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.rouge),
            const SizedBox(width: 6),
            Text('Total dépenses : ', style: const TextStyle(fontSize: 11, color: AppColors.gris)),
            Text(_fmt(_total), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.rouge)),
            const SizedBox(width: 6),
            Text('sur ${_expenses.length} entrée(s)', style: const TextStyle(fontSize: 11, color: AppColors.gris)),
          ]),
        ),
      Expanded(
        child: _loading ? const Center(child: CircularProgressIndicator())
            : _error != null ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
            : _expenses.isEmpty ? const Center(child: Text('Aucune dépense enregistrée.', style: TextStyle(color: AppColors.gris)))
            : Padding(padding: const EdgeInsets.all(16), child: Container(
              decoration: BoxDecoration(color: AppColors.blanc, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.bord)),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(color: Color(0xFFF8FAFC), border: Border(bottom: BorderSide(color: AppColors.bord)), borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
                  child: const Row(children: [
                    Expanded(flex: 2, child: _ColHeader('DATE')),
                    Expanded(flex: 3, child: _ColHeader('DESCRIPTION')),
                    Expanded(flex: 2, child: _ColHeader('CATÉGORIE')),
                    Expanded(flex: 2, child: _ColHeader('MONTANT')),
                  ]),
                ),
                Expanded(child: ListView.separated(
                  itemCount: _expenses.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
                  itemBuilder: (ctx, i) {
                    final e = _expenses[i];
                    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(children: [
                      Expanded(flex: 2, child: Text(_shortDate(e['date']), style: const TextStyle(fontSize: 11, color: AppColors.gris))),
                      Expanded(flex: 3, child: Text(e['description'] ?? '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                      Expanded(flex: 2, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(e['category'] ?? 'Général', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.orange)),
                      )),
                      Expanded(flex: 2, child: Text(_fmt(e['amount']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.rouge))),
                    ]));
                  },
                )),
              ]),
            )),
      ),
    ]);
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
  final _categoryCtrl = TextEditingController();
  bool _loading = false; String? _error;

  Future<void> _submit() async {
    if (_descCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) { setState(() => _error = 'Description et montant obligatoires.'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiClient().post(ApiEndpoints.accountingExpenses, {
        'description': _descCtrl.text.trim(), 'amount': double.tryParse(_amountCtrl.text.trim()) ?? 0,
        'category': _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
        'date': DateTime.now().toIso8601String().substring(0, 10),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: SizedBox(width: 380, child: Column(mainAxisSize: MainAxisSize.min, children: [
      _DialogHeader(title: 'Nouvelle Dépense', icon: Icons.money_off_rounded),
      Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_error != null) _ErrorBanner(_error!),
        const _FieldLabel('Description *'), _Input(controller: _descCtrl, hint: 'Ex: Achat papier A4'),
        const SizedBox(height: 14),
        const _FieldLabel('Montant (FCFA) *'), _Input(controller: _amountCtrl, hint: '0', keyboardType: TextInputType.number),
        const SizedBox(height: 14),
        const _FieldLabel('Catégorie'), _Input(controller: _categoryCtrl, hint: 'Ex: Fournitures, Loyer, Salaires...'),
      ])),
      _DialogActions(onConfirm: _loading ? null : _submit, isLoading: _loading),
    ])),
  );
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

class _ColHeader extends StatelessWidget {
  final String label; const _ColHeader(this.label);
  @override Widget build(BuildContext context) => Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gris, letterSpacing: 0.5));
}

class _DialogHeader extends StatelessWidget {
  final String title; final IconData icon;
  const _DialogHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: const BoxDecoration(color: AppColors.bleu, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
    child: Row(children: [Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))), IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 16), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints())]),
  );
}

class _ErrorBanner extends StatelessWidget {
  final String message; const _ErrorBanner(this.message);
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: AppColors.rouge.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.rouge.withOpacity(0.3))), child: Text(message, style: const TextStyle(color: AppColors.rouge, fontSize: 12, fontWeight: FontWeight.w600)));
}

class _FieldLabel extends StatelessWidget {
  final String label; const _FieldLabel(this.label);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)));
}

class _Input extends StatelessWidget {
  final TextEditingController controller; final String hint; final TextInputType? keyboardType; final int maxLines;
  const _Input({required this.controller, required this.hint, this.keyboardType, this.maxLines = 1});
  @override Widget build(BuildContext context) => TextField(controller: controller, keyboardType: keyboardType, maxLines: maxLines, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.gris, fontSize: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true), style: const TextStyle(fontSize: 13));
}

class _DialogActions extends StatelessWidget {
  final VoidCallback? onConfirm; final String confirmLabel; final bool isLoading;
  const _DialogActions({this.onConfirm, this.confirmLabel = 'Enregistrer', this.isLoading = false});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: Row(children: [
    Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(foregroundColor: AppColors.gris, side: const BorderSide(color: AppColors.bord), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), child: const Text('Annuler'))),
    const SizedBox(width: 10),
    Expanded(flex: 2, child: ElevatedButton(onPressed: isLoading ? null : onConfirm, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w700)))),
  ]));
}

