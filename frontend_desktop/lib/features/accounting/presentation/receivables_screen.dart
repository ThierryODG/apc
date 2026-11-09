import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class ReceivablesScreen extends StatefulWidget {
  const ReceivablesScreen({super.key});
  @override State<ReceivablesScreen> createState() => _ReceivablesScreenState();
}

class _ReceivablesScreenState extends State<ReceivablesScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true; String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient().get(ApiEndpoints.accountingReceivables);
      final List data = res['data'] ?? res['receivables'] ?? [];
      setState(() { _items = data.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  String _fmt(dynamic v) {
    final n = (double.tryParse('$v') ?? 0).toInt();
    if (n >= 1000) return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3, '0')} F';
    return '$n F';
  }

  double get _totalCreances => _items.fold(0, (s, i) => s + (double.tryParse('${i['remaining_amount'] ?? i['amount']}') ?? 0));

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _ScreenHeader(title: 'Créances Clients', icon: Icons.people_rounded),
      if (!_loading && _error == null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: const Color(0xFFF8FAFC),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.rouge),
            const SizedBox(width: 6),
            Text('Total créances : ', style: const TextStyle(fontSize: 11, color: AppColors.gris)),
            Text(_fmt(_totalCreances), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.rouge)),
            const SizedBox(width: 6),
            Text('(${_items.length} client(s) débiteur(s))', style: const TextStyle(fontSize: 11, color: AppColors.gris)),
          ]),
        ),
      Expanded(
        child: _loading ? const Center(child: CircularProgressIndicator())
            : _error != null ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
            : _items.isEmpty ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.vert),
                SizedBox(height: 8),
                Text('Aucune créance en cours !', style: TextStyle(color: AppColors.vert, fontSize: 14, fontWeight: FontWeight.w700)),
              ]))
            : Padding(padding: const EdgeInsets.all(16), child: Container(
              decoration: BoxDecoration(color: AppColors.blanc, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.bord)),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(color: Color(0xFFF8FAFC), border: Border(bottom: BorderSide(color: AppColors.bord)), borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
                  child: const Row(children: [
                    Expanded(flex: 3, child: _ColHeader('CLIENT')),
                    Expanded(flex: 2, child: _ColHeader('N° CMD')),
                    Expanded(flex: 2, child: _ColHeader('TOTAL CMD')),
                    Expanded(flex: 2, child: _ColHeader('PAYÉ')),
                    Expanded(flex: 2, child: _ColHeader('RESTE DÛ')),
                  ]),
                ),
                Expanded(child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
                  itemBuilder: (ctx, i) {
                    final item = _items[i];
                    final remaining = double.tryParse('${item['remaining_amount'] ?? 0}') ?? 0;
                    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(children: [
                      Expanded(flex: 3, child: Row(children: [
                        CircleAvatar(radius: 14, backgroundColor: AppColors.rouge.withOpacity(0.1), child: Text((item['customer']?['name'] ?? 'C').substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.rouge))),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item['customer']?['name'] ?? '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                      ])),
                      Expanded(flex: 2, child: Text('#${item['order_id'] ?? item['id']}', style: const TextStyle(fontSize: 12, color: AppColors.bleu, fontWeight: FontWeight.w700))),
                      Expanded(flex: 2, child: Text(_fmt(item['total_amount']), style: const TextStyle(fontSize: 12))),
                      Expanded(flex: 2, child: Text(_fmt(item['paid_amount']), style: const TextStyle(fontSize: 12, color: AppColors.vert, fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text(_fmt(remaining), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.rouge))),
                    ]));
                  },
                )),
              ]),
            )),
      ),
    ]);
  }
}

// ─── Widgets locaux ──────────────────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  final String title; final IconData icon; final String? actionLabel; final VoidCallback? onAction; final Widget? child;
  const _ScreenHeader({required this.title, required this.icon, this.actionLabel, this.onAction, this.child});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(color: AppColors.blanc, border: Border(bottom: BorderSide(color: AppColors.bord))),
    child: Row(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.bleu.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: AppColors.bleu)),
      const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.bleu)), const SizedBox(width: 20),
      if (child != null) Expanded(child: child!) else const Spacer(),
      if (actionLabel != null && onAction != null) ElevatedButton(onPressed: onAction, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0), child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
    ]),
  );
}

class _ColHeader extends StatelessWidget {
  final String label; const _ColHeader(this.label);
  @override Widget build(BuildContext context) => Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gris, letterSpacing: 0.5));
}

