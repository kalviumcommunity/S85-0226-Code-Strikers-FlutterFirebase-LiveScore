import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/live_score_socket.dart';

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

class _LiveScoreScreenState extends State<LiveScoreScreen>
    with SingleTickerProviderStateMixin {
  final socket = LiveScoreSocket();
  Map<String, dynamic>? live;
  late TabController _tabController;

  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color liveRed = const Color(0xFFEF4444);
  final Color primaryPurple = const Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _fetchInitialData(); // API first
    _connectSocket(); // then realtime
  }

  Future<void> _fetchInitialData() async {
    try {
      final res = await http.get(Uri.parse(
          "https://livescorebackend-production.up.railway.app/live/${widget.tournamentId}"));

      if (res.statusCode == 200) {
        List list = json.decode(res.body);

        final match =
        list.firstWhere((m) => m["matchId"] == widget.matchId, orElse: () => null);

        if (match != null && mounted) {
          setState(() => live = Map<String, dynamic>.from(match));
        }
      }
    } catch (e) {
      debugPrint("Initial fetch error: $e");
    }
  }

  void _connectSocket() {
    socket.connect(
      tournamentId: widget.tournamentId,
      matchId: widget.matchId,
      onData: (data) {
        if (!mounted) return;
        setState(() => live = data);
      },
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (live == null) {
      return Scaffold(
        backgroundColor: darkBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _liveAppBarTitle(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildMainScorecard(),
          const SizedBox(height: 12),
          _buildOnFieldStats(),
          const SizedBox(height: 12),
          _buildBattingTable(live!["battingA"]),
          const SizedBox(height: 10),
          _buildBowlingTable(live!["bowlingB"]),
          const SizedBox(height: 12),
          _buildSquadTabs(),
        ],
      ),
    );
  }

  /// APP BAR
  Widget _liveAppBarTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: liveRed, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        const Text("LIVE SCORECARD",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }

  /// MAIN SCORE
  Widget _buildMainScorecard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _teamInnings(
              live!["teamAName"],
              live!["scoreA"],
              live!["wicketsA"],
              live!["oversA"],
              true),
          const Text("VS", style: TextStyle(color: Colors.white24)),
          _teamInnings(
              live!["teamBName"],
              live!["scoreB"],
              live!["wicketsB"],
              live!["oversB"],
              false),
        ],
      ),
    );
  }

  Widget _teamInnings(
      String name, dynamic runs, dynamic wickets, dynamic overs, bool lead) {
    return Column(
      children: [
        Text(name,
            style: TextStyle(
                color: lead ? Colors.white : Colors.white54,
                fontWeight: FontWeight.bold)),
        Text("$runs/$wickets",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900)),
        Text("$overs ov",
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  /// ON FIELD
  Widget _buildOnFieldStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration:
      BoxDecoration(color: cardBg.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _fieldRow("Striker", live!["strikerName"]),
          _fieldRow("Non-Striker", live!["nonStrikerName"]),
          _fieldRow("Bowler", live!["bowlerName"]),
        ],
      ),
    );
  }

  Widget _fieldRow(String label, String? name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38)),
          Text(name ?? "-", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  /// BATTING TABLE
  Widget _buildBattingTable(List players) {
    if (players.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: cardBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: Text("Batting",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const Divider(color: Colors.white10),
          ...players.map<Widget>((p) {
            return Row(
              children: [
                Expanded(flex: 3, child: Text(p["playerName"], style: const TextStyle(color: Colors.white))),
                Expanded(child: Text("${p["runs"]}", style: const TextStyle(color: Colors.white))),
                Expanded(child: Text("${p["balls"]}", style: const TextStyle(color: Colors.white))),
                Expanded(child: Text("${p["fours"]}", style: const TextStyle(color: Colors.white))),
                Expanded(child: Text("${p["sixes"]}", style: const TextStyle(color: Colors.white))),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  /// BOWLING TABLE
  Widget _buildBowlingTable(List players) {
    if (players.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: cardBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: Text("Bowling",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const Divider(color: Colors.white10),
          ...players.map<Widget>((p) {
            double overs = (p["balls"] ?? 0) / 6;
            return Row(
              children: [
                Expanded(flex: 3, child: Text(p["playerName"], style: const TextStyle(color: Colors.white))),
                Expanded(child: Text(overs.toStringAsFixed(1), style: const TextStyle(color: Colors.white))),
                Expanded(child: Text("${p["runs"]}", style: const TextStyle(color: Colors.white))),
                Expanded(child: Text("${p["wickets"]}", style: const TextStyle(color: Colors.white))),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  /// SQUAD
  Widget _buildSquadTabs() {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: accentCyan,
            labelColor: accentCyan,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: live!["teamAName"]),
              Tab(text: live!["teamBName"]),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _playerList(live!["teamAPlayers"]),
                _playerList(live!["teamBPlayers"]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerList(List? players) {
    if (players == null || players.isEmpty) {
      return const Center(
          child: Text("No Squad Data", style: TextStyle(color: Colors.white24)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(players[i].toString(),
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}