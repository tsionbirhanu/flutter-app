import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiResponse {
  ApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final dynamic body;
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceFirst(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;
  String? _token;

  void setToken(String? token) => _token = token;

  Future<Map<String, dynamic>> getMap(String path) async {
    final response = await _client.get(_uri(path), headers: _headers());
    return _decodeMap(response);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await _client.get(_uri(path), headers: _headers());
    final decoded = _decode(response);
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      for (final key in ['data', 'items', 'transactions', 'notifications']) {
        final value = decoded[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? const {}),
    );
    return _decodeMap(response);
  }

  Future<ApiResponse> postRaw(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers(),
      body: jsonEncode(body ?? const {}),
    );
    final decoded = _decode(response);
    return ApiResponse(statusCode: response.statusCode, body: decoded);
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _headers() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    final decoded = _decode(response);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  dynamic _decode(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      const pinNotSetMessage = 'PIN not set for this account';
      final message = body is Map<String, dynamic>
          ? body.values.any((value) => '$value' == pinNotSetMessage)
              ? pinNotSetMessage
              : '${body['message'] ?? body['error'] ?? 'Request failed'}'
          : 'Request failed';
      throw ApiException(message, statusCode: response.statusCode);
    }
    return body;
  }
}
