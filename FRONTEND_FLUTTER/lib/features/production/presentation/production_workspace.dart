import 'package:flutter/material.dart';

import 'package:apc_frontend/features/production/domain/production_work_order.dart';
import 'package:apc_frontend/features/production/presentation/production_desktop_screen.dart';
import 'package:apc_frontend/features/production/presentation/production_mobile_screen.dart';

class ProductionWorkspace extends StatelessWidget {
  const ProductionWorkspace({
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
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 760;
    final screen = mobile
        ? ProductionMobileScreen(
            user: user,
            workOrders: workOrders,
            loading: loading,
            error: error,
            onRefresh: onRefresh,
            onUpdateStatus: onUpdateStatus,
            onError: onError,
          )
        : ProductionDesktopScreen(
            user: user,
            workOrders: workOrders,
            loading: loading,
            error: error,
            onRefresh: onRefresh,
            onUpdateStatus: onUpdateStatus,
            onError: onError,
          );

    return screen;
  }
}
