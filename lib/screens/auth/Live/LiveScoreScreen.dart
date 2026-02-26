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
    // Constructing the WS URL: ws://127.0.0.1:8080/live/live-score/tournId/matchId
    final wsUrl = "ws://127.0.0.1:8080/live/live-score/${widget.tournamentId}/${widget.matchId}";

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
        title: const Text("Live Scorecard", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _errorState("Connection Error");
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Parsing the real-time JSON from WebSocket
          final data = json.decode(snapshot.data.toString());
          final match = data is List ? data[0] : data; // Handle if list or object

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeaderScore(match),
                const SizedBox(height: 20),
                _buildBattingTable(match["battingA"] ?? [], "Batting: ${match["teamAName"]}"),
                const SizedBox(height: 20),
                _buildBowlingTable(match["bowlingB"] ?? [], "Bowling: ${match["teamBName"]}"),
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
          Text(m["status"] ?? "LIVE", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _teamHeader(m["teamAName"], m["scoreA"], m["wicketsA"], m["oversA"]),
              const Text("VS", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
              _teamHeader(m["teamBName"], m["scoreB"], m["wicketsB"], m["oversB"]),
            ],
          ),
          const Divider(height: 30, color: Colors.white10),
          Text("Current Bowler: ${m["bowlerName"]}", style: TextStyle(color: accentCyan, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _teamHeader(name, score, wickets, overs) {
    return Column(
      children: [
        Text(name.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text("$score/$wickets", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
        Text("$overs Overs", style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildBattingTable(List players, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Table(
          columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
          children: [
            TableRow(children: [_th("Player"), _th("R"), _th("B")]),
            ...players.map((p) => TableRow(
                children: [
                  _td(p["playerName"], isMain: p["out"] == false),
                  _td(p["runs"].toString()),
                  _td(p["balls"].toString()),
                ]
            )).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildBowlingTable(List bowlers, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Table(
          columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
          children: [
            TableRow(children: [_th("Bowler"), _th("W"), _th("R")]),
            ...bowlers.map((b) => TableRow(
                children: [
                  _td(b["playerName"]),
                  _td(b["wickets"].toString()),
                  _td(b["runs"].toString()),
                ]
            )).toList(),
          ],
        ),
      ],
    );
  }

  Widget _th(String text) => Padding(padding: const EdgeInsets.all(8), child: Text(text, style: const TextStyle(color: Colors.white38, fontSize: 12)));
  Widget _td(String text, {bool isMain = false}) => Padding(padding: const EdgeInsets.all(8), child: Text(text, style: TextStyle(color: isMain ? Colors.orangeAccent : Colors.white, fontSize: 13)));

  Widget _errorState(String msg) => Center(child: Text(msg, style: const TextStyle(color: Colors.white54)));
}