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

/// Sidebar moderne 230px avec le vrai logo de la marque
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
          NavItem(icon: Icons.analytics_outlined, label: 'Tableau de bord', route: 'accounting.dashboard'),
          NavItem(icon: Icons.account_balance_wallet_rounded, label: 'Journal Trésorerie', route: 'accounting.cashflows'),
          NavItem(icon: Icons.receipt_outlined, label: 'Dépenses', route: 'accounting.expenses'),
          NavItem(icon: Icons.pending_actions_rounded, label: 'Créances clients', route: 'accounting.receivables'),
          NavItem(icon: Icons.lock_clock_rounded, label: 'Clôture de caisse (Z)', route: 'accounting.daily_register'),
        ];
      case 'admin':
        return const [
          NavItem(icon: Icons.dashboard_outlined, label: 'Tableau de bord', route: 'admin.dashboard'),
          NavItem(icon: Icons.business_rounded, label: 'Fiche Entreprise', route: 'admin.company'),
          NavItem(icon: Icons.calendar_month_rounded, label: 'Exercices fiscaux', route: 'admin.fiscal_years'),
          NavItem(icon: Icons.manage_accounts_rounded, label: 'Utilisateurs & Droits', route: 'admin.users'),
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

    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: Color(0xFF072747), // Bleu nuit sobre et corporate
        border: Border(right: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête : Logo officiel de la marque ──────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/brand/logo.png',
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.orange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.print_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AFRICA PRINT',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              'COMMUNICATION',
                              style: TextStyle(color: AppColors.orange, fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (company != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    company.name,
                    style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 10, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // ── Menu de navigation (Style Sobre, moderne, sans ligne latérale orange IA) ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              children: items.map((item) => _NavTile(
                item: item,
                isSelected: selectedRoute == item.route,
                onTap: () => onRouteChanged(item.route),
              )).toList(),
            ),
          ),

          // ── Pied de page : Profil utilisateur ───────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF051C33),
              border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    (auth.currentUser?.name ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUser?.name ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _roleLabel(role),
                        style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, size: 17, color: Color(0xAAFFFFFF)),
                  tooltip: 'Déconnexion',
                  onPressed: () => auth.logout(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
        return 'Directeur Général';
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
          duration: const Duration(milliseconds: 140),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withOpacity(0.14) // Fond sobre semi-transparent moderne
                : _hovered
                    ? Colors.white.withOpacity(0.06)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 18,
                color: active ? Colors.white : const Color(0xAAFFFFFF),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    color: active ? Colors.white : const Color(0xCCFFFFFF),
                    letterSpacing: 0.2,
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
