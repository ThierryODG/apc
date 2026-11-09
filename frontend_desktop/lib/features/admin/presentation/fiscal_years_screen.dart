import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class FiscalYearsScreen extends StatefulWidget {
  const FiscalYearsScreen({super.key});
  @override State<FiscalYearsScreen> createState() => _FiscalYearsScreenState();
}

class _FiscalYearsScreenState extends State<FiscalYearsScreen> {
  List<Map<String, dynamic>> _years = [];
  bool _loading = true; String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient().get(ApiEndpoints.adminFiscalYears);
      final List data = res['data'] ?? res['fiscal_years'] ?? [];
      setState(() { _years = data.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  Future<void> _openCreate() async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => const _CreateFiscalYearDialog());
    if (ok == true) _load();
  }

  Future<void> _activate(int id) async {
    try {
      await ApiClient().patch('${ApiEndpoints.adminFiscalYears}/$id/activate');
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.rouge));
    }
  }

  Future<void> _close(int id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Clôturer l\'exercice ?', style: TextStyle(fontWeight: FontWeight.w900)),
      content: const Text('Cette action fermera définitivement l\'exercice. Les données seront archivées.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.rouge), child: const Text('Clôturer', style: TextStyle(color: Colors.white)))],
    ));
    if (confirm != true) return;
    try {
      await ApiClient().patch('${ApiEndpoints.adminFiscalYears}/$id/close');
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.rouge));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _ScreenHeader(title: 'Exercices Fiscaux', icon: Icons.calendar_month_rounded, actionLabel: '+ Nouvel exercice', onAction: _openCreate),
      Expanded(
        child: _loading ? const Center(child: CircularProgressIndicator())
            : _error != null ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
            : _years.isEmpty ? const Center(child: Text('Aucun exercice fiscal.', style: TextStyle(color: AppColors.gris)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _years.length,
                itemBuilder: (ctx, i) {
                  final y = _years[i];
                  final isActive = y['status'] == 'active';
                  final isClosed = y['status'] == 'closed';
                  return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                    Container(width: 42, height: 42, decoration: BoxDecoration(color: isActive ? AppColors.vert.withOpacity(0.1) : AppColors.fond, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.calendar_month_rounded, size: 20, color: isActive ? AppColors.vert : AppColors.gris)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(y['name'] ?? '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                      Text('${y['start_date'] ?? ''} → ${y['end_date'] ?? ''}', style: const TextStyle(fontSize: 11, color: AppColors.gris)),
                    ])),
                    const SizedBox(width: 10),
                    if (isActive)
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.vert.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.vert.withOpacity(0.3))), child: const Text('ACTIF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.vert)))
                    else if (isClosed)
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.gris.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gris.withOpacity(0.3))), child: const Text('CLÔTURÉ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gris)))
                    else
                      TextButton(onPressed: () => _activate(y['id']), child: const Text('Activer', style: TextStyle(fontSize: 11, color: AppColors.bleu, fontWeight: FontWeight.w700))),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(onPressed: () => _close(y['id']), style: OutlinedButton.styleFrom(foregroundColor: AppColors.rouge, side: const BorderSide(color: AppColors.rouge), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)), child: const Text('Clôturer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                    ],
                  ])));
                },
              ),
      ),
    ]);
  }
}

class _CreateFiscalYearDialog extends StatefulWidget {
  const _CreateFiscalYearDialog();
  @override State<_CreateFiscalYearDialog> createState() => _CreateFiscalYearDialogState();
}

class _CreateFiscalYearDialogState extends State<_CreateFiscalYearDialog> {
  final _nameCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  bool _loading = false; String? _error;

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) { setState(() => _error = 'Nom obligatoire.'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiClient().post(ApiEndpoints.adminFiscalYears, {
        'name': _nameCtrl.text.trim(), 'start_date': _startCtrl.text.trim(), 'end_date': _endCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: SizedBox(width: 380, child: Column(mainAxisSize: MainAxisSize.min, children: [
      _DialogHeader(title: 'Nouvel Exercice Fiscal', icon: Icons.calendar_month_rounded),
      Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_error != null) _ErrorBanner(_error!),
        const _FieldLabel('Nom de l\'exercice *'), _Input(controller: _nameCtrl, hint: 'Ex: Exercice 2025-2026'),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _FieldLabel('Date début'), _Input(controller: _startCtrl, hint: '2025-01-01')])),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _FieldLabel('Date fin'), _Input(controller: _endCtrl, hint: '2025-12-31')])),
        ]),
      ])),
      _DialogActions(onConfirm: _loading ? null : _submit, isLoading: _loading),
    ])),
  );
}

// ─── Widgets locaux ──────────────────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  final String title; final IconData icon; final String? actionLabel; final VoidCallback? onAction; final Widget? child;
  const _ScreenHeader({required this.title, required this.icon, this.actionLabel, this.onAction, this.child});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), decoration: const BoxDecoration(color: AppColors.blanc, border: Border(bottom: BorderSide(color: AppColors.bord))), child: Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.bleu.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: AppColors.bleu)), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.bleu)), const SizedBox(width: 20), if (child != null) Expanded(child: child!) else const Spacer(), if (actionLabel != null && onAction != null) ElevatedButton(onPressed: onAction, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0), child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))]));
}

class _DialogHeader extends StatelessWidget {
  final String title; final IconData icon;
  const _DialogHeader({required this.title, required this.icon});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: const BoxDecoration(color: AppColors.bleu, borderRadius: BorderRadius.vertical(top: Radius.circular(10))), child: Row(children: [Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))), IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 16), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints())]));
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
  final TextEditingController controller; final String hint; final int maxLines;
  const _Input({required this.controller, required this.hint, this.maxLines = 1});
  @override Widget build(BuildContext context) => TextField(controller: controller, maxLines: maxLines, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.gris, fontSize: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true), style: const TextStyle(fontSize: 13));
}

class _DialogActions extends StatelessWidget {
  final VoidCallback? onConfirm; final String confirmLabel; final bool isLoading;
  const _DialogActions({this.onConfirm, this.confirmLabel = 'Enregistrer', this.isLoading = false});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: Row(children: [Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(foregroundColor: AppColors.gris, side: const BorderSide(color: AppColors.bord), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), child: const Text('Annuler'))), const SizedBox(width: 10), Expanded(flex: 2, child: ElevatedButton(onPressed: isLoading ? null : onConfirm, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w700))))]));
}

