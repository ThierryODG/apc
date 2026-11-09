import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient().get(ApiEndpoints.secretaryOrders);
      final list = ApiClient.extractList(res, 'orders');
      setState(() {
        _orders = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_statusFilter == 'all') return _orders;
    return _orders.where((o) => o['status'] == _statusFilter).toList();
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'paid': return AppColors.vert;
      case 'pending': return AppColors.orange;
      case 'in_production': return AppColors.bleu2;
      case 'completed': return AppColors.bleu;
      case 'cancelled': return AppColors.rouge;
      default: return AppColors.gris;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'paid': return 'Payé';
      case 'pending': return 'En attente';
      case 'in_production': return 'En production';
      case 'completed': return 'Terminé';
      case 'cancelled': return 'Annulé';
      default: return status ?? '—';
    }
  }

  String _fmt(dynamic v) {
    final n = (double.tryParse('$v') ?? 0).toInt();
    if (n >= 1000) return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3, '0')} F';
    return '$n F';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ScreenHeader(
          title: 'Commandes',
          icon: Icons.receipt_long_rounded,
          child: Row(
            children: [
              for (final f in [
                ('all', 'Toutes'),
                ('pending', 'En attente'),
                ('in_production', 'Production'),
                ('paid', 'Payées'),
                ('completed', 'Terminées'),
              ])
                _FilterChip(
                  label: f.$2,
                  active: _statusFilter == f.$1,
                  onTap: () => setState(() => _statusFilter = f.$1),
                ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
                  : _filtered.isEmpty
                      ? const Center(child: Text('Aucune commande.', style: TextStyle(color: AppColors.gris)))
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
                                      Expanded(flex: 2, child: _ColHeader('N° CMD')),
                                      Expanded(flex: 3, child: _ColHeader('CLIENT')),
                                      Expanded(flex: 2, child: _ColHeader('DATE')),
                                      Expanded(flex: 2, child: _ColHeader('MONTANT')),
                                      Expanded(flex: 2, child: _ColHeader('STATUT')),
                                      Expanded(flex: 2, child: _ColHeader('PAIEMENT')),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: _filtered.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
                                    itemBuilder: (ctx, i) {
                                      final o = _filtered[i];
                                      final status = o['status'] as String?;
                                      final payStatus = o['payment_status'] as String?;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: Row(
                                          children: [
                                            Expanded(flex: 2, child: Text('#${o['id']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.bleu))),
                                            Expanded(flex: 3, child: Text(o['customer']?['name'] ?? 'Comptoir', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                            Expanded(flex: 2, child: Text(_shortDate(o['created_at']), style: const TextStyle(fontSize: 11, color: AppColors.gris))),
                                            Expanded(flex: 2, child: Text(_fmt(o['total_amount']), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                                            Expanded(flex: 2, child: _StatusBadge(label: _statusLabel(status), color: _statusColor(status))),
                                            Expanded(flex: 2, child: _StatusBadge(
                                              label: payStatus == 'paid' ? 'Payé' : payStatus == 'partial' ? 'Partiel' : 'Non payé',
                                              color: payStatus == 'paid' ? AppColors.vert : payStatus == 'partial' ? AppColors.orange : AppColors.rouge,
                                            )),
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

  String _shortDate(dynamic dt) {
    if (dt == null) return '—';
    try {
      final d = DateTime.parse(dt.toString());
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) { return dt.toString().substring(0, 10); }
  }
}



// ─── Widgets locaux ──────────────────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  final String title; final IconData icon; final String? actionLabel; final VoidCallback? onAction; final Widget? child;
  const _ScreenHeader({required this.title, required this.icon, this.actionLabel, this.onAction, this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
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
}

class _ColHeader extends StatelessWidget {
  final String label; const _ColHeader(this.label);
  @override Widget build(BuildContext context) => Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gris, letterSpacing: 0.5));
}

class _StatusBadge extends StatelessWidget {
  final String label; final Color color; const _StatusBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
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
