import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class ApiService {
  static const String baseUrl = "http://10.65.11.58:8000/api/Journalist";
  static String? _token; // ✅ نخزن التوكن داخلياً

  /// ================= Get current token =================
  static String? get token => _token;

  /// ================= Helper to safely decode JSON =================
  static dynamic _safeJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      return {"message": "Unexpected response from server", "raw": body};
    }
  }

  /// ================= Register Journalist =================
  static Future<Map<String, dynamic>> registerUser(User user) async {
    final url = Uri.parse("$baseUrl/register/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(user.toJson()),
      );

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {"success": true, "data": decoded};
      } else {
        return {"success": false, "error": decoded};
      }
    } catch (e) {
      return {"success": false, "error": "Request failed: $e"};
    }
  }

  /// ================= Register then Auto Login =================
  static Future<Map<String, dynamic>> registerAndLogin(
    Map<String, dynamic> data,
  ) async {
    final registerUrl = Uri.parse("$baseUrl/register/");
    try {
      final response = await http.post(
        registerUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // ✅ بعد التسجيل، نعمل Login تلقائي
        return await login(data["email"], data["password"]);
      } else {
        return {"success": false, "error": decoded};
      }
    } catch (e) {
      return {"success": false, "error": "Request failed: $e"};
    }
  }

  /// ================= Login =================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/login/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 && decoded["status"] == "success") {
        final data = decoded["data"];
        return {
          "success": true,
          "token": data["access"], // هنا التوكن الصحيح
          "user": data["user"], // بيانات المستخدم
        };
      } else {
        return {"success": false, "error": decoded};
      }
    } catch (e) {
      return {"success": false, "error": "Request failed: $e"};
    }
  }

  /// ================= Reset password =================
  static Future<Map<String, dynamic>> resetPassword(
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse("$baseUrl/reset-password/");
    try {
      if (_token == null) {
        return {"success": false, "error": "No token found"};
      }

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_token",
        },
        body: jsonEncode(data),
      );

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": decoded};
      } else {
        return {"success": false, "error": decoded};
      }
    } catch (e) {
      return {"success": false, "error": "Request failed: $e"};
    }
  }

  /// ================= Forgot password (لا يحتاج توكن) =================
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse("$baseUrl/forgot-password/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": decoded};
      } else {
        return {"success": false, "error": decoded};
      }
    } catch (e) {
      return {"success": false, "error": "Request failed: $e"};
    }
  }

  /// ================= Update profile =================
  static Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String specialization,
    File? image,
  }) async {
    final url = Uri.parse("$baseUrl/profile/update/");
    try {
      if (_token == null) {
        return {"success": false, "error": "No token found"};
      }

      var request = http.MultipartRequest("POST", url);
      request.headers["Authorization"] = "Bearer $_token";

      request.fields["first_name"] = firstName;
      request.fields["last_name"] = lastName;
      request.fields["specialization"] = specialization;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath("image", image.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": decoded};
      } else {
        return {"success": false, "error": decoded};
      }
    } catch (e) {
      return {"success": false, "error": "Request failed: $e"};
    }
  }

  /// ================= Logout =================
  static Future<void> logout() async {
    _token = null; // ✅ مسحنا التوكن من الميموري
    // إذا عم تستخدم sharedPreferences أو secureStorage، امسحها كمان
    // await SharedPreferences.getInstance().then((prefs) => prefs.remove("token"));
  }
}
