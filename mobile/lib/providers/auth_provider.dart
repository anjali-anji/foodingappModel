import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/fcm_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _userKey = 'auth_user';

  UserModel? _user;
  bool restoring = true;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null && ApiService.instance.token != null;

  Future<void> restoreSession() async {
    restoring = true;
    notifyListeners();
    await ApiService.instance.loadToken();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (ApiService.instance.token != null && raw != null) {
      _user = UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      debugPrint('SESSION RESTORED user=${_user?.email}');
    } else {
      _user = null;
      debugPrint('SESSION NONE — show login');
    }
    restoring = false;
    notifyListeners();
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user == null) {
      await prefs.remove(_userKey);
    } else {
      await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
    }
  }

  Future<void> login(String email, String password) async {
    debugPrint('LOGIN API ${ApiConstants.baseUrl}${ApiConstants.login} email=$email');
    final json = await ApiService.instance.post(ApiConstants.login, {
      'email': email.trim(),
      'password': password,
      'fcm_token': FcmService.instance.token,
    });
    await ApiService.instance.setToken(json['token'] as String);
    _user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    await _saveUser();
    debugPrint('LOGIN OK user=${_user?.email}');
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    debugPrint('REGISTER API ${ApiConstants.register} email=$email');
    final json = await ApiService.instance.post(ApiConstants.register, {
      'name': name.trim(),
      'email': email.trim(),
      'mobile': mobile.trim(),
      'password': password,
      'fcm_token': FcmService.instance.token,
    });
    await ApiService.instance.setToken(json['token'] as String);
    _user = UserModel.fromJson(json['user'] as Map<String, dynamic>);
    await _saveUser();
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await ApiService.instance.setToken(null);
    await _saveUser();
    notifyListeners();
  }
}
