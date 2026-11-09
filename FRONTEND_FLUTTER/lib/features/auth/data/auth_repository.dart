import 'package:apc_frontend/data/apc_api.dart';

class AuthRepository {
  const AuthRepository(this._api);

  final ApcApi _api;

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) {
    return _api.login(email: email, password: password);
  }

  Future<void> signOut() => _api.logout();
}