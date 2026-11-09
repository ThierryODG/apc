import 'package:flutter/material.dart';

import '../../core/state/auth_state.dart';
import 'app_sidebar.dart';
import '../secretary/presentation/secretary_pos_screen.dart';
import '../secretary/presentation/orders_screen.dart';
import '../secretary/presentation/customers_screen.dart';
import '../secretary/presentation/inquiries_screen.dart';
import '../accounting/presentation/accounting_dashboard_screen.dart';
import '../accounting/presentation/cash_flows_screen.dart';
import '../accounting/presentation/expenses_screen.dart';
import '../accounting/presentation/receivables_screen.dart';
import '../accounting/presentation/daily_register_screen.dart';
import '../admin/presentation/admin_dashboard_screen.dart';
import '../admin/presentation/company_settings_screen.dart';
import '../admin/presentation/fiscal_years_screen.dart';
import '../admin/presentation/users_screen.dart';
import '../admin/presentation/catalog_screen.dart';
import '../admin/presentation/settings_screen.dart';

/// Shell principal de l'application.
/// Compose : Sidebar (220px) | Zone principale (topbar + contenu routé)
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late String _currentRoute;

  @override
  void initState() {
    super.initState();
    final role = AuthState().currentUser?.role ?? 'secretary';
    _currentRoute = _defaultRouteForRole(role);
  }

  String _defaultRouteForRole(String role) {
    switch (role) {
      case 'accounting':
        return 'accounting.dashboard';
      case 'admin':
        return 'admin.dashboard';
      default:
        return 'secretary.pos';
    }
  }

  Widget _buildContent() {
    switch (_currentRoute) {
      // ── Secrétariat ──────────────────────────────────────────
      case 'secretary.pos':
        return const SecretaryPosScreen();
      case 'secretary.orders':
        return const OrdersScreen();
      case 'secretary.customers':
        return const CustomersScreen();
      case 'secretary.inquiries':
        return const InquiriesScreen();

      // ── Comptabilité ─────────────────────────────────────────
      case 'accounting.dashboard':
        return const AccountingDashboardScreen();
      case 'accounting.cashflows':
        return const CashFlowsScreen();
      case 'accounting.expenses':
        return const ExpensesScreen();
      case 'accounting.receivables':
        return const ReceivablesScreen();
      case 'accounting.daily_register':
        return const DailyRegisterScreen();

      // ── Admin ────────────────────────────────────────────────
      case 'admin.dashboard':
        return const AdminDashboardScreen();
      case 'admin.company':
        return const CompanySettingsScreen();
      case 'admin.fiscal_years':
        return const FiscalYearsScreen();
      case 'admin.users':
        return const UsersScreen();
      case 'admin.catalog':
        return const CatalogScreen();
      case 'admin.settings':
        return const SettingsScreen();

      default:
        return const Center(child: Text('Page introuvable.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final content = Row(
            children: [
              AppSidebar(
                selectedRoute: _currentRoute,
                onRouteChanged: (route) =>
                    setState(() => _currentRoute = route),
              ),
              Expanded(child: _buildContent()),
            ],
          );

          // Si la fenêtre est réduite en-dessous de 1080px de large, on offre un défilement horizontal fluide
          // évitant tout overflow jaune/noir désagréable
          if (constraints.maxWidth < 1080) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1080,
                height: constraints.maxHeight,
                child: content,
              ),
            );
          }

          return content;
        },
      ),
    );
  }
}
