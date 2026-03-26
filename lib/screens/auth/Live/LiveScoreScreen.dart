import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class LiveScoreScreen extends StatefulWidget {
  final String tournamentId;
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
  late WebSocketChannel channel;
  bool isConnected = false;

  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color accentCyan = const Color(0xFF22D3EE);

  @override
  void initState() {
    super.initState();
    connectToSocket();
  }

  void connectToSocket() {
    final wsUrl =
        "ws:https://livescore-backend-1otr.onrender.com/${widget.tournamentId}/${widget.matchId}";

    channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    setState(() => isConnected = true);
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Live Scorecard",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _errorState("Connection Error");
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = json.decode(snapshot.data.toString());
          Map match;

          if (data is List) {
            match = data.firstWhere(
                  (m) => m["matchId"].toString() == widget.matchId,
              orElse: () => data[0], // fallback
            );
          } else {
            match = data;
          }

          /// 🔥 FIX: Detect which team is batting
          bool isTeamABatting = (match["teamAPlayers"] ?? [])
              .contains(match["strikerName"]);

          final battingList = isTeamABatting
              ? match["battingA"]
              : match["battingB"];

          final battingTeamName = isTeamABatting
              ? match["teamAName"]
              : match["teamBName"];

          final bowlingList = isTeamABatting
              ? match["bowlingB"]
              : match["bowlingA"];

          final bowlingTeamName = isTeamABatting
              ? match["teamBName"]
              : match["teamAName"];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeaderScore(match),
                const SizedBox(height: 20),

                /// ✅ Dynamic Batting (FIXED)
                _buildBattingTable(
                    battingList ?? [], "Batting: $battingTeamName"),

                const SizedBox(height: 20),

                /// ✅ Dynamic Bowling (FIXED)
                _buildBowlingTable(
                    bowlingList ?? [], "Bowling: $bowlingTeamName"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderScore(Map m) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentCyan.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            m["status"] ?? "LIVE",
            style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _teamHeader(
                  m["teamAName"], m["scoreA"], m["wicketsA"], m["oversA"]),
              const Text("VS",
                  style: TextStyle(
                      color: Colors.white24, fontWeight: FontWeight.bold)),
              _teamHeader(
                  m["teamBName"], m["scoreB"], m["wicketsB"], m["oversB"]),
            ],
          ),
          const Divider(height: 30, color: Colors.white10),
          Text(
            "Striker: ${m["strikerName"]}",
            style: TextStyle(color: accentCyan, fontSize: 13),
          ),
          Text(
            "Non-Striker: ${m["nonStrikerName"]}",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            "Bowler: ${m["bowlerName"]}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _teamHeader(name, score, wickets, overs) {
    return Column(
      children: [
        Text(name.toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text("$score/$wickets",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900)),
        Text("$overs Overs",
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildBattingTable(List players, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1)
          },
          children: [
            TableRow(children: [_th("Player"), _th("R"), _th("B")]),
            ...players.map((p) => TableRow(children: [
              _td(p["playerName"],
                  isMain: p["out"] == false),
              _td(p["runs"].toString()),
              _td(p["balls"].toString()),
            ]))
          ],
        ),
      ],
    );
  }

  Widget _buildBowlingTable(List bowlers, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1)
          },
          children: [
            TableRow(children: [_th("Bowler"), _th("W"), _th("R")]),
            ...bowlers.map((b) => TableRow(children: [
              _td(b["playerName"]),
              _td(b["wickets"].toString()),
              _td(b["runs"].toString()),
            ]))
          ],
        ),
      ],
    );
  }

  Widget _th(String text) => Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text,
          style: const TextStyle(color: Colors.white38, fontSize: 12)));

  Widget _td(String text, {bool isMain = false}) => Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text,
          style: TextStyle(
              color: isMain ? Colors.orangeAccent : Colors.white,
              fontSize: 13)));

  Widget _errorState(String msg) =>
      Center(child: Text(msg, style: const TextStyle(color: Colors.white54)));
}