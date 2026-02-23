import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tournament.dart';
import 'auth_service.dart';

class TournamentService {
  static const String baseUrl = "http://127.0.0.1:8080";

  static Future<List<Tournament>> fetchTournaments() async {
    print("TOKEN USED => ${AuthService.token}");

    final response = await http.get(
      Uri.parse("$baseUrl/get/tournament"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
    );

    print("STATUS => ${response.statusCode}");
    print("BODY => ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Tournament.fromJson(e)).toList();
    }

    throw Exception("Failed tournaments ${response.statusCode}");
  }
}