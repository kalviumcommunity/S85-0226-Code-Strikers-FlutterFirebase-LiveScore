import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/team/team.dart';
import '../models/team/team_join_request.dart';
import 'auth_service.dart';

class TeamService {
  static const String baseUrl = "http://127.0.0.1:8080";

  static Map<String, String> get _headers => {
    "Authorization": "Bearer ${AuthService.token}",
    "Content-Type": "application/json",
  };

  /* ================= TEAMS ================= */

  static Future<List<Team>> fetchTeams() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/team/teams"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Team.fromJson(e)).toList();
    }

    throw Exception("Failed to load teams");
  }

  static Future<bool> createTeam({
    required String name,
    required int maxPlayers,
    required String sports,
  }) async {
    final uri = Uri.parse("$baseUrl/api/team/create").replace(
      queryParameters: {
        "name": name,
        "maxPlayers": maxPlayers.toString(),
        "sports": sports,
      },
    );

    final response = await http.post(uri, headers: _headers);

    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<Team> fetchTeamById(String teamId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/team/get/$teamId"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Team.fromJson(data);
    }

    throw Exception("Failed to load team");
  }

  /* ================= JOIN REQUEST ================= */

  /// Send join request
  static Future<bool> sendJoinRequest(String teamId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/teams/$teamId/requests"),
      headers: _headers,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Check if current user already requested
  static Future<bool> hasRequested(String teamId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/teams/$teamId/requests/me"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["requested"] == true;
    }

    return false;
  }

  /// GET all requests for a team (TEAM_LEADER)
  static Future<List<TeamJoinRequest>> getRequests(String teamId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/teams/$teamId/requests"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TeamJoinRequest.fromJson(e)).toList();
    }

    throw Exception("Failed to load requests");
  }

  /// APPROVE request
  static Future<bool> approveRequest(
      String teamId, String requestId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/teams/$teamId/requests/$requestId/approve"),
      headers: _headers,
    );

    return response.statusCode == 200;
  }

  /// REJECT request
  static Future<bool> rejectRequest(
      String teamId, String requestId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/teams/$teamId/requests/$requestId/reject"),
      headers: _headers,
    );

    return response.statusCode == 200;
  }
  static Future<List<Map<String, dynamic>>> getTeamMembers(String teamId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/team/get/$teamId/members"),
      headers: AuthService.authHeader,
    );

    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(res.body));
    }

    throw Exception("Failed to load team members");
  }

}