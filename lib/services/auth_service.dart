import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:livescore/config/firebase_config.dart'; // ✅ import config

class AuthService {
  // 🔹 Spring Boot base URL
  static const String baseUrl = "http://10.46.33.20:8080";

  // 🔹 Endpoints
  static const String signupUrl = "$baseUrl/auth/signup";
  static const String meUrl = "$baseUrl/auth/me";

  // =============================
  // SIGNUP → Spring Boot
  // =============================
  static Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(signupUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "photoUrl": ""
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // =============================
  // LOGIN → Firebase REST
  // =============================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(FirebaseConfig.signInUrl), // ✅ from config
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "returnSecureToken": true
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        "success": true,
        "idToken": data["idToken"],
        "uid": data["localId"]
      };
    } else {
      return {
        "success": false,
        "message": data["error"]?["message"] ?? "Login failed"
      };
    }
  }

  // =============================
  // FETCH USER → Spring Boot /auth/me
  // =============================
  static Future<Map<String, dynamic>> getMe(String idToken) async {
    final response = await http.get(
      Uri.parse(meUrl),
      headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
        "user": jsonDecode(response.body),
      };
    } else {
      return {
        "success": false,
        "message": response.body,
      };
    }
  }
}