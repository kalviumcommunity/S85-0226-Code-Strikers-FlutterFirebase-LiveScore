import 'dart:convert';
import 'dart:ui';
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

  // UI Colors
  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color liveRed = const Color(0xFFEF4444);
  final Color primaryPurple = const Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _fetchInitialData();
    _connectSocket();
  }

  // --- PRESERVED LOGIC START ---
  Future<void> _fetchInitialData() async {
    try {
      final res = await http.get(Uri.parse(
          "https://livescore-backend-1otr.onrender.com/live/${widget.tournamentId}"));

      print("API RESPONSE: ${res.body}");

      if (res.statusCode == 200) {
        List list = json.decode(res.body);

        if (list.isNotEmpty && mounted) {
          setState(() => live = Map<String, dynamic>.from(list[0]));
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
  // --- PRESERVED LOGIC END ---

  @override
  Widget build(BuildContext context) {
    if (live == null) {
      return Scaffold(
        backgroundColor: darkBg,
        body: Center(child: CircularProgressIndicator(color: accentCyan)),
      );
    }

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _liveAppBarTitle(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildMainScorecard(),
                const SizedBox(height: 16),
                _buildOnFieldStats(),
                const SizedBox(height: 16),
                _sectionTitle("BATTING PERFORMANCE"),
                _buildBattingTable(live!["battingA"]),
                const SizedBox(height: 16),
                _sectionTitle("BOWLING PERFORMANCE"),
                _buildBowlingTable(live!["bowlingB"]),
                const SizedBox(height: 16),
                _sectionTitle("TEAM SQUADS"),
              ],
            ),
          ),
          // Squad Tabs at the bottom for better UX
          SizedBox(
            height: 300,
            child: _buildSquadTabs(),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(title,
          style: TextStyle(color: accentCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  /// APP BAR WITH PULSING LIVE INDICATOR
  Widget _liveAppBarTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: liveRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: liveRed.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: liveRed, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          const Text("LIVE SCORECARD",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 1)),
        ],
      ),
    );
  }

  /// MAIN SCORECARD (Broadcast Style)
  Widget _buildMainScorecard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cardBg, cardBg.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _teamInnings(live!["teamAName"], live!["scoreA"], live!["wicketsA"], live!["oversA"], true),
          Column(
            children: [
              Text("VS", style: TextStyle(color: accentCyan.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 4),
              const Icon(Icons.bolt, color: Colors.amber, size: 16),
            ],
          ),
          _teamInnings(live!["teamBName"], live!["scoreB"], live!["wicketsB"], live!["oversB"], false),
        ],
      ),
    );
  }

  Widget _teamInnings(String name, dynamic runs, dynamic wickets, dynamic overs, bool lead) {
    return Column(
      children: [
        Text(name, style: TextStyle(color: lead ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Text("$runs/$wickets",
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
          child: Text("$overs ov", style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  /// ON FIELD (Glass Card)
  Widget _buildOnFieldStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _fieldRow("Striker", live!["strikerName"], Icons.sports_cricket, accentCyan),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white10, height: 1)),
          _fieldRow("Non-Striker", live!["nonStrikerName"], Icons.directions_run, Colors.white60),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white10, height: 1)),
          _fieldRow("Bowler", live!["bowlerName"], Icons.adjust, primaryPurple),
        ],
      ),
    );
  }

  Widget _fieldRow(String label, String? name, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        const Spacer(),
        Text(name ?? "-", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  /// BATTING TABLE (Clean Grid)
  Widget _buildBattingTable(List players) {
    if (players.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(children: const [
            Expanded(flex: 3, child: Text("BATSMAN", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
            Expanded(child: Text("R", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
            Expanded(child: Text("B", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
            Expanded(child: Text("4s", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
            Expanded(child: Text("6s", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 10),
          ...players.map<Widget>((p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Expanded(flex: 3, child: Text(p["playerName"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              Expanded(child: Text("${p["runs"]}", style: TextStyle(color: accentCyan, fontWeight: FontWeight.w900))),
              Expanded(child: Text("${p["balls"]}", style: const TextStyle(color: Colors.white70))),
              Expanded(child: Text("${p["fours"]}", style: const TextStyle(color: Colors.white38))),
              Expanded(child: Text("${p["sixes"]}", style: const TextStyle(color: Colors.white38))),
            ]),
          )).toList(),
        ],
      ),
    );
  }

  /// BOWLING TABLE
  Widget _buildBowlingTable(List players) {
    if (players.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(children: const [
            Expanded(flex: 3, child: Text("BOWLER", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
            Expanded(child: Text("O", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
            Expanded(child: Text("R", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
            Expanded(child: Text("W", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 10),
          ...players.map<Widget>((p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Expanded(flex: 3, child: Text(p["playerName"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              Expanded(child: Text("${((p["balls"] ?? 0) / 6).toStringAsFixed(1)}", style: const TextStyle(color: Colors.white70))),
              Expanded(child: Text("${p["runs"]}", style: const TextStyle(color: Colors.white70))),
              Expanded(child: Text("${p["wickets"]}", style: TextStyle(color: accentCyan, fontWeight: FontWeight.w900))),
            ]),
          )).toList(),
        ],
      ),
    );
  }

  /// SQUAD TABS
  Widget _buildSquadTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: accentCyan,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: accentCyan,
          unselectedLabelColor: Colors.white38,
          tabs: [
            Tab(text: (live!["teamAName"] ?? "Team A").toString().toUpperCase()),
            Tab(text: (live!["teamBName"] ?? "Team B").toString().toUpperCase()),
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
    );
  }

  Widget _playerList(List? players) {
    if (players == null || players.isEmpty) {
      return const Center(child: Text("No Squad Data", style: TextStyle(color: Colors.white24)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
      itemBuilder: (context, i) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: accentCyan.withOpacity(0.1), child: Text("${i+1}", style: TextStyle(color: accentCyan, fontSize: 12))),
        title: Text(players[i].toString(), style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }
}