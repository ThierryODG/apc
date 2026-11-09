import 'package:flutter/material.dart';
import 'package:apc_frontend/core/theme/apc_palette.dart';
import 'package:apc_frontend/core/utils/display_formatters.dart';
import 'package:apc_frontend/shared/presentation/apc_widgets.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key, required this.customers, required this.stats});
  final List<Map<String, dynamic>> customers;
  final Map<String, dynamic> stats;

  @override
  State<CustomerPage> createState() => CustomerPageState();
}

class CustomerPageState extends State<CustomerPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.customers
        .where(
          (item) =>
              '${item['name']} ${item['trade_name']} ${item['phone']} ${item['email']}'
                  .toLowerCase()
                  .contains(_search.text.toLowerCase()),
        )
        .toList();
    return PageFrame(
      eyebrow: 'RÉPERTOIRE · HISTORIQUE · CONTACTS',
      title: 'Clients',
      description:
          '${widget.stats['total'] ?? widget.customers.length} fiches dans le répertoire chargé.',
      child: Column(
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Nom, téléphone ou email',
              prefixIcon: Icon(Icons.search_rounded),
              isDense: true,
            ),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.people_alt_outlined,
              title: 'Aucun client trouvé',
              detail: 'Modifie la recherche ou ajoute une fiche client.',
            )
          else
            ...filtered.map((customer) => CustomerRow(customer: customer)),
        ],
      ),
    );
  }
}

class CustomerRow extends StatelessWidget {
  const CustomerRow({super.key, required this.customer});
  final Map<String, dynamic> customer;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFB),
      border: Border.all(color: ApcPalette.line),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: customer['type'] == 'company'
              ? const Color(0xFFD9EDF5)
              : const Color(0xFFFFE8DB),
          child: Icon(
            customer['type'] == 'company'
                ? Icons.storefront_outlined
                : Icons.person_outline_rounded,
            color: customer['type'] == 'company'
                ? ApcPalette.blue
                : ApcPalette.orange,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                textOrFallback(
                  customer['display_name'],
                  textOrFallback(customer['name'], 'Client'),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ApcPalette.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                [customer['phone'], customer['email']]
                    .where((value) => value != null && '$value'.isNotEmpty)
                    .join('  ·  '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: ApcPalette.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        StatusTag(
          label: textOrFallback(customer['segment'], 'nouveau'),
          color: customer['is_active'] == false
              ? ApcPalette.muted
              : ApcPalette.blue,
        ),
      ],
    ),
  );
}
