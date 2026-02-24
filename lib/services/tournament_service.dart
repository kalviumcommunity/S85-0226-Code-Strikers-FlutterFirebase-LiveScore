import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fixture.dart';
import '../models/tournament.dart';
import 'auth_service.dart';

class TournamentService {
  static const String baseUrl = "http://127.0.0.1:8080";

  /// ===============================
  /// FETCH ALL TOURNAMENTS
  /// ===============================
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

  /// ===============================
  /// ADMIN CREATE TOURNAMENT
  /// ===============================
  static Future<bool> createTournament({
    required String name,
    required String location,
    required String sports,
    required DateTime startDate,
    required DateTime endDate,
    required int totalTeams,
    required int requiredPlayer,
    required String registration,
  }) async {
    final url = "$baseUrl/api/admin/tournaments";

    final body = {
      "name": name,
      "location": location,
      "sports": sports,
      "startDate": startDate.toUtc().toIso8601String(),
      "endDate": endDate.toUtc().toIso8601String(),
      "totalTeams": totalTeams,
      "requiredPlayer": requiredPlayer,

      /// ⚠️ IMPORTANT — match backend field name
      "registeration": registration,
    };

    print("CREATE TOURNAMENT BODY => ${jsonEncode(body)}");

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("CREATE STATUS => ${response.statusCode}");
    print("CREATE BODY => ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// ===============================
  /// TOURNAMENT TEAMS
  /// ===============================
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

  /// ===============================
  /// SHUFFLE FIXTURES
  /// ===============================
  static Future<bool> shuffleFixtures({
    required String tournamentId,
    required String sport,
  }) async {
    final response = await http.post(
      Uri.parse(
          "$baseUrl/tournaments/$tournamentId/fixtures/shuffle?sport=$sport"),
      headers: AuthService.authHeader,
    );

    return response.statusCode == 200;
  }

  /// ===============================
  /// GET FIXTURES
  /// ===============================
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
  static Future<String> registerTeam({
    required String teamId,
    required String tournamentId,
  }) async {
    final url = Uri.parse("$baseUrl/api/team/$teamId/register/$tournamentId");

    final response = await http.post(url, headers: AuthService.authHeader);

    if (response.statusCode == 200) {
      return response.body;
    }

    throw Exception(response.body);
  }
  static Future<List<Map<String, dynamic>>> getMatches(
      String tournamentId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/tournaments/$tournamentId/matches"),
      headers: AuthService.authHeader,
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception("Failed to load matches");
  }
  static Future<List<Map<String, dynamic>>> getTeamMembers(
      String teamId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/team/get/$teamId/members"),
      headers: AuthService.authHeader,
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception("Failed to load team members");
  }
  static Future<void> startInnings({
    required String tournamentId,
    required String matchId,
    required String strikerId,
    required String nonStrikerId,
    required String bowlerId,
  }) async {
    final url =
        "$baseUrl/tournaments/$tournamentId/matches/$matchId/cricket/start-innings"
        "?strikerId=$strikerId"
        "&nonStrikerId=$nonStrikerId"
        "&bowlerId=$bowlerId";

    final res = await http.post(
      Uri.parse(url),
      headers: AuthService.authHeader,
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception("Failed to start innings");
    }
  }
  static Future<void> startMatch({
    required String tournamentId,
    required String matchId,
  }) async {
    final url = "$baseUrl/tournaments/$tournamentId/matches/$matchId/start";

    final res = await http.post(
      Uri.parse(url),
      headers: AuthService.authHeader,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to start match");
    }
  }
  static Future<void> updateBall({
    required String tournamentId,
    required String matchId,
    required int runs,
    required bool wicket,
  }) async {
    final url =
        "$baseUrl/tournaments/$tournamentId/matches/$matchId/cricket/ball"
        "?runs=$runs"
        "&wicket=$wicket";

    final res = await http.post(
      Uri.parse(url),
      headers: AuthService.authHeader,
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update ball");
    }
  }
}