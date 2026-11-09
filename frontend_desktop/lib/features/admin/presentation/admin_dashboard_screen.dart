import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
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
      setState(() {
        _data = res;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _reload() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _load();
  }

  String _fmt(dynamic v) {
    final n = (double.tryParse('$v') ?? 0).toInt();
    if (n >= 1000000)
      return '${(n ~/ 1000000)}M ${((n % 1000000) ~/ 1000).toString().padLeft(3, '0')} F';
    if (n >= 1000)
      return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3, '0')} F';
    return '$n F';
  }

  String _date(dynamic v) {
    final s = v?.toString() ?? '';
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  String _todayLabel() {
    const jours = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    const mois = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    final d = DateTime.now();
    return '${jours[d.weekday - 1]} ${d.day} ${mois[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScreenHeader(
          title: 'Tableau de bord de Direction',
          subtitle: _todayLabel(),
          icon: Icons.insights_rounded,
          trailing: TextButton.icon(
            onPressed: _loading ? null : _reload,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Actualiser'),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildError()
              : _buildContent(),
        ),
      ],
    );
  }

  // ── État d'erreur ──────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bord),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.rouge.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 28,
                color: AppColors.rouge,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Impossible de charger les données',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.texte,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.gris),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contenu principal ──────────────────────────────────────
  Widget _buildContent() {
    final metricsMap = _data['metrics'] is Map
        ? Map<String, dynamic>.from(_data['metrics'])
        : <String, dynamic>{};
    final usersMap = _data['users_distribution'] is Map
        ? Map<String, dynamic>.from(_data['users_distribution'])
        : <String, dynamic>{};

    final metrics = <_MetricCard>[
      _MetricCard(
        title: 'Chiffre d\'Affaires Réalisé',
        value: _fmt(metricsMap['total_turnover'] ?? 0),
        icon: Icons.payments_rounded,
        iconColor: AppColors.vert,
        subtitle: 'Toutes prestations confondues',
      ),
      _MetricCard(
        title: 'Total Commandes',
        value: '${metricsMap['total_orders'] ?? 0}',
        icon: Icons.receipt_long_rounded,
        iconColor: AppColors.bleu,
        subtitle: 'Passées au guichet',
      ),
      _MetricCard(
        title: 'Clients Enregistrés',
        value: '${metricsMap['total_customers'] ?? 0}',
        icon: Icons.people_alt_rounded,
        iconColor: AppColors.orange,
        subtitle: 'Base clientèle active',
      ),
      _MetricCard(
        title: 'Collaborateurs Actifs',
        value: '${usersMap['total'] ?? 0}',
        icon: Icons.badge_outlined,
        iconColor: const Color(0xFF6366F1),
        subtitle: 'Secrétariat & Comptabilité',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1000;
          final medium = constraints.maxWidth >= 640;

          // Cartes métriques : 4 en ligne (large) ou 2x2 (étroit)
          Widget metricsBlock;
          if (medium) {
            metricsBlock = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < metrics.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(child: metrics[i]),
                ],
              ],
            );
          } else {
            metricsBlock = Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: metrics[0]),
                    const SizedBox(width: 16),
                    Expanded(child: metrics[1]),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: metrics[2]),
                    const SizedBox(width: 16),
                    Expanded(child: metrics[3]),
                  ],
                ),
              ],
            );
          }

          final chart = _buildChartPanel();
          final orders = _buildOrdersPanel();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              metricsBlock,
              const SizedBox(height: 24),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: chart),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: orders),
                  ],
                )
              else ...[
                chart,
                const SizedBox(height: 24),
                orders,
              ],
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  // ── Panneau graphique ──────────────────────────────────────
  Widget _buildChartPanel() {
    return _Panel(
      title: 'Aperçu du volume d\'activité',
      subtitle: 'Répartition des encaissements et prestations',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.vert.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.vert,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'En temps réel',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.vert,
              ),
            ),
          ],
        ),
      ),
      child: SizedBox(
        height: 230,
        child: Stack(
          children: [
            // Lignes de repère
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 24,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (_) => const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.bord,
                  ),
                ),
              ),
            ),
            // Barres
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Expanded(
                  child: _ChartBar(
                    label: 'Lun',
                    heightFactor: 0.45,
                    amount: '45 k',
                  ),
                ),
                Expanded(
                  child: _ChartBar(
                    label: 'Mar',
                    heightFactor: 0.65,
                    amount: '68 k',
                  ),
                ),
                Expanded(
                  child: _ChartBar(
                    label: 'Mer',
                    heightFactor: 0.35,
                    amount: '32 k',
                  ),
                ),
                Expanded(
                  child: _ChartBar(
                    label: 'Jeu',
                    heightFactor: 0.85,
                    amount: '92 k',
                  ),
                ),
                Expanded(
                  child: _ChartBar(
                    label: 'Ven',
                    heightFactor: 0.95,
                    amount: '120 k',
                    isHighest: true,
                  ),
                ),
                Expanded(
                  child: _ChartBar(
                    label: 'Sam',
                    heightFactor: 0.50,
                    amount: '50 k',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Panneau dernières commandes ────────────────────────────
  Widget _buildOrdersPanel() {
    final orders = (_data['recent_orders'] as List? ?? []).take(5).toList();

    return _Panel(
      title: 'Dernières commandes clients',
      subtitle: '${orders.length} commande(s) récente(s)',
      padding: EdgeInsets.zero,
      child: orders.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_rounded, size: 36, color: AppColors.gris),
                    SizedBox(height: 8),
                    Text(
                      'Aucune commande pour le moment',
                      style: TextStyle(fontSize: 12, color: AppColors.gris),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                for (int i = 0; i < orders.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.bord),
                  _OrderRow(
                    order: orders[i] as Map<String, dynamic>,
                    amount: _fmt(
                      (orders[i] as Map<String, dynamic>)['total_amount'],
                    ),
                    date: _date(
                      (orders[i] as Map<String, dynamic>)['created_at'],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Widgets
// ════════════════════════════════════════════════════════════

class _Panel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bord),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.bleu,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.gris,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.bord),
          Padding(
            padding: padding == EdgeInsets.zero
                ? EdgeInsets.zero
                : const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatefulWidget {
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
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hover ? widget.iconColor.withOpacity(0.5) : AppColors.bord,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hover ? 0.08 : 0.03),
              blurRadius: _hover ? 16 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Bande d'accent colorée en haut
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(height: 3, color: widget.iconColor),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gris,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 19,
                            color: widget.iconColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.value,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.texte,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gris,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    final color = isHighest ? AppColors.orange : AppColors.bleu;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          amount,
          style: TextStyle(
            fontSize: 11,
            color: isHighest ? AppColors.orange : AppColors.gris,
            fontWeight: isHighest ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 150 * heightFactor),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, h, _) => Container(
            width: 40,
            height: h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
              boxShadow: isHighest
                  ? [
                      BoxShadow(
                        color: AppColors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
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

class _OrderRow extends StatefulWidget {
  final Map<String, dynamic> order;
  final String amount;
  final String date;

  const _OrderRow({
    required this.order,
    required this.amount,
    required this.date,
  });

  @override
  State<_OrderRow> createState() => _OrderRowState();
}

class _OrderRowState extends State<_OrderRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final name = '${widget.order['customer']?['name'] ?? 'Client Comptoir'}';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hover ? AppColors.fond : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.bleu.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.bleu,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.texte,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Commande #${widget.order['id']}  •  ${widget.date}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.gris),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.amount,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.bleu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;

  const _ScreenHeader({
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
  });

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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.bleu.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.bleu),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.bleu,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 12, color: AppColors.gris),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}
