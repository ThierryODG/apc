import 'package:flutter/material.dart';

import 'package:apc_frontend/core/theme/apc_palette.dart';
import 'package:apc_frontend/core/utils/display_formatters.dart';
import 'package:apc_frontend/features/production/domain/production_work_order.dart';
import 'package:apc_frontend/shared/presentation/apc_widgets.dart';

class ProductionDesktopScreen extends StatefulWidget {
  const ProductionDesktopScreen({
    super.key,
    required this.user,
    required this.workOrders,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onUpdateStatus,
    required this.onError,
  });

  final Map<String, dynamic> user;
  final List<ProductionWorkOrder> workOrders;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final Future<void> Function(int, String) onUpdateStatus;
  final ValueChanged<String> onError;

  @override
  State<ProductionDesktopScreen> createState() =>
      _ProductionDesktopScreenState();
}

class _ProductionDesktopScreenState extends State<ProductionDesktopScreen> {
  final _search = TextEditingController();
  String _statusFilter = 'Tous';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.workOrders.where((item) {
      final matchesText =
          '${item.number} ${item.orderNumber} ${item.subject} ${item.customerName}'
              .toLowerCase()
              .contains(_search.text.toLowerCase());
      return matchesText &&
          (_statusFilter == 'Tous' || item.status == _statusFilter);
    }).toList();

    return _DesktopFrame(
      user: widget.user,
      loading: widget.loading,
      onRefresh: widget.onRefresh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un ordre, client ou travail',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 205,
                child: DropdownButtonFormField<String>(
                  initialValue: _statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Statut',
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Tous', child: Text('Tous')),
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('À démarrer'),
                    ),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('En cours'),
                    ),
                    DropdownMenuItem(value: 'blocked', child: Text('Bloqués')),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Terminés'),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _statusFilter = value ?? 'Tous';
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (widget.error != null)
            ErrorBanner(message: widget.error!, onRetry: widget.onRefresh),
          if (widget.workOrders.isEmpty && !widget.loading)
            const EmptyState(
              icon: Icons.precision_manufacturing_outlined,
              title: 'Aucun ordre dans ta file',
              detail: 'Les travaux affectés à ton atelier apparaîtront ici après validation d’une commande.',
            )
          else if (filtered.isEmpty && !widget.loading)
            const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Aucun résultat',
              detail: 'Modifie le texte ou le filtre de statut.',
            )
          else
            _WorkOrderTable(
              workOrders: filtered,
              onUpdateStatus: widget.onUpdateStatus,
              onError: widget.onError,
            ),
        ],
      ),
    );
  }
}

class _DesktopFrame extends StatelessWidget {
  const _DesktopFrame({
    required this.user,
    required this.loading,
    required this.onRefresh,
    required this.child,
  });

  final Map<String, dynamic> user;
  final bool loading;
  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1360),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(
              textOrFallback(
                user['department'] is Map
                    ? (user['department'] as Map)['name']
                    : null,
                'FILE DE PRODUCTION',
              ).toUpperCase(),
            ),
            const SizedBox(height: 8),
            Text(
              'Ordres de travail',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    ),
  );
}

class _WorkOrderTable extends StatelessWidget {
  const _WorkOrderTable({
    required this.workOrders,
    required this.onUpdateStatus,
    required this.onError,
  });

  final List<ProductionWorkOrder> workOrders;
  final Future<void> Function(int, String) onUpdateStatus;
  final ValueChanged<String> onError;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFB),
      border: Border.all(color: ApcPalette.line),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      children: [
        const _TableHeader(),
        for (final workOrder in workOrders)
          _WorkOrderTableRow(
            workOrder: workOrder,
            onUpdateStatus: onUpdateStatus,
            onError: onError,
          ),
      ],
    ),
  );
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 13),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text('ORDRE / TRAVAIL')),
        Expanded(child: Text('CLIENT')),
        SizedBox(width: 120, child: Text('ÉTAT')),
        SizedBox(width: 230, child: Text('ACTION')),
      ],
    ),
  );
}

class _WorkOrderTableRow extends StatelessWidget {
  const _WorkOrderTableRow({
    required this.workOrder,
    required this.onUpdateStatus,
    required this.onError,
  });

  final ProductionWorkOrder workOrder;
  final Future<void> Function(int, String) onUpdateStatus;
  final ValueChanged<String> onError;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: ApcPalette.line)),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workOrder.number,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                workOrder.subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Expanded(child: Text(workOrder.customerName)),
        SizedBox(
          width: 120,
          child: _ProductionStatus(status: workOrder.status),
        ),
        SizedBox(
          width: 230,
          child: _WorkOrderActions(
            workOrder: workOrder,
            onUpdateStatus: onUpdateStatus,
            onError: onError,
          ),
        ),
      ],
    ),
  );
}

class _ProductionStatus extends StatelessWidget {
  const _ProductionStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) => StatusTag(
    label: switch (status) {
      'pending' => 'À DÉMARRER',
      'in_progress' => 'EN COURS',
      'blocked' => 'BLOQUÉ',
      'completed' => 'TERMINÉ',
      _ => status.toUpperCase(),
    },
    color: switch (status) {
      'pending' => ApcPalette.blue,
      'in_progress' => const Color(0xFF667A35),
      'blocked' => ApcPalette.orange,
      _ => ApcPalette.muted,
    },
  );
}

class _WorkOrderActions extends StatelessWidget {
  const _WorkOrderActions({
    required this.workOrder,
    required this.onUpdateStatus,
    required this.onError,
  });

  final ProductionWorkOrder workOrder;
  final Future<void> Function(int, String) onUpdateStatus;
  final ValueChanged<String> onError;

  @override
  Widget build(BuildContext context) {
    final actions = _availableActions(workOrder.status);
    return Wrap(
      spacing: 4,
      children: [
        for (final action in actions)
          TextButton(
            onPressed: () async {
              try {
                await onUpdateStatus(workOrder.id, action.status);
              } on Object catch (error) {
                onError('$error');
              }
            },
            child: Text(action.label),
          ),
      ],
    );
  }
}

class WorkOrderAction {
  const WorkOrderAction(this.status, this.label);

  final String status;
  final String label;
}

List<WorkOrderAction> availableWorkOrderActions(String status) =>
    switch (status) {
      'pending' => const [
        WorkOrderAction('in_progress', 'Démarrer'),
        WorkOrderAction('blocked', 'Bloquer'),
      ],
      'in_progress' => const [
        WorkOrderAction('blocked', 'Bloquer'),
        WorkOrderAction('completed', 'Terminer'),
      ],
      'blocked' => const [
        WorkOrderAction('in_progress', 'Reprendre'),
        WorkOrderAction('completed', 'Terminer'),
      ],
      _ => const [],
    };

List<WorkOrderAction> _availableActions(String status) =>
    availableWorkOrderActions(status);

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => MaterialBanner(
    content: Text(message),
    leading: const Icon(Icons.warning_amber_rounded, color: ApcPalette.orange),
    actions: [TextButton(onPressed: onRetry, child: const Text('Réessayer'))],
  );
}
