import 'package:flutter/foundation.dart';

import 'package:apc_frontend/data/apc_api.dart';
import 'package:apc_frontend/features/production/data/production_repository.dart';
import 'package:apc_frontend/features/production/domain/production_work_order.dart';

class ProductionController extends ChangeNotifier {
  ProductionController(this._repository);

  final ProductionRepository _repository;

  List<ProductionWorkOrder> _workOrders = [];
  String? _error;
  bool _loading = false;

  List<ProductionWorkOrder> get workOrders => _workOrders;
  String? get error => _error;
  bool get loading => _loading;

  Future<void> refresh(Map<String, dynamic> user) async {
    final permissions = (user['permissions'] as List? ?? const []).toSet();
    if (!permissions.contains('production.view_queue')) {
      _workOrders = [];
      _error = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _workOrders = await _repository.workOrders();
    } on ApiException catch (error) {
      _error = error.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(
    int id,
    String status,
    Map<String, dynamic> user,
  ) async {
    await _repository.updateStatus(id, status);
    await refresh(user);
  }

  void clear() {
    _workOrders = [];
    _error = null;
    _loading = false;
    notifyListeners();
  }
}