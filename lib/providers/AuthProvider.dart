// import 'package:flutter/material.dart';
// import 'package:pro_2/models/user_profile.dart';
// import 'package:pro_2/services/api.dart';

// class AuthProvider extends ChangeNotifier {
//   User? _user;
//   String? _accessToken;

//   /// ================= Getters =================
//   User? get user => _user;
//   String? get accessToken => _accessToken;
//   bool get isLoggedIn => _user != null && _accessToken != null;

//   /// ================= Set User =================
//   void setUser(User user) {
//     _user = user;
//     notifyListeners();
//   }

//   /// ================= Set Token =================
//   void setToken(String token) {
//     _accessToken = token;
//     notifyListeners();
//   }

//   /// ================= Login =================
//   Future<bool> login(String email, String password) async {
//     final result = await ApiService.login(email, password);

//     if (result['success'] == true && result['data'] != null) {
//       final data = result['data'];
//       final token = data['access'] ?? ''; // تأكد من وجود access
//       final userJson = data['user'] ?? {}; // تأكد من وجود user

//       if (token.isNotEmpty && userJson.isNotEmpty) {
//         _accessToken = token;
//         _user = User.fromJson(userJson);
//         notifyListeners();
//         return true;
//       } else {
//         // data موجود بس بدون access أو user
//         print("Login data incomplete: $data");
//         return false;
//       }
//     } else {
//       print("Login failed: ${result['error']}");
//       return false;
//     }
//   }

//   /// ================= Register + Auto Login =================
//   Future<bool> registerAndLogin(Map<String, dynamic> userData) async {
//     final result = await ApiService.registerAndLogin(userData);

//     if (result['success']) {
//       _accessToken = result['token'];
//       _user = User.fromJson(result['user']);
//       notifyListeners();
//       return true;
//     }
//     return false;
//   }

//   /// ================= Logout =================
//   Future<void> logout() async {
//     _user = null;
//     _accessToken = null;
//     await ApiService.logout(); // يمسح التوكن من API Service
//     notifyListeners();
//   }

//   /// ================= Update User =================
//   void updateUser(User updatedUser) {
//     _user = updatedUser;
//     notifyListeners();
//   }
// }
