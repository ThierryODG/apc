import 'package:flutter/material.dart';
import 'package:apc_frontend/core/auth/role_workspace.dart';
import 'package:apc_frontend/core/theme/apc_palette.dart';
import 'package:apc_frontend/data/apc_api.dart';
import 'package:apc_frontend/features/secretariat/presentation/catalog_page.dart';
import 'package:apc_frontend/features/secretariat/presentation/customers_page.dart';
import 'package:apc_frontend/features/secretariat/presentation/dialogs.dart';
import 'package:apc_frontend/features/secretariat/presentation/inquiries_page.dart';
import 'package:apc_frontend/features/secretariat/presentation/overview_page.dart';
import 'package:apc_frontend/core/utils/display_formatters.dart';
import 'package:apc_frontend/features/production/domain/production_work_order.dart';
import 'package:apc_frontend/features/production/presentation/production_workspace.dart';
import 'package:apc_frontend/features/administration/presentation/administration_workspace.dart';
import 'package:apc_frontend/features/accounting/presentation/accounting_workspace.dart';
import 'package:apc_frontend/features/prepress/presentation/prepress_workspace.dart';
import 'package:apc_frontend/shared/presentation/apc_widgets.dart';

class WorkspaceSection {
  const WorkspaceSection(this.key, this.label, this.icon);

  final String key;
  final String label;
  final IconData icon;
}

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({
    super.key,
    required this.user,
    required this.section,
    required this.loading,
    required this.loadError,
    required this.catalog,
    required this.customers,
    required this.inquiries,
    required this.customerStats,
    required this.workOrders,
    required this.productionLoading,
    required this.productionError,
    required this.onSelect,
    required this.onRefresh,
    required this.onCreateInquiry,
    required this.onCreateCustomer,
    required this.onQualify,
    required this.onSendQuote,
    required this.onRefuse,
    required this.onUpdateWorkOrderStatus,
    required this.onLogout,
    required this.onError,
  });

  final Map<String, dynamic> user;
  final int section;
  final bool loading;
  final String? loadError;
  final List<Map<String, dynamic>> catalog;
  final List<Map<String, dynamic>> customers;
  final List<Map<String, dynamic>> inquiries;
  final Map<String, dynamic> customerStats;
  final List<ProductionWorkOrder> workOrders;
  final bool productionLoading;
  final String? productionError;
  final ValueChanged<int> onSelect;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Map<String, String>) onCreateInquiry;
  final Future<void> Function(Map<String, String>) onCreateCustomer;
  final Future<void> Function(int) onQualify;
  final Future<void> Function(int, double) onSendQuote;
  final Future<void> Function(int, String) onRefuse;
  final Future<void> Function(int, String) onUpdateWorkOrderStatus;
  final Future<void> Function() onLogout;
  final ValueChanged<String> onError;

  List<WorkspaceSection> get _items {
    final permissions = (user['permissions'] as List? ?? const []).toSet();
    return [
      const WorkspaceSection('overview', 'Mon espace', Icons.grid_view_rounded),
      if (permissions.contains('inquiries.view'))
        const WorkspaceSection(
          'inquiries',
          'Demandes',
          Icons.markunread_mailbox_outlined,
        ),
      if (permissions.contains('customers.view'))
        const WorkspaceSection(
          'customers',
          'Clients',
          Icons.people_alt_outlined,
        ),
      if (permissions.contains('catalog.view'))
        const WorkspaceSection(
          'catalog',
          'Catalogue',
          Icons.color_lens_outlined,
        ),
      if (_hasRole('Graphiste'))
        const WorkspaceSection(
          'prepress',
          'Préparation PAO',
          Icons.design_services_outlined,
        ),
      if (permissions.contains('production.view_queue'))
        const WorkspaceSection(
          'production',
          'File atelier',
          Icons.precision_manufacturing_outlined,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, bounds) {
        final desktop = bounds.maxWidth >= 1020;
        final items = _items;
        final selectedIndex = section.clamp(0, items.length - 1);
        final selectedItem = items[selectedIndex];
        final page = _page(context, selectedItem.key);
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (desktop)
                  SideNavigation(
                    items: items,
                    selected: selectedIndex,
                    user: user,
                    onSelect: onSelect,
                    onLogout: onLogout,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      WorkspaceHeader(
                        user: user,
                        title: selectedItem.label,
                        loading: loading,
                        onRefresh: onRefresh,
                        onLogout: onLogout,
                      ),
                      if (loadError != null)
                        MaterialBanner(
                          backgroundColor: const Color(0xFFFFE9DE),
                          content: Text(
                            '$loadError Certains panneaux peuvent rester vides jusqu’au rétablissement de l’API.',
                          ),
                          leading: const Icon(
                            Icons.warning_amber_rounded,
                            color: ApcPalette.orange,
                          ),
                          actions: [
                            TextButton(
                              onPressed: onRefresh,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      Expanded(child: page),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: desktop || items.length < 2
              ? null
              : NavigationBar(
                  selectedIndex: section,
                  onDestinationSelected: onSelect,
                  backgroundColor: const Color(0xFFFFFEFB),
                  indicatorColor: const Color(0xFFD9EDF5),
                  destinations: items
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          label: item.key == 'overview'
                              ? 'Mon espace'
                              : item.label,
                        ),
                      )
                      .toList(),
                ),
          floatingActionButton:
              (selectedItem.key == 'inquiries' && _can('inquiries.create')) ||
                  (selectedItem.key == 'customers' && _can('customers.create'))
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    try {
                      if (selectedItem.key == 'inquiries') {
                        await _newInquiry(context);
                      } else {
                        await _newCustomer(context);
                      }
                    } on ApiException catch (error) {
                      onError(error.message);
                    }
                  },
                  backgroundColor: ApcPalette.orange,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    selectedItem.key == 'inquiries'
                        ? 'Nouvelle demande'
                        : 'Nouveau client',
                  ),
                )
              : null,
        );
      },
    );
  }

  bool _can(String permission) =>
      ((user['permissions'] as List?) ?? const []).contains(permission);

  Future<void> _newInquiry(BuildContext context) async {
    final fields = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const InquiryDialog(),
    );
    if (fields == null) return;
    try {
      await onCreateInquiry(fields);
    } on ApiException catch (error) {
      onError(error.message);
    }
  }

  Future<void> _newCustomer(BuildContext context) async {
    final fields = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const CustomerDialog(),
    );
    if (fields == null) return;
    try {
      await onCreateCustomer(fields);
    } on ApiException catch (error) {
      onError(error.message);
    }
  }

  Future<void> _refuseInquiry(BuildContext context, int id) async {
    final controller = TextEditingController();
    try {
      final reason = await showDialog<String>(
        context: context,
        builder: (context) => ApcDialog(
          title: 'Refuser la demande',
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Confirmer le refus'),
            ),
          ],
          child: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Motif du refus'),
          ),
        ),
      );
      if (reason == null || reason.trim().isEmpty) return;
      await onRefuse(id, reason.trim());
    } finally {
      controller.dispose();
    }
  }

  void _selectDestination(String key) {
    final index = _items.indexWhere((item) => item.key == key);
    if (index >= 0) onSelect(index);
  }

  Widget _page(BuildContext context, String key) {
    switch (key) {
      case 'production':
        return ProductionWorkspace(
          user: user,
          workOrders: workOrders,
          loading: productionLoading,
          error: productionError,
          onRefresh: onRefresh,
          onUpdateStatus: onUpdateWorkOrderStatus,
          onError: onError,
        );
      case 'prepress':
        return const PrepressWorkspace();
      case 'inquiries':
        return InquiryPage(
          inquiries: inquiries,
          user: user,
          onQualify: onQualify,
          onSendQuote: onSendQuote,
          onRefuse: (id) => _refuseInquiry(context, id),
          onError: onError,
        );
      case 'customers':
        return CustomerPage(customers: customers, stats: customerStats);
      case 'catalog':
        return CatalogPage(categories: catalog);
      default:
        if (_hasRole('SuperAdmin') || _hasRole('DirecteurGeneral')) {
          return const AdministrationWorkspace();
        }
        if (_hasRole('Comptable')) return const AccountingWorkspace();
        if (_hasRole('Graphiste')) return const PrepressWorkspace();
        return OverviewPage(
          user: user,
          customers: customers,
          inquiries: inquiries,
          catalog: catalog,
          customerStats: customerStats,
          onSelect: _selectDestination,
          onNewInquiry: () => _newInquiry(context),
          canViewInquiries: _can('inquiries.view'),
          canCreateInquiry: _can('inquiries.create'),
          canViewCatalog: _can('catalog.view'),
        );
    }
  }

  bool _hasRole(String role) =>
      ((user['roles'] as List?) ?? const []).contains(role);
}

