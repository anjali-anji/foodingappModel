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

  Future<void> _resolveBaseUrl() async {
    if (_resolved) return;
    for (final url in ApiConstants.baseUrlCandidates) {
      debugPrint('API TRY $url/');
      try {
        final res = await http
            .get(Uri.parse('$url/'))
            .timeout(const Duration(seconds: 3));
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
    debugPrint('API NONE WORKED, using ${ApiConstants.baseUrl}');
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    await _resolveBaseUrl();
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    debugPrint('API POST $uri');
    debugPrint('API BODY ${_safeBody(body)}');
    try {
      final res = await http
          .post(
            uri,
            headers: _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 12));
      debugPrint('API POST STATUS ${res.statusCode}');
      debugPrint('API POST RESPONSE ${res.body}');
      return _decode(res);
    } catch (e) {
      debugPrint('API POST ERROR $uri => $e');
      throw ApiException(
        'Server nahi mila. Backend chalu hai? USB ke liye adb reverse, ya same Wi-Fi. ($e)',
      );
    }
  }

  Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    await _resolveBaseUrl();
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    debugPrint('API GET $uri');
    try {
      final res = await http
          .get(uri, headers: _headers(auth: auth))
          .timeout(const Duration(seconds: 12));
      debugPrint('API GET STATUS ${res.statusCode}');
      debugPrint('API GET RESPONSE ${res.body}');
      return _decode(res);
    } catch (e) {
      debugPrint('API GET ERROR $uri => $e');
      throw ApiException(
        'Server nahi mila. Backend chalu hai? USB ke liye adb reverse, ya same Wi-Fi. ($e)',
      );
    }
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
