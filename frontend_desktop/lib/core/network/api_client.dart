import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic errors;

  ApiException(this.message, {this.statusCode = 500, this.errors});

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _authToken;

  void setToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers());
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de connexion avec le serveur : $e');
    }
  }

  Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de communication : $e');
    }
  }

  Future<Map<String, dynamic>> put(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de communication : $e');
    }
  }

  Future<Map<String, dynamic>> patch(String url, [Map<String, dynamic>? body]) async {
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: _headers(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erreur de communication : $e');
    }
  }

  /// Extraction robuste d'une liste à partir d'une réponse API ou d'un paginator Laravel
  /// Gère les cas : List directe, {'data': [...]}, {'nom_cle': {'data': [...]}}, ou {'nom_cle': [...]}
  static List<dynamic> extractList(dynamic response, [String? preferredKey]) {
    if (response == null) return [];
    if (response is List) return response;

    if (response is Map<String, dynamic>) {
      // 1. Si une clé spécifique a été demandée
      if (preferredKey != null && response.containsKey(preferredKey)) {
        final val = response[preferredKey];
        if (val is List) return val;
        if (val is Map<String, dynamic> && val['data'] is List) {
          return val['data'] as List;
        }
      }

      // 2. Format standard Laravel pagination direct : {'data': [...]}
      if (response['data'] is List) {
        return response['data'] as List;
      }

      // 3. Chercher dans les clés connues courantes
      for (final k in ['customers', 'orders', 'expenses', 'cash_flows', 'payments', 'users', 'inquiries', 'products', 'fiscal_years']) {
        if (response[k] is List) return response[k] as List;
        if (response[k] is Map<String, dynamic> && response[k]['data'] is List) {
          return response[k]['data'] as List;
        }
      }
    }

    return [];
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'data': data};
    }

    String message = 'Erreur HTTP ${response.statusCode}';
    if (data is Map) {
      if (data['message'] != null) {
        message = data['message'].toString();
      }
      if (data['errors'] != null && data['errors'] is Map) {
        final errorMap = data['errors'] as Map;
        final details = errorMap.values.expand((e) => e is List ? e : [e]).join('\n');
        if (details.isNotEmpty) {
          message = '$message\n$details';
        }
      }
    }

    throw ApiException(message, statusCode: response.statusCode, errors: data is Map ? data['errors'] : null);
  }
}