class SideNavigation extends StatelessWidget {
  const SideNavigation({
    super.key,
    required this.items,
    required this.selected,
    required this.user,
    required this.onSelect,
    required this.onLogout,
  });

  final List<WorkspaceSection> items;
  final int selected;
  final Map<String, dynamic> user;
  final ValueChanged<int> onSelect;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 246,
      color: ApcPalette.ink,
      padding: const EdgeInsets.fromLTRB(18, 22, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 72,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Image.asset(
              'assets/brand/apc-logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 34),
          Eyebrow(workspaceTitle(user).toUpperCase(), light: true),
          const SizedBox(height: 12),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final active = index == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF274650)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border(
                      left: BorderSide(
                        color: active ? ApcPalette.orange : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 19,
                        color: active ? Colors.white : const Color(0xFFA7B7B6),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : const Color(0xFFA7B7B6),
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          const Divider(color: Color(0xFF38545C)),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: ApcPalette.orange,
                child: Text(
                  initialsFor(user['name']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      textOrFallback(user['name'], 'Membre APC'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      textOrFallback(
                        user['department'] is Map
                            ? (user['department'] as Map)['name']
                            : null,
                        'Équipe APC',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFA7B7B6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Déconnexion',
                onPressed: onLogout,
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: Color(0xFFA7B7B6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkspaceHeader extends StatelessWidget {
  const WorkspaceHeader({
    super.key,
    required this.user,
    required this.title,
    required this.loading,
    required this.onRefresh,
    required this.onLogout,
  });

  final Map<String, dynamic> user;
  final String title;
  final bool loading;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFEFB),
        border: Border(bottom: BorderSide(color: ApcPalette.line)),
      ),
      child: Row(
        children: [
          if (MediaQuery.sizeOf(context).width < 1020) ...[
            Container(
              width: 43,
              height: 43,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ApcPalette.line),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Image.asset(
                'assets/brand/apc-logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                    color: ApcPalette.muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  workspaceTitle(user).toUpperCase(),
                  style: TextStyle(
                    fontSize: MediaQuery.sizeOf(context).width < 600 ? 10 : 12,
                    color: ApcPalette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Actualiser les données',
            onPressed: loading ? null : onRefresh,
            icon: loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          if (MediaQuery.sizeOf(context).width < 1020)
            IconButton(
              tooltip: 'Déconnexion',
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
    );
  }
}
