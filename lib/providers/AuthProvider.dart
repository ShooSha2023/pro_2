import 'package:flutter/material.dart';
import 'package:pro_2/models/user_profile.dart';
import 'package:pro_2/services/api.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _accessToken;

  /// ================= Getters =================
  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _user != null && _accessToken != null;

  /// ================= Set User =================
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  /// ================= Set Token =================
  void setToken(String token) {
    _accessToken = token;
    notifyListeners();
  }

  /// ================= Login =================
  Future<bool> login(String email, String password) async {
    final result = await ApiService.login(email, password);

    if (result['success']) {
      final data = result['data'];
      _accessToken = data['token'];
      _user = User.fromJson(data['user']);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// ================= Register + Auto Login =================
  Future<bool> registerAndLogin(Map<String, dynamic> userData) async {
    final result = await ApiService.registerAndLogin(userData);

    if (result['success']) {
      _accessToken = result['token'];
      _user = User.fromJson(result['user']);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// ================= Logout =================
  Future<void> logout() async {
    _user = null;
    _accessToken = null;
    await ApiService.logout(); // يمسح التوكن من API Service
    notifyListeners();
  }

  /// ================= Update User =================
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}
