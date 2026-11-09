import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PosTiles extends StatelessWidget {
  final VoidCallback onNewOrder;
  final VoidCallback onCheckout;
  final VoidCallback onNewCustomer;
  final VoidCallback onDailyReport;

  const PosTiles({
    super.key,
    required this.onNewOrder,
    required this.onCheckout,
    required this.onNewCustomer,
    required this.onDailyReport,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _TileItem(
                icon: Icons.add_circle_outline,
                title: 'Nouvelle commande',
                isHot: true,
                onTap: onNewOrder,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TileItem(
                icon: Icons.print_outlined,
                title: 'Lancer prod.',
                onTap: onNewOrder,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TileItem(
                icon: Icons.receipt_long_outlined,
                title: 'Encaisser',
                onTap: onCheckout,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TileItem(
                icon: Icons.inventory_2_outlined,
                title: 'Entrée stock',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TileItem(
                icon: Icons.person_add_alt_1_outlined,
                title: 'Nouveau client',
                onTap: onNewCustomer,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TileItem(
                icon: Icons.analytics_outlined,
                title: 'Rapport jour',
                onTap: onDailyReport,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isHot;
  final VoidCallback onTap;

  const _TileItem({
    required this.icon,
    required this.title,
    this.isHot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.bord),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: isHot ? AppColors.orange : AppColors.bleu2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(icon, size: 22, color: isHot ? AppColors.orange2 : AppColors.bleu),
            const SizedBox(height: 6),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: isHot ? AppColors.orange2 : AppColors.bleu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

