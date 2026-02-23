import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://127.0.1.1:8080";
  static const String firebaseApiKey =
      "AIzaSyAvJo-TShqKa3cKR0-SvIIIfr8KNLYFwC4";

  static const String meUrl = "$baseUrl/auth/me";

  static String firebaseLoginUrl =
      "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$firebaseApiKey";

  /// GLOBAL AUTH STATE
  static String? token;
  static String? role;
  static String? userId;

  /* ================= LOGIN ================= */

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
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
      token = data["idToken"];

      print("LOGIN TOKEN OK");
      print("TOKEN = $token");

      return {"success": true};
    }

    return {
      "success": false,
      "message": data["error"]?["message"] ?? "Invalid credentials"
    };
  }

  /* ================= GET ME ================= */

  static Future<Map<String, dynamic>> getMe() async {
    print("CALLING /auth/me");
    print("TOKEN = $token");

    final response = await http.get(
      Uri.parse(meUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("ME STATUS = ${response.statusCode}");
    print("ME BODY = ${response.body}");

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);

      /// ⭐⭐⭐ STORE ID + ROLE
      userId = user["id"]?.toString();
      role = user["role"]?.toString();

      print("AUTH USER ID = $userId");
      print("AUTH ROLE = $role");

      return {"success": true, "user": user};
    }

    return {"success": false, "message": "Unauthorized"};
  }
  static bool isUser() {
    return role == "USER" || role == "ROLE_USER";
  }
  static bool isLeader() => role == "TEAM_LEADER";
}