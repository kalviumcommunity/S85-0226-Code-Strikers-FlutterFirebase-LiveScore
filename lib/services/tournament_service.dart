import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fixture.dart';
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
  static Future<List<Map<String, dynamic>>> getTournamentTeams(
      String tournamentId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/tournament/$tournamentId/teams"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception("Failed to load tournament teams");
  }
  static Future<bool> shuffleFixtures(String tournamentId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/tournaments/$tournamentId/fixtures/shuffle"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
    );

    return response.statusCode == 200;
  }
  static Future<List<Fixture>> getFixtures(String tournamentId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/tournaments/$tournamentId/matches"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Fixture.fromJson(e)).toList();
    }

    throw Exception("Failed to load fixtures");
  }
}