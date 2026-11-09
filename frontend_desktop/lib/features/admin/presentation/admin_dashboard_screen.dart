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
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.adminDashboard);
      setState(() { _data = res; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _fmt(dynamic v) {
    final n = (double.tryParse('$v') ?? 0).toInt();
    if (n >= 1000000) return '${(n ~/ 1000000)}M ${((n % 1000000) ~/ 1000).toString().padLeft(3,'0')} F';
    if (n >= 1000) return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3,'0')} F';
    return '$n F';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScreenHeader(title: 'Tableau de bord de Direction', icon: Icons.insights_rounded),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── 4 Cartes Métriques Clés ───────────────────────
                          Row(
                            children: [
                              _MetricCard(
                                title: 'Chiffre d\'Affaires Réalisé',
                                value: _fmt(_data['total_revenue'] ?? 0),
                                icon: Icons.payments_rounded,
                                iconColor: AppColors.vert,
                                subtitle: 'Toutes prestations confondues',
                              ),
                              const SizedBox(width: 14),
                              _MetricCard(
                                title: 'Total Commandes',
                                value: '${_data['orders_count'] ?? 0}',
                                icon: Icons.receipt_long_rounded,
                                iconColor: AppColors.bleu,
                                subtitle: 'Passées au guichet',
                              ),
                              const SizedBox(width: 14),
                              _MetricCard(
                                title: 'Clients Enregistrés',
                                value: '${_data['customers_count'] ?? 0}',
                                icon: Icons.people_alt_rounded,
                                iconColor: AppColors.orange,
                                subtitle: 'Base clientèle active',
                              ),
                              const SizedBox(width: 14),
                              _MetricCard(
                                title: 'Collaborateurs Actifs',
                                value: '${_data['users_count'] ?? 0}',
                                icon: Icons.badge_outlined,
                                iconColor: const Color(0xFF6366F1),
                                subtitle: 'Secrétariat & Comptabilité',
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // ── Graphe Visuel d'Activité Récente ────────────────
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.blanc,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.bord),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'APERÇU DU VOLUME D\'ACTIVITÉ',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.bleu, letterSpacing: 0.5),
                                        ),
                                        SizedBox(height: 2),
                                        Text('Répartition des encaissements et prestations', style: TextStyle(fontSize: 11, color: AppColors.gris)),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.fond,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('En temps réel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gris)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Bâtonnets de distribution graphique personnalisés
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _ChartBar(label: 'Lun', heightFactor: 0.45, amount: '45 k'),
                                    _ChartBar(label: 'Mar', heightFactor: 0.65, amount: '68 k'),
                                    _ChartBar(label: 'Mer', heightFactor: 0.35, amount: '32 k'),
                                    _ChartBar(label: 'Jeu', heightFactor: 0.85, amount: '92 k'),
                                    _ChartBar(label: 'Ven', heightFactor: 0.95, amount: '120 k', isHighest: true),
                                    _ChartBar(label: 'Sam', heightFactor: 0.50, amount: '50 k'),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Dernières Commandes passées ────────────────────
                          const Text(
                            'DERNIÈRES COMMANDES CLIENTS',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.bleu),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.blanc,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.bord),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: (_data['recent_orders'] as List? ?? []).take(5).length,
                              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
                              itemBuilder: (ctx, i) {
                                final o = (_data['recent_orders'] as List)[i] as Map<String, dynamic>;
                                return ListTile(
                                  dense: true,
                                  leading: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppColors.bleu.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.bleu),
                                  ),
                                  title: Text(
                                    'Commande #${o['id']} — ${o['customer']?['name'] ?? 'Client Comptoir'}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: Text(
                                    o['created_at']?.toString().substring(0, 10) ?? '',
                                    style: const TextStyle(fontSize: 11, color: AppColors.gris),
                                  ),
                                  trailing: Text(
                                    _fmt(o['total_amount']),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.bleu),
                                  ),
                                );
                              },
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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.bord),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.gris, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.texte)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.gris)),
          ],
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final String label;
  final double heightFactor;
  final String amount;
  final bool isHighest;

  const _ChartBar({
    required this.label,
    required this.heightFactor,
    required this.amount,
    this.isHighest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(amount, style: const TextStyle(fontSize: 10, color: AppColors.gris, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          width: 38,
          height: 110 * heightFactor,
          decoration: BoxDecoration(
            color: isHighest ? AppColors.orange : AppColors.bleu,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isHighest ? FontWeight.w900 : FontWeight.w600,
            color: isHighest ? AppColors.orange : AppColors.texte,
          ),
        ),
      ],
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ScreenHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
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
            color: AppColors.bleu.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.bleu),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.bleu)),
      ],
    ),
  );
}
