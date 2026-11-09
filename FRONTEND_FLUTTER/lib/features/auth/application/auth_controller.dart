import 'package:flutter/foundation.dart';

import 'package:apc_frontend/features/auth/data/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  Map<String, dynamic>? _user;
  bool _loading = false;

  Map<String, dynamic>? get user => _user;
  bool get loading => _loading;

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _repository.signIn(email: email, password: password);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
    } finally {
      _user = null;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}