import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../live_score_screen.dart';

class TournamentMatchesScreen extends StatefulWidget {
  final String tournamentId;

  const TournamentMatchesScreen({
    super.key,
    required this.tournamentId,
  });

  @override
  State<TournamentMatchesScreen> createState() =>
      _TournamentMatchesScreenState();
}

class _TournamentMatchesScreenState extends State<TournamentMatchesScreen> {
  List matches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    final res = await http.get(
      Uri.parse(
        "http://10.0.2.2:8080/tournaments/${widget.tournamentId}/live-matches",
      ),
    );

    if (res.statusCode == 200) {
      setState(() {
        matches = json.decode(res.body);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Matches"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : matches.isEmpty
          ? const Center(
        child: Text(
          "No live matches",
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (_, i) {
          final m = matches[i];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveScoreScreen(
                    tournamentId: widget.tournamentId,
                    matchId: m["matchId"],
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TEAMS
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m["teamAName"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("VS"),
                      Text(
                        m["teamBName"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// SCORE
                  Text(
                    "${m["scoreA"]}/${m["wicketsA"]} (${m["oversA"]})",
                    style: const TextStyle(fontSize: 14),
                  ),

                  /// STATUS BADGE
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "LIVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}