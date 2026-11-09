import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/state/auth_state.dart';

/// Élément de navigation dans la sidebar
class NavItem {
  final IconData icon;
  final String label;
  final String route;

  const NavItem({required this.icon, required this.label, required this.route});
}

/// Sidebar gauche 220px — spécifique au rôle connecté
class AppSidebar extends StatelessWidget {
  final String selectedRoute;
  final Function(String route) onRouteChanged;

  const AppSidebar({
    super.key,
    required this.selectedRoute,
    required this.onRouteChanged,
  });

  List<NavItem> _itemsForRole(String role) {
    switch (role) {
      case 'secretary':
        return const [
          NavItem(icon: Icons.point_of_sale_rounded, label: 'Caisse (POS)', route: 'secretary.pos'),
          NavItem(icon: Icons.receipt_long_rounded, label: 'Commandes', route: 'secretary.orders'),
          NavItem(icon: Icons.people_alt_rounded, label: 'Clients', route: 'secretary.customers'),
          NavItem(icon: Icons.request_quote_rounded, label: 'Devis / Demandes', route: 'secretary.inquiries'),
        ];
      case 'accounting':
        return const [
          NavItem(icon: Icons.dashboard_rounded, label: 'Tableau de bord', route: 'accounting.dashboard'),
          NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Trésorerie', route: 'accounting.cashflows'),
          NavItem(icon: Icons.money_off_rounded, label: 'Dépenses', route: 'accounting.expenses'),
          NavItem(icon: Icons.people_rounded, label: 'Créances clients', route: 'accounting.receivables'),
          NavItem(icon: Icons.lock_clock_rounded, label: 'Clôture de caisse', route: 'accounting.daily_register'),
        ];
      case 'admin':
        return const [
          NavItem(icon: Icons.dashboard_rounded, label: 'Tableau de bord', route: 'admin.dashboard'),
          NavItem(icon: Icons.business_rounded, label: 'Entreprise', route: 'admin.company'),
          NavItem(icon: Icons.calendar_month_rounded, label: 'Exercices fiscaux', route: 'admin.fiscal_years'),
          NavItem(icon: Icons.manage_accounts_rounded, label: 'Utilisateurs', route: 'admin.users'),
          // Admin peut aussi accéder au POS et à la comptabilité
          NavItem(icon: Icons.point_of_sale_rounded, label: 'Caisse (POS)', route: 'secretary.pos'),
          NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Trésorerie', route: 'accounting.cashflows'),
        ];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthState();
    final role = auth.currentUser?.role ?? 'secretary';
    final items = _itemsForRole(role);
    final company = auth.company;
    final fiscalYear = auth.activeFiscalYear;

    return Container(
      width: 220,
      color: AppColors.bleu,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête : Logo + Marque ──────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x33FFFFFF))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.print_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AFRICA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            height: 1,
                          ),
                        ),
                        Text(
                          'PRINT',
                          style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (company != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    company.name,
                    style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 10, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // ── Menu de navigation ───────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: items.map((item) => _NavTile(
                item: item,
                isSelected: selectedRoute == item.route,
                onTap: () => onRouteChanged(item.route),
              )).toList(),
            ),
          ),

          // ── Pied de page : Exercice + Utilisateur ───────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fiscalYear != null)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xAAFFFFFF)),
                      const SizedBox(width: 5),
                      Text(
                        fiscalYear.name,
                        style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        (auth.currentUser?.name ?? 'U').substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.currentUser?.name ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _roleLabel(role),
                            style: const TextStyle(color: AppColors.orange, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, size: 16, color: Color(0xAAFFFFFF)),
                      tooltip: 'Déconnexion',
                      onPressed: () => auth.logout(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrateur';
      case 'secretary':
        return 'Secrétariat';
      case 'accounting':
        return 'Comptabilité';
      default:
        return role;
    }
  }
}

class _NavTile extends StatefulWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({required this.item, required this.isSelected, required this.onTap});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: active
                ? AppColors.orange.withOpacity(0.18)
                : _hovered
                    ? Colors.white.withOpacity(0.07)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                color: active ? AppColors.orange : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 17,
                color: active ? AppColors.orange : const Color(0xCCFFFFFF),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : const Color(0xCCFFFFFF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

