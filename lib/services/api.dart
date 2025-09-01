// api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pro_2/services/token_manager.dart';

class ApiService {
  static const String baseUrl = "http://192.168.1.102:8000/api/Journalist";
  static const String baseUrl1 = "http://192.168.1.102:8000/api";

  /// تسجيل الدخول
  /// تسجيل الدخول
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/login/");
    try {
      print("Sending login request to: $url");
      print("Body: {email: $email, password: $password}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Login response status: ${response.statusCode}");
      print("Login response body: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['status'] == 'success') {
        final token = decoded['data']['access'];
        await TokenManager.saveToken(token);
        await TokenManager.saveUserData(decoded['data']);

        final savedToken = await TokenManager.getToken();
        print("✅ Saved token: $savedToken");

        return {"success": true, "data": decoded['data']};
      } else {
        return {"success": false, "error": decoded};
      }
    } catch (e) {
      print("Login exception: $e");
      return {"success": false, "error": e.toString()};
    }
  }

  /// جلب بيانات البروفايل
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        return {"success": false, "error": "Token not found"};
      }

      final url = Uri.parse("$baseUrl/profile/");
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("📡 GET ${url.toString()}");
      print("🔑 Token: $token");
      print("📥 Response (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return {"success": true, "data": jsonBody["data"]};
      } else {
        return {
          "success": false,
          "error": "Status ${response.statusCode}: ${response.body}",
        };
      }
    } catch (e) {
      print("❌ Error in getProfile: $e");
      return {"success": false, "error": e.toString()};
    }
  }

  /// تحديث البروفايل مع الصورة
  /// تحديث البروفايل
  static Future<Map<String, dynamic>> updateProfile({
    required String? firstName,
    required String? lastName,
    required String? specialization,
    File? image,
  }) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        return {"success": false, "error": "Token not found"};
      }

      final url = Uri.parse("$baseUrl/profile/update/");
      print("📡 PUT ${url.toString()}");
      print("🔑 Token: $token");

      // 🔹 Multipart request (بحال في صورة)
      var request = http.MultipartRequest("PUT", url);
      request.headers["Authorization"] = "Bearer $token";

      if (firstName != null) request.fields["first_name"] = firstName;
      if (lastName != null) request.fields["last_name"] = lastName;
      if (specialization != null) request.fields["specialty"] = specialization;

      if (image != null) {
        final imgStream = http.ByteStream(image.openRead());
        final imgLength = await image.length();
        final multipartFile = http.MultipartFile(
          "profile_picture",
          imgStream,
          imgLength,
          filename: image.path.split("/").last,
        );
        request.files.add(multipartFile);
        print("🖼️ Attached image: ${image.path}");
      }

      print("📤 Sending fields: ${request.fields}");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("📥 Response (${response.statusCode}): $responseBody");

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(responseBody);
        return {"success": true, "data": jsonBody["data"]};
      } else {
        return {
          "success": false,
          "error": "Status ${response.statusCode}: $responseBody",
        };
      }
    } catch (e) {
      print("❌ Error in updateProfile: $e");
      return {"success": false, "error": e.toString()};
    }
  }
  // داخل ApiService

  static Future<Map<String, dynamic>> registerUser({
    required String first_name,
    required String last_name,
    required String email,
    required String specialty,
    required String password,
    required String password2,
  }) async {
    final url = Uri.parse('$baseUrl/register/');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "first_name": first_name,
          "last_name": last_name,
          "email": email,
          "specialty": specialty,
          "password": password,
          "password2": password2,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "error": data};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  /// حذف الحساب
  static Future<Map<String, dynamic>> deleteAccount(String password) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        return {"success": false, "error": "User not logged in"};
      }

      final url = Uri.parse('${baseUrl}/delete-account/');
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"password": password}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // نجاح الحذف
        return {"success": true};
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "error": data['message'] ?? "Failed to delete account",
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> uploadAudioFile(File audioFile) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        return {"success": false, "message": "User not logged in"};
      }

      final uri = Uri.parse('$baseUrl1/Interviews/create/');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('audio_file', audioFile.path),
      );

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      print("🔹 Transcription API result: $respStr");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "message": respStr};
      } else {
        return {"success": false, "message": respStr};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // تابع نسيان كلمة المرور بدون توكن
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}/forgot-password/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "message": data['message'],
          "data": data['data'],
        };
      } else {
        return {
          "success": false,
          "error": "Failed to send reset email",
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getRecipients(String token) async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.102:8000/api/Journalist/recipients/"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data['data']};
      } else {
        return {"success": false, "error": "Failed to fetch recipients"};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }
}
