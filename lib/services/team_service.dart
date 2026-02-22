import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/team/team.dart';
import 'auth_service.dart';

class TeamService {
  static const String baseUrl = "http://10.46.33.20:8080";

  static Future<List<Team>> fetchTeams() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/team/teams"),
      headers: {
        "Authorization": "Bearer ${AuthService.token}",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Team.fromJson(e)).toList();
    }

    throw Exception("Failed to load teams");
  }
}