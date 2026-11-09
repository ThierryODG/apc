import 'package:apc_frontend/data/apc_api.dart';

class SecretariatRepository {
  const SecretariatRepository(this._api);

  final ApcApi _api;

  Future<List<Map<String, dynamic>>> catalog() => _api.catalog();

  Future<List<Map<String, dynamic>>> customers() => _api.customers();

  Future<Map<String, dynamic>> customerStats() => _api.customerStats();

  Future<List<Map<String, dynamic>>> inquiries() => _api.inquiries();

  Future<void> createInquiry(Map<String, String> fields) {
    return _api.createInquiry(
      subject: fields['subject']!,
      contactName: fields['contact_name']!,
      description: fields['description']!,
      source: fields['source']!,
      contactPhone: fields['contact_phone'],
    );
  }

  Future<void> createCustomer(Map<String, String> fields) {
    return _api.createCustomer(name: fields['name']!, type: fields['type']!);
  }

  Future<void> qualifyInquiry(int id) => _api.qualifyInquiry(id);

  Future<void> sendInquiryQuote(int id, double amount) {
    return _api.sendInquiryQuote(id, amount);
  }

  Future<void> refuseInquiry(int id, String reason) {
    return _api.refuseInquiry(id, reason);
  }
}