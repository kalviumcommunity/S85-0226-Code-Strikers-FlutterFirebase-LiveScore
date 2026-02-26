import 'package:flutter/material.dart';
import '../../services/live_score_socket.dart';

class LiveScoreScreen extends StatefulWidget {
  final String tournamentId;   // ⭐ add
  final String matchId;

  const LiveScoreScreen({
    super.key,
    required this.tournamentId,
    required this.matchId,
  });

  @override
  State<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends State<LiveScoreScreen> {
  final socket = LiveScoreSocket();
  Map<String, dynamic>? live;

  @override
  void initState() {
    super.initState();

    socket.connect(
      tournamentId: widget.tournamentId,
      matchId: widget.matchId,
      onData: (data) {
        setState(() {
          live = data;   // ⭐ correct variable
        });
      },
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (live == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("LIVE MATCH")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// MATCH TITLE
            Center(
              child: Text(
                "${live!["teamAName"]} vs ${live!["teamBName"]}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// SCORE
            Center(
              child: Column(
                children: [
                  Text(
                    "${live!["scoreA"]}/${live!["wicketsA"]} (${live!["oversA"]})",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    "${live!["scoreB"]}/${live!["wicketsB"]} (${live!["oversB"]})",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// CURRENT PLAYERS
            const Text(
              "On Field",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            Text("Striker: ${live!["strikerName"] ?? "-"}"),
            Text("Non-Striker: ${live!["nonStrikerName"] ?? "-"}"),
            Text("Bowler: ${live!["bowlerName"] ?? "-"}"),

            const SizedBox(height: 20),

            /// TEAM A PLAYERS
            const Text(
              "Team A Players",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            ...((live!["teamAPlayers"] as List?) ?? [])
                .map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(p.toString()),
            ))
                .toList(),

            const SizedBox(height: 20),

            /// TEAM B PLAYERS
            const Text(
              "Team B Players",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            ...((live!["teamBPlayers"] as List?) ?? [])
                .map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(p.toString()),
            ))
                .toList(),
          ],
        ),
      ),
    );
  }
}