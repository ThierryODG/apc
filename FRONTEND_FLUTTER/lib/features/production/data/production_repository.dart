import 'package:apc_frontend/data/apc_api.dart';
import 'package:apc_frontend/features/production/domain/production_work_order.dart';

class ProductionRepository {
  const ProductionRepository(this._api);

  final ApcApi _api;

  Future<List<ProductionWorkOrder>> workOrders() async {
    final records = await _api.workOrders();
    return records.map(ProductionWorkOrder.fromJson).toList();
  }

  Future<void> updateStatus(int id, String status) {
    return _api.updateWorkOrderStatus(id, status);
  }
}