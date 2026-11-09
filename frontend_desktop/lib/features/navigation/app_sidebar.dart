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

/// Sidebar moderne repliable (dynamique : mode étendu 220px ou compact 72px)
class AppSidebar extends StatefulWidget {
  final String selectedRoute;
  final Function(String route) onRouteChanged;

  const AppSidebar({
    super.key,
    required this.selectedRoute,
    required this.onRouteChanged,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _isCollapsed = false;

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
          NavItem(icon: Icons.inventory_2_outlined, label: 'Consommables & Stocks', route: 'accounting.expenses'),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: _isCollapsed ? 74 : 224,
      decoration: const BoxDecoration(
        color: Color(0xFF072747),
        border: Border(right: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête : Logo pur sans texte parasite + Bouton toggle ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: _isCollapsed ? Alignment.center : Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'assets/brand/logo.png',
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.print_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  tooltip: _isCollapsed ? 'Agrandir le menu' : 'Réduire le menu',
                  onPressed: () => setState(() => _isCollapsed = !_isCollapsed),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // ── Liste des items de menu ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              children: items.map((item) => _NavTile(
                item: item,
                isCollapsed: _isCollapsed,
                isSelected: widget.selectedRoute == item.route,
                onTap: () => widget.onRouteChanged(item.route),
              )).toList(),
            ),
          ),

          // ── Pied de page : Profil utilisateur ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF051C33),
              border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
            ),
            child: Row(
              mainAxisAlignment: _isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
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
                if (!_isCollapsed) ...[
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
  final bool isCollapsed;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isCollapsed,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected;
    return Tooltip(
      message: widget.isCollapsed ? widget.item.label : '',
      waitDuration: const Duration(milliseconds: 300),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            margin: const EdgeInsets.only(bottom: 4),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withOpacity(0.14)
                  : _hovered
                      ? Colors.white.withOpacity(0.06)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  widget.item.icon,
                  size: 19,
                  color: active ? Colors.white : const Color(0xAAFFFFFF),
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                        color: active ? Colors.white : const Color(0xCCFFFFFF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
