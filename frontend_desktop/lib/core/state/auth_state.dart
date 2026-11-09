import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../models/company.dart';
import '../../models/fiscal_year.dart';
import '../network/api_client.dart';
import '../constants/api_endpoints.dart';

class AuthState extends ChangeNotifier {
  static final AuthState _instance = AuthState._internal();
  factory AuthState() => _instance;
  AuthState._internal();

  User? _currentUser;
  Company? _company;
  FiscalYear? _activeFiscalYear;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  Company? get company => _company;
  FiscalYear? get activeFiscalYear => _activeFiscalYear;
  bool get isAuthenticated => _isAuthenticated;

  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isSecretary => _currentUser?.role == 'secretary' || isAdmin;
  bool get isAccounting => _currentUser?.role == 'accounting' || isAdmin;

  Future<bool> login(String email, String password) async {
    try {
      final res = await ApiClient().post(ApiEndpoints.login, {
        'email': email,
        'password': password,
      });

      if (res['success'] == true) {
        final token = res['token'] as String;
        ApiClient().setToken(token);

        _currentUser = User.fromJson(res['user']);
        if (res['company'] != null) {
          _company = Company.fromJson(res['company']);
        }
        if (res['active_fiscal_year'] != null) {
          _activeFiscalYear = FiscalYear.fromJson(res['active_fiscal_year']);
        }
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      rethrow;
    }
  }

  void logout() {
    _currentUser = null;
    _company = null;
    _activeFiscalYear = null;
    _isAuthenticated = false;
    ApiClient().setToken(null);
    notifyListeners();
  }
}

