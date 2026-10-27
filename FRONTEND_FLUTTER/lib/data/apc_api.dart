import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  @override
  String toString() => message;
}

class ApcApi {
  ApcApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

  static String get defaultBaseUrl {
    const configured = String.fromEnvironment('APC_API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  String baseUrl = defaultBaseUrl;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/api/v1/auth/login',
      body: {
        'email': email,
        'password': password,
        'device_name': 'APC Flutter',
      },
      authenticated: false,
    );
    _token = data['token'] as String?;
    return Map<String, dynamic>.from(data['user'] as Map);
  }

  Future<void> logout() async {
    try {
      await _request('POST', '/api/v1/auth/logout');
    } finally {
      _token = null;
    }
  }

  Future<List<Map<String, dynamic>>> catalog() async {
    final data = await _request('GET', '/api/v1/catalog', authenticated: false);
    return _asMaps(data);
  }

  Future<List<Map<String, dynamic>>> customers({String search = ''}) async {
    final query = search.trim().isEmpty
        ? ''
        : '?search=${Uri.encodeQueryComponent(search.trim())}';
    final data = await _request('GET', '/api/v1/customers$query');
    return _asMaps(data is Map ? data['data'] : data);
  }

  Future<Map<String, dynamic>> customerStats() async {
    final data = await _request('GET', '/api/v1/customers/stats');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> inquiries({String search = ''}) async {
    final query = search.trim().isEmpty
        ? ''
        : '?search=${Uri.encodeQueryComponent(search.trim())}';
    final data = await _request('GET', '/api/v1/inquiries$query');
    return _asMaps(data is Map ? data['data'] : data);
  }

  Future<void> createCustomer({
    required String name,
    required String type,
  }) async {
    await _request(
      'POST',
      '/api/v1/customers',
      body: {'name': name, 'type': type, 'acquisition_channel': 'other'},
    );
  }

  Future<void> createInquiry({
    required String subject,
    required String contactName,
    required String description,
    required String source,
    String? contactPhone,
  }) async {
    await _request(
      'POST',
      '/api/v1/inquiries',
      body: {
        'subject': subject,
        'contact_name': contactName,
        'description': description,
        'source': source,
        if (contactPhone != null && contactPhone.trim().isNotEmpty)
          'contact_phone': contactPhone.trim(),
      },
    );
  }

  Future<void> qualifyInquiry(int id) async {
    await _request('PATCH', '/api/v1/inquiries/$id/qualify');
  }

  Future<void> sendInquiryQuote(int id, double amount) async {
    await _request(
      'PATCH',
      '/api/v1/inquiries/$id/quote',
      body: {'quote_amount': amount},
    );
  }

  Future<void> refuseInquiry(int id, String reason) async {
    await _request(
      'PATCH',
      '/api/v1/inquiries/$id/refuse',
      body: {'reason': reason},
    );
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    late http.Response response;
    try {
      switch (method) {
        case 'POST':
          response = await _client.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
        case 'GET':
          response = await _client.get(uri, headers: headers);
        case 'PATCH':
          response = await _client.patch(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
        default:
          throw UnsupportedError('HTTP method non pris en charge: $method');
      }
    } on Object catch (error) {
      if (error is UnsupportedError) rethrow;
      throw ApiException(
        'Serveur inaccessible. Vérifie l’adresse de l’API et le réseau.',
      );
    }

    final decoded = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        decoded['message'] as String? ?? 'La requête a échoué.',
        statusCode: response.statusCode,
        errors: decoded['errors'] is Map
            ? Map<String, dynamic>.from(decoded['errors'] as Map)
            : null,
      );
    }
    return decoded['data'];
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final value = jsonDecode(body);
      if (value is Map<String, dynamic>) return value;
      throw const FormatException();
    } on FormatException {
      throw const ApiException(
        'La réponse du serveur n’est pas un JSON valide.',
      );
    }
  }

  List<Map<String, dynamic>> _asMaps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
