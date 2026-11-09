import 'package:flutter/material.dart';
import 'package:apc_frontend/features/secretariat/presentation/dialogs.dart';
import 'package:apc_frontend/core/theme/apc_palette.dart';
import 'package:apc_frontend/core/utils/display_formatters.dart';
import 'package:apc_frontend/data/apc_api.dart';
import 'package:apc_frontend/shared/presentation/apc_widgets.dart';

class InquiryPage extends StatefulWidget {
  const InquiryPage({
    super.key,
    required this.inquiries,
    required this.user,
    required this.onQualify,
    required this.onSendQuote,
    required this.onRefuse,
    required this.onError,
  });
  final List<Map<String, dynamic>> inquiries;
  final Map<String, dynamic> user;
  final Future<void> Function(int) onQualify;
  final Future<void> Function(int, double) onSendQuote;
  final Future<void> Function(int) onRefuse;
  final ValueChanged<String> onError;

  @override
  State<InquiryPage> createState() => InquiryPageState();
}

class InquiryPageState extends State<InquiryPage> {
  final _search = TextEditingController();
  String _filter = 'Toutes';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.inquiries.where((item) {
      final query = _search.text.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          '${item['subject']} ${item['contact_name']} ${item['contact_phone']}'
              .toLowerCase()
              .contains(query);
      final matchesFilter =
          _filter == 'Toutes' || item['status'] == statusCode(_filter);
      return matchesSearch && matchesFilter;
    }).toList();

    return PageFrame(
      eyebrow: 'ACCUEIL · DEVIS · SUIVI',
      title: 'Demandes entrantes',
      description: 'Chaque échange devient un dossier suivi, du premier contact au devis.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 270,
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Chercher une demande',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                ),
              ),
              for (final filter in [
                'Toutes',
                'Nouvelles',
                'Qualifiées',
                'Devis envoyés',
                'Refusées',
              ])
                FilterButton(
                  label: filter,
                  selected: _filter == filter,
                  onTap: () => setState(() => _filter = filter),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.markunread_mailbox_outlined,
              title: 'Aucune demande trouvée',
              detail: 'Essaie un autre filtre ou crée une nouvelle demande.',
            )
          else
            ...filtered.map(
              (item) => InquiryRow(
                item: item,
                onQualify: _can('inquiries.edit') && item['status'] == 'new'
                    ? () => _run(() => widget.onQualify(_id(item['id'])))
                    : null,
                onSendQuote:
                    _can('inquiries.edit') && item['status'] == 'qualified'
                    ? () => _quote(item)
                    : null,
                onRefuse:
                    _can('inquiries.edit') &&
                        !['refused', 'converted'].contains(item['status'])
                    ? () => _run(() => widget.onRefuse(_id(item['id'])))
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  bool _can(String permission) =>
      (widget.user['permissions'] as List? ?? const []).contains(permission);

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (error) {
      widget.onError(error.message);
    }
  }

  Future<void> _quote(Map<String, dynamic> item) async {
    final amount = await _numberDialog();
    if (amount == null) return;
    await _run(() => widget.onSendQuote(_id(item['id']), amount));
  }

  Future<double?> _numberDialog() async {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) => ApcDialog(
        title: 'Marquer le devis envoyé',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              double.tryParse(controller.text.replaceAll(',', '.')),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
        child: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Montant estimatif · FCFA',
          ),
        ),
      ),
    );
  }

  int _id(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
}

class InquiryRow extends StatelessWidget {
  const InquiryRow({
    super.key,
    required this.item,
    this.compact = false,
    this.onQualify,
    this.onSendQuote,
    this.onRefuse,
  });
  final Map<String, dynamic> item;
  final bool compact;
  final VoidCallback? onQualify;
  final VoidCallback? onSendQuote;
  final VoidCallback? onRefuse;

  @override
  Widget build(BuildContext context) {
    final status = textOrFallback(item['status'], 'new');
    final statusColor = switch (status) {
      'new' => ApcPalette.blue,
      'qualified' => const Color(0xFF667A35),
      'quote_sent' => ApcPalette.orange,
      'refused' => const Color(0xFF866156),
      _ => ApcPalette.muted,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: compact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFB),
        border: Border.all(color: ApcPalette.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final main = Row(
            children: [
              Container(width: 4, height: 39, color: statusColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      textOrFallback(item['subject'], 'Nouvelle demande'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ApcPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${textOrFallback(item['contact_name'], 'Contact')}  ·  ${textOrFallback(item['source'], 'autre')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ApcPalette.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              StatusTag(label: statusLabel(status), color: statusColor),
            ],
          );
          if (compact) return main;
          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onQualify != null)
                IconButton(
                  tooltip: 'Qualifier',
                  onPressed: onQualify,
                  icon: const Icon(
                    Icons.task_alt_rounded,
                    color: ApcPalette.blue,
                  ),
                ),
              if (onSendQuote != null)
                IconButton(
                  tooltip: 'Saisir l’envoi du devis',
                  onPressed: onSendQuote,
                  icon: const Icon(
                    Icons.send_outlined,
                    color: ApcPalette.orange,
                  ),
                ),
              if (onRefuse != null)
                IconButton(
                  tooltip: 'Refuser la demande',
                  onPressed: onRefuse,
                  icon: const Icon(
                    Icons.block_outlined,
                    color: ApcPalette.muted,
                  ),
                ),
            ],
          );
          return narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    main,
                    if (actions.children.isNotEmpty)
                      Align(alignment: Alignment.centerRight, child: actions),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: main),
                    actions,
                  ],
                );
        },
      ),
    );
  }
}
