import 'package:flutter/material.dart';

import 'package:apc_frontend/core/theme/apc_palette.dart';
import 'package:apc_frontend/features/production/domain/production_work_order.dart';
import 'package:apc_frontend/features/production/presentation/production_desktop_screen.dart';
import 'package:apc_frontend/shared/presentation/apc_widgets.dart';

class ProductionMobileScreen extends StatelessWidget {
  const ProductionMobileScreen({
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
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        Text(
          user['department'] is Map
              ? '${(user['department'] as Map)['name'] ?? 'Atelier APC'}'
              : 'Atelier APC',
          style: const TextStyle(
            color: ApcPalette.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        if (error != null) ...[
          _MobileErrorBanner(message: error!, onRetry: onRefresh),
          const SizedBox(height: 12),
        ],
        if (workOrders.isEmpty && !loading)
          const EmptyState(
            icon: Icons.precision_manufacturing_outlined,
            title: 'Aucun travail affecté',
            detail: 'Les nouveaux ordres de ton atelier apparaîtront ici.',
          )
        else
          for (final workOrder in workOrders)
            _MobileWorkOrderCard(
              workOrder: workOrder,
              onUpdateStatus: onUpdateStatus,
              onError: onError,
            ),
      ],
    ),
  );
}

class _MobileWorkOrderCard extends StatelessWidget {
  const _MobileWorkOrderCard({
    required this.workOrder,
    required this.onUpdateStatus,
    required this.onError,
  });

  final ProductionWorkOrder workOrder;
  final Future<void> Function(int, String) onUpdateStatus;
  final ValueChanged<String> onError;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(15),
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
                workOrder.number,
                style: const TextStyle(
                  color: ApcPalette.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _MobileStatus(status: workOrder.status),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          workOrder.subject,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          workOrder.customerName,
          style: const TextStyle(color: ApcPalette.muted),
        ),
        const SizedBox(height: 13),
        Text(
          workOrder.description,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),
        for (final action in availableWorkOrderActions(workOrder.status))
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: () async {
                  try {
                    await onUpdateStatus(workOrder.id, action.status);
                  } on Object catch (error) {
                    onError('$error');
                  }
                },
                icon: Icon(_actionIcon(action.status)),
                label: Text(action.label),
                style: FilledButton.styleFrom(
                  backgroundColor: action.status == 'blocked'
                      ? ApcPalette.orange
                      : ApcPalette.ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  IconData _actionIcon(String status) => switch (status) {
    'in_progress' => Icons.play_arrow_rounded,
    'blocked' => Icons.pause_rounded,
    _ => Icons.check_rounded,
  };
}

class _MobileStatus extends StatelessWidget {
  const _MobileStatus({required this.status});

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
    color: status == 'blocked' ? ApcPalette.orange : ApcPalette.blue,
  );
}

class _MobileErrorBanner extends StatelessWidget {
  const _MobileErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFFFE9DE),
    borderRadius: BorderRadius.circular(5),
    child: ListTile(
      leading: const Icon(
        Icons.warning_amber_rounded,
        color: ApcPalette.orange,
      ),
      title: Text(message),
      trailing: IconButton(
        tooltip: 'Réessayer',
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
      ),
    ),
  );
}
