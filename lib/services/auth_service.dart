import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://10.46.33.20:8080";

  static const String firebaseApiKey =
      "AIzaSyAvJo-TShqKa3cKR0-SvIIIfr8KNLYFwC4";

  static const String signupUrl = "$baseUrl/auth/signup";
  static const String meUrl = "$baseUrl/auth/me";

  static String firebaseLoginUrl =
      "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$firebaseApiKey";

  /// ⭐ GLOBAL TOKEN
  static String? token;

  /// =============================
  /// SIGNUP
  /// =============================
  static Future<Map<String, dynamic>> signup({
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true};
    }

    return {"success": false, "message": response.body};
  }

  /// =============================
  /// LOGIN (Firebase)
  /// =============================
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
      /// ⭐ STORE TOKEN HERE
      token = data["idToken"];

      return {
        "success": true,
        "idToken": data["idToken"],
        "uid": data["localId"],
        "email": data["email"],
      };
    }

    return {
      "success": false,
      "message": data["error"]?["message"] ?? "Invalid credentials"
    };
  }

  /// =============================
  /// FETCH USER
  /// =============================
  static Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse(meUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return {"success": true, "user": jsonDecode(response.body)};
    }

    return {"success": false, "message": "Unauthorized"};
  }
}