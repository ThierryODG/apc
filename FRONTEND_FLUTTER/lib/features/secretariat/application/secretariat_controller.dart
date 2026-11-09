import 'package:flutter/foundation.dart';

import 'package:apc_frontend/data/apc_api.dart';
import 'package:apc_frontend/features/secretariat/data/secretariat_repository.dart';

class SecretariatController extends ChangeNotifier {
  SecretariatController(this._repository);

  final SecretariatRepository _repository;

  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _catalog = [];
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _inquiries = [];
  Map<String, dynamic> _customerStats = {};
  String? _loadError;
  bool _loading = false;

  List<Map<String, dynamic>> get catalog => _catalog;
  List<Map<String, dynamic>> get customers => _customers;
  List<Map<String, dynamic>> get inquiries => _inquiries;
  Map<String, dynamic> get customerStats => _customerStats;
  String? get loadError => _loadError;
  bool get loading => _loading;

  bool can(String permission) =>
      ((_user?['permissions'] as List?) ?? const []).contains(permission);

  void clear() {
    _user = null;
    _catalog = [];
    _customers = [];
    _inquiries = [];
    _customerStats = {};
    _loadError = null;
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh(Map<String, dynamic> user) async {
    _user = user;
    _loading = true;
    _loadError = null;
    notifyListeners();

    final results = await Future.wait<dynamic>([
      _fetchIfAllowed('catalog.view', _repository.catalog),
      _fetchIfAllowed('customers.view', _repository.customers),
      _fetchIfAllowed('customers.view', _repository.customerStats),
      _fetchIfAllowed('inquiries.view', _repository.inquiries),
    ]);

    if (results[0] is List<Map<String, dynamic>>) {
      _catalog = results[0] as List<Map<String, dynamic>>;
    }
    if (results[1] is List<Map<String, dynamic>>) {
      _customers = results[1] as List<Map<String, dynamic>>;
    }
    if (results[2] is Map<String, dynamic>) {
      _customerStats = results[2] as Map<String, dynamic>;
    }
    if (results[3] is List<Map<String, dynamic>>) {
      _inquiries = results[3] as List<Map<String, dynamic>>;
    }
    final failures = results.whereType<ApiException>().toList();
    if (failures.isNotEmpty) _loadError = failures.first.message;
    _loading = false;
    notifyListeners();
  }

  Future<void> createInquiry(Map<String, String> fields) async {
    await _repository.createInquiry(fields);
    await _reload();
  }

  Future<void> createCustomer(Map<String, String> fields) async {
    await _repository.createCustomer(fields);
    await _reload();
  }

  Future<void> qualifyInquiry(int id) async {
    await _repository.qualifyInquiry(id);
    await _reload();
  }

  Future<void> sendQuote(int id, double amount) async {
    await _repository.sendInquiryQuote(id, amount);
    await _reload();
  }

  Future<void> refuseInquiry(int id, String reason) async {
    await _repository.refuseInquiry(id, reason);
    await _reload();
  }

  Future<void> _reload() async {
    final user = _user;
    if (user != null) await refresh(user);
  }

  Future<dynamic> _fetchIfAllowed(
    String permission,
    Future<dynamic> Function() fetch,
  ) async {
    if (!can(permission)) return null;
    try {
      return await fetch();
    } on ApiException catch (error) {
      return error;
    }
  }
}
