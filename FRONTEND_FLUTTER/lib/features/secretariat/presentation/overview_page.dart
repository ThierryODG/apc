import 'package:flutter/material.dart';
import 'package:apc_frontend/core/theme/apc_palette.dart';
import 'package:apc_frontend/core/auth/role_workspace.dart';
import 'package:apc_frontend/core/utils/display_formatters.dart';
import 'package:apc_frontend/features/secretariat/presentation/inquiries_page.dart';
import 'package:apc_frontend/shared/presentation/apc_widgets.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({
    super.key,
    required this.user,
    required this.customers,
    required this.inquiries,
    required this.catalog,
    required this.customerStats,
    required this.onSelect,
    required this.onNewInquiry,
    required this.canViewInquiries,
    required this.canCreateInquiry,
    required this.canViewCatalog,
  });

  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> customers;
  final List<Map<String, dynamic>> inquiries;
  final List<Map<String, dynamic>> catalog;
  final Map<String, dynamic> customerStats;
  final ValueChanged<String> onSelect;
  final Future<void> Function() onNewInquiry;
  final bool canViewInquiries;
  final bool canCreateInquiry;
  final bool canViewCatalog;

  @override
  Widget build(BuildContext context) {
    final name = textOrFallback(user['name'], 'Équipe APC').split(' ').first;
    final stats = <StatData>[
      if (canViewInquiries)
        StatData(
          'Demandes ouvertes',
          '${inquiries.where((item) => !['refused', 'converted'].contains(item['status'])).length}',
          Icons.markunread_mailbox_outlined,
          ApcPalette.blue,
        ),
      if (user['permissions'] is List &&
          (user['permissions'] as List).contains('customers.view'))
        StatData(
          'Clients actifs',
          '${customerStats['active'] ?? customers.length}',
          Icons.people_alt_outlined,
          ApcPalette.orange,
        ),
      if (canViewCatalog)
        StatData(
          'Prestations',
          '${catalog.fold<int>(0, (total, category) => total + ((category['services'] as List?)?.length ?? 0))}',
          Icons.print_outlined,
          ApcPalette.ink,
        ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 34),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(27, 25, 27, 25),
                decoration: BoxDecoration(
                  color: ApcPalette.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) => Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Eyebrow(
                              workspaceTitle(user).toUpperCase(),
                              light: true,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Bonjour $name.',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              workspaceMessage(user),
                              style: TextStyle(
                                color: Color(0xFFE1F1F6),
                                fontSize: 14,
                              ),
                            ),
                            if (canCreateInquiry) ...[
                              const SizedBox(height: 19),
                              FilledButton.icon(
                                onPressed: onNewInquiry,
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('Saisir une demande'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: ApcPalette.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (constraints.maxWidth > 560) ...[
                        const SizedBox(width: 22),
                        Container(
                          width: 142,
                          height: 142,
                          decoration: BoxDecoration(
                            color: const Color(0xFF07649D),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Stack(
                            children: [
                              Positioned(
                                right: -21,
                                top: -20,
                                child: PrintDisc(
                                  size: 118,
                                  color: Color(0xFF2E91C2),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Icon(
                                    Icons.auto_awesome_mosaic_outlined,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (stats.isNotEmpty) const SizedBox(height: 24),
              if (stats.isNotEmpty)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth > 840
                        ? 3
                        : (constraints.maxWidth > 500 ? 3 : 1);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisExtent: 112,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) =>
                          StatTile(data: stats[index]),
                    );
                  },
                ),
              if (canViewInquiries) const SizedBox(height: 31),
              if (canViewInquiries)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'À suivre',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onSelect('inquiries'),
                      child: const Text('Toutes les demandes  →'),
                    ),
                  ],
                ),
              if (canViewInquiries) const SizedBox(height: 10),
              if (canViewInquiries && inquiries.isEmpty)
                EmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'La file est calme',
                  detail: 'Les nouvelles demandes apparaîtront ici.',
                )
              else if (canViewInquiries)
                ...inquiries
                    .take(4)
                    .map((item) => InquiryRow(item: item, compact: true)),
              if (canViewCatalog) const SizedBox(height: 28),
              if (canViewCatalog)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Le catalogue du jour',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () => onSelect('catalog'),
                      child: const Text('Voir le catalogue  →'),
                    ),
                  ],
                ),
              if (canViewCatalog) const SizedBox(height: 12),
              if (canViewCatalog)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in catalog.take(8))
                      CategoryTag(
                        label: textOrFallback(category['name'], 'Prestation'),
                      ),
                    if (catalog.isEmpty)
                      const CategoryTag(label: 'Catalogue non chargé'),
                  ],
                ),
              if (!canViewInquiries && !canViewCatalog) ...[
                const SizedBox(height: 28),
                EmptyState(
                  icon: Icons.construction_outlined,
                  title: 'Espace métier en préparation',
                  detail: workspacePendingMessage(user),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StatData {
  const StatData(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.data});
  final StatData data;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFB),
      border: Border.all(color: ApcPalette.line),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(data.icon, color: data.color, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: const TextStyle(
                  fontSize: 26,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: ApcPalette.ink,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: ApcPalette.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
