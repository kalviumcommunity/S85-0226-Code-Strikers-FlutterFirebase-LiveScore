import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // 🔹 Spring Boot base URL
  static const String baseUrl = "http://10.46.33.20:8080";

  // 🔹 Firebase API key
  static const String firebaseApiKey =
      "AIzaSyAvJo-TShqKa3cKR0-SvIIIfr8KNLYFwC4";

  // 🔹 Endpoints
  static const String signupUrl = "$baseUrl/auth/signup";
  static const String meUrl = "$baseUrl/auth/me";

  static String firebaseLoginUrl =
      "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$firebaseApiKey";

  // =============================
  // SIGNUP → Spring Boot
  // =============================
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true};
      } else {
        return {
          "success": false,
          "message": response.body
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error"
      };
    }
  }

  // =============================
  // LOGIN → Firebase REST
  // =============================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(firebaseLoginUrl),
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
          "uid": data["localId"],
          "email": data["email"],
        };
      } else {
        return {
          "success": false,
          "message": data["error"]?["message"] ?? "Invalid credentials"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error"
      };
    }
  }

  // =============================
  // FETCH USER → Spring Boot /auth/me
  // =============================
  static Future<Map<String, dynamic>> getMe(String idToken) async {
    try {
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
          "message": "Unauthorized"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error"
      };
    }
  }
}