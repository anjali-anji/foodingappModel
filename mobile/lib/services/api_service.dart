import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const _tokenKey = 'auth_token';
  String? _token;
  bool _resolved = false;

  String? get token => _token;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> setToken(String? value) async {
    _token = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, value);
    }
  }

  Map<String, String> _headers({bool auth = false}) {
    return {
      'Content-Type': 'application/json',
      if (auth && _token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Map<String, dynamic> _safeBody(Map<String, dynamic> body) {
    final copy = Map<String, dynamic>.from(body);
    if (copy.containsKey('password')) copy['password'] = '***';
    return copy;
  }

  List<String> _urlsToTry() {
    final selected = ApiConstants.baseUrl;
    final rest = ApiConstants.baseUrlCandidates
        .where((url) => url != selected)
        .toList();
    return [selected, ...rest];
  }

  bool _isUnreachable(Object error) {
    final text = error.toString();
    return text.contains('SocketException') ||
        text.contains('Connection refused') ||
        text.contains('Failed host lookup') ||
        text.contains('Network is unreachable') ||
        text.contains('Connection timed out') ||
        text.contains('TimeoutException');
  }

  Duration _timeoutFor(String path) {
    if (path.contains('payment')) {
      return const Duration(seconds: 30);
    }
    return const Duration(seconds: 4);
  }

  Future<void> _resolveBaseUrl() async {
    if (_resolved) return;
    for (final url in ApiConstants.baseUrlCandidates) {
      debugPrint('API TRY $url/');
      try {
        final res = await http
            .get(Uri.parse('$url/'))
            .timeout(const Duration(milliseconds: 800));
        debugPrint('API TRY RESULT $url => ${res.statusCode} ${res.body}');
        if (res.statusCode == 200) {
          ApiConstants.baseUrl = url;
          _resolved = true;
          debugPrint('API SELECTED $url');
          return;
        }
      } catch (e) {
        debugPrint('API TRY FAIL $url => $e');
      }
    }
    debugPrint('API NONE WORKED, will retry per request');
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    await _resolveBaseUrl();
    debugPrint('API BODY ${_safeBody(body)}');
    return _send(
      path,
      (uri) => http.post(
        uri,
        headers: _headers(auth: auth),
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    await _resolveBaseUrl();
    return _send(
      path,
      (uri) => http.get(uri, headers: _headers(auth: auth)),
    );
  }

  Future<Map<String, dynamic>> _send(
    String path,
    Future<http.Response> Function(Uri uri) request,
  ) async {
    Object? lastError;
    for (final base in _urlsToTry()) {
      final uri = Uri.parse('$base$path');
      debugPrint('API CALL $uri');
      try {
        final res = await request(uri).timeout(_timeoutFor(path));
        debugPrint('API STATUS ${res.statusCode} $uri');
        debugPrint('API RESPONSE ${res.body}');
        ApiConstants.baseUrl = base;
        _resolved = true;
        return _decode(res);
      } catch (e) {
        lastError = e;
        debugPrint('API ERROR $uri => $e');
        if (!_isUnreachable(e)) {
          throw ApiException(e.toString());
        }
        _resolved = false;
      }
    }
    throw ApiException('Server not found');
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Server error (${res.statusCode})');
    }
    if (res.statusCode >= 400 || json['success'] == false) {
      throw ApiException(json['message']?.toString() ?? 'Request failed');
    }
    return json;
  }
}
