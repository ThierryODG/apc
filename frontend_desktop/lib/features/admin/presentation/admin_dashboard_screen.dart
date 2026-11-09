import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _data = {};
  bool _loading = true; String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.adminDashboard);
      setState(() { _data = res; _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  String _fmt(dynamic v) {
    final n = (double.tryParse('$v') ?? 0).toInt();
    if (n >= 1000000) return '${n ~/ 1000000}M ${((n % 1000000) ~/ 1000).toString().padLeft(3,'0')} F';
    if (n >= 1000) return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3,'0')} F';
    return '$n F';
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _ScreenHeader(title: 'Tableau de Bord — Administrateur', icon: Icons.dashboard_rounded),
      Expanded(
        child: _loading ? const Center(child: CircularProgressIndicator())
            : _error != null ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
            : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Info exercice actif
                if (_data['active_fiscal_year'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: AppColors.bleu.withOpacity(0.07), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.bleu.withOpacity(0.2))),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.bleu),
                      const SizedBox(width: 10),
                      Text('Exercice actif : ', style: const TextStyle(fontSize: 12, color: AppColors.gris)),
                      Text(_data['active_fiscal_year']['name'] ?? '—', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.bleu)),
                      const SizedBox(width: 10),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.vert.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.vert.withOpacity(0.3))), child: const Text('ACTIF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.vert))),
                    ]),
                  ),

                // KPI Cards
                Row(children: [
                  _AdminKpiCard(icon: Icons.people_alt_rounded, label: 'Clients', value: '${_data['customers_count'] ?? 0}', color: AppColors.bleu),
                  const SizedBox(width: 14),
                  _AdminKpiCard(icon: Icons.receipt_long_rounded, label: 'Commandes totales', value: '${_data['orders_count'] ?? 0}', color: AppColors.orange),
                  const SizedBox(width: 14),
                  _AdminKpiCard(icon: Icons.attach_money_rounded, label: 'CA global', value: _fmt(_data['total_revenue']), color: AppColors.vert),
                  const SizedBox(width: 14),
                  _AdminKpiCard(icon: Icons.manage_accounts_rounded, label: 'Utilisateurs', value: '${_data['users_count'] ?? 0}', color: AppColors.gris),
                ]),
                const SizedBox(height: 24),

                // Dernières commandes
                const Text('DERNIÈRES COMMANDES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.bleu)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(color: AppColors.blanc, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.bord)),
                  child: ListView.separated(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    itemCount: (_data['recent_orders'] as List? ?? []).take(6).length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
                    itemBuilder: (ctx, i) {
                      final o = (_data['recent_orders'] as List)[i] as Map<String, dynamic>;
                      return ListTile(dense: true,
                        leading: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.receipt_rounded, size: 16, color: AppColors.orange)),
                        title: Text('Commande #${o['id']} — ${o['customer']?['name'] ?? 'Comptoir'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        subtitle: Text(o['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 10)),
                        trailing: Text(_fmt(o['total_amount']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.bleu)),
                      );
                    },
                  ),
                ),
              ])),
      ),
    ]);
  }
}

class _AdminKpiCard extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color color;
  const _AdminKpiCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.blanc, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.bord)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: color)),
      const SizedBox(height: 10),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gris, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
    ]),
  ));
}

// ─── Widget local ─────────────────────────────────────────────────────────────

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

