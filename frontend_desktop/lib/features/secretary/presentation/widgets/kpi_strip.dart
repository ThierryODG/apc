import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Bande KPI en bas du POS — 4 indicateurs clé du jour
class KpiStrip extends StatelessWidget {
  final int ventesCount;
  final double caDuJour;
  final int enProduction;
  final double creances;
  final bool isLoading;

  const KpiStrip({
    super.key,
    required this.ventesCount,
    required this.caDuJour,
    required this.enProduction,
    required this.creances,
    this.isLoading = false,
  });

  String _fmt(double v) {
    final n = v.toInt();
    if (n >= 1000000) {
      return '${(n ~/ 1000000)}M ${((n % 1000000) ~/ 1000)} F';
    }
    if (n >= 1000) {
      return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3, '0')} F';
    }
    return '$n F';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.blanc,
        border: Border(top: BorderSide(color: AppColors.bord)),
      ),
      child: Row(
        children: [
          _KpiCard(
            icon: Icons.shopping_cart_checkout_rounded,
            label: 'Ventes du jour',
            value: isLoading ? '...' : '$ventesCount',
            color: AppColors.bleu,
          ),
          _Divider(),
          _KpiCard(
            icon: Icons.attach_money_rounded,
            label: 'CA du jour',
            value: isLoading ? '...' : _fmt(caDuJour),
            color: AppColors.vert,
          ),
          _Divider(),
          _KpiCard(
            icon: Icons.print_rounded,
            label: 'En production',
            value: isLoading ? '...' : '$enProduction',
            color: AppColors.orange,
          ),
          _Divider(),
          _KpiCard(
            icon: Icons.warning_amber_rounded,
            label: 'Créances',
            value: isLoading ? '...' : _fmt(creances),
            color: AppColors.rouge,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const VerticalDivider(width: 1, color: AppColors.bord);
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: AppColors.gris, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

