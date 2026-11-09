import 'package:flutter/material.dart';
import 'package:apc_frontend/core/theme/apc_palette.dart';
import 'package:apc_frontend/core/utils/display_formatters.dart';
import 'package:apc_frontend/shared/presentation/apc_widgets.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required this.categories});
  final List<Map<String, dynamic>> categories;

  @override
  State<CatalogPage> createState() => CatalogPageState();
}

class CatalogPageState extends State<CatalogPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories
        .map((category) {
          final services = (category['services'] as List? ?? const [])
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .where(
                (item) => '${item['name']} ${item['code']}'
                    .toLowerCase()
                    .contains(_search.text.toLowerCase()),
              )
              .toList();
          return (category: category, services: services);
        })
        .where((item) => item.services.isNotEmpty || _search.text.isEmpty)
        .toList();
    return PageFrame(
      eyebrow: 'PRESTATIONS · UNITÉS · TARIFS',
      title: 'Catalogue',
      description: 'Les prestations actives et leurs tarifs enregistrés.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Chercher une prestation',
              prefixIcon: Icon(Icons.search_rounded),
              isDense: true,
            ),
          ),
          const SizedBox(height: 24),
          if (widget.categories.isEmpty)
            const EmptyState(
              icon: Icons.print_outlined,
              title: 'Catalogue indisponible',
              detail:
                  'Vérifie la connexion à l’API puis actualise les données.',
            )
          else
            ...categories.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 24,
                          color: ApcPalette.orange,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            textOrFallback(
                              entry.category['name'],
                              'Prestations',
                            ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          '${entry.services.length} références',
                          style: const TextStyle(
                            color: ApcPalette.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, bounds) {
                        final columns = bounds.maxWidth > 1000
                            ? 3
                            : (bounds.maxWidth > 620 ? 2 : 1);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: entry.services.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: 119,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) =>
                              ServiceTile(service: entry.services[index]),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key, required this.service});
  final Map<String, dynamic> service;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFB),
      border: Border.all(color: ApcPalette.line),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                textOrFallback(service['name'], 'Prestation'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ApcPalette.ink,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_outward_rounded,
              size: 16,
              color: ApcPalette.blue,
            ),
          ],
        ),
        const Spacer(),
        Text(
          textOrFallback(service['code'], 'APC'),
          style: const TextStyle(color: ApcPalette.muted, fontSize: 11),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              '${formatMoney(service['unit_price'])} FCFA',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: ApcPalette.blue,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '/ ${textOrFallback(service['unit'] is Map ? (service['unit'] as Map)['symbol'] : null, 'unité')}',
              style: const TextStyle(color: ApcPalette.muted, fontSize: 11),
            ),
          ],
        ),
      ],
    ),
  );
}
