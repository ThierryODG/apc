import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class AccountingDashboardScreen extends StatefulWidget {
  const AccountingDashboardScreen({super.key});

  @override
  State<AccountingDashboardScreen> createState() => _AccountingDashboardScreenState();
}

class _AccountingDashboardScreenState extends State<AccountingDashboardScreen> {
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
      final res = await ApiClient().get(ApiEndpoints.accountingDashboard);
      setState(() { _data = res; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _fmt(dynamic v) {
    final n = (double.tryParse('$v') ?? 0).toInt();
    if (n >= 1000000) return '${(n ~/ 1000000)}M ${((n % 1000000) ~/ 1000).toString().padLeft(3, '0')} F';
    if (n >= 1000) return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3, '0')} F';
    return '$n F';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScreenHeader(title: 'Tableau de bord — Comptabilité & Trésorerie', icon: Icons.analytics_outlined),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          Expanded(child: Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge))))
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 4 Cartes Financement ───────────────────────────
                  Row(
                    children: [
                      _AccKpiCard(
                        icon: Icons.trending_up_rounded,
                        label: 'Total Entrées Caisse',
                        value: _fmt(_data['monthly_income']),
                        color: AppColors.vert,
                        subtitle: 'Période en cours',
                      ),
                      const SizedBox(width: 14),
                      _AccKpiCard(
                        icon: Icons.trending_down_rounded,
                        label: 'Total Sorties / Dépenses',
                        value: _fmt(_data['monthly_expenses']),
                        color: AppColors.rouge,
                        subtitle: 'Achats & charges',
                      ),
                      const SizedBox(width: 14),
                      _AccKpiCard(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Solde Net en Caisse',
                        value: _fmt(_data['net_balance']),
                        color: AppColors.bleu,
                        subtitle: 'Disponible théorique',
                      ),
                      const SizedBox(width: 14),
                      _AccKpiCard(
                        icon: Icons.pending_actions_rounded,
                        label: 'Créances Clients à Recouvrer',
                        value: _fmt(_data['total_receivables']),
                        color: AppColors.orange,
                        subtitle: 'Reste dû sur commandes',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Comparatif Graphique Recettes vs Dépenses ────────
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
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RATIO TRÉSORERIE : REVIENT VS SORTIES',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.bleu, letterSpacing: 0.5),
                                ),
                                SizedBox(height: 2),
                                Text('Performance d\'exploitation de l\'imprimerie', style: TextStyle(fontSize: 11, color: AppColors.gris)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.circle, size: 10, color: AppColors.vert),
                                          SizedBox(width: 6),
                                          Text('Encaissements', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                      Text(_fmt(_data['monthly_income']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.vert)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: const LinearProgressIndicator(
                                      value: 0.78,
                                      minHeight: 12,
                                      backgroundColor: AppColors.fond,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.vert),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.circle, size: 10, color: AppColors.rouge),
                                          SizedBox(width: 6),
                                          Text('Décaissements', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                      Text(_fmt(_data['monthly_expenses']), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.rouge)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: const LinearProgressIndicator(
                                      value: 0.28,
                                      minHeight: 12,
                                      backgroundColor: AppColors.fond,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.rouge),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Derniers flux de trésorerie ─────────────────────
                  const Text(
                    'HISTORIQUE RÉCENT DES MOUVEMENTS DE CAISSE',
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
                      itemCount: (_data['recent_movements'] as List? ?? []).take(6).length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
                      itemBuilder: (ctx, i) {
                        final m = (_data['recent_movements'] as List)[i] as Map<String, dynamic>;
                        final isIn = m['type'] == 'in';
                        return ListTile(
                          dense: true,
                          leading: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: (isIn ? AppColors.vert : AppColors.rouge).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              size: 16,
                              color: isIn ? AppColors.vert : AppColors.rouge,
                            ),
                          ),
                          title: Text(m['description'] ?? 'Mouvement sans libellé', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          subtitle: Text(m['date'] ?? '', style: const TextStyle(fontSize: 11, color: AppColors.gris)),
                          trailing: Text(
                            '${isIn ? '+' : '-'} ${_fmt(m['amount'])}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isIn ? AppColors.vert : AppColors.rouge,
                            ),
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

class _AccKpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String subtitle;

  const _AccKpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gris, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.gris)),
          ],
        ),
      ),
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
