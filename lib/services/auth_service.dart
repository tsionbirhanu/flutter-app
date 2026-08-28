import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_service.dart';

class AuthService {
  AuthService(this._api, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'wallet_jwt';

  final ApiService _api;
  final FlutterSecureStorage _storage;

  Future<String?> loadToken() async {
    final token = await _storage.read(key: _tokenKey);
    _api.setToken(token);
    return token;
  }

  Future<String> login({
    required String phoneNumber,
    required String pin,
  }) async {
    final json = await _api.post(
      '/customer/login',
      body: {'phone_number': phoneNumber, 'pin': pin},
    );
    final token = '${json['token'] ?? json['jwt'] ?? json['accessToken'] ?? ''}';
    if (token.isEmpty) {
      throw ApiException('Login succeeded but no token was returned.');
    }
    await _storage.write(key: _tokenKey, value: token);
    _api.setToken(token);
    return token;
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    _api.setToken(null);
  }
}
