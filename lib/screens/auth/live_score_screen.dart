import 'package:flutter/material.dart';
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

class _LiveScoreScreenState extends State<LiveScoreScreen> with SingleTickerProviderStateMixin {
  final socket = LiveScoreSocket();
  Map<String, dynamic>? live;
  late TabController _tabController;

  // Professional Palette
  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color liveRed = const Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    socket.connect(
      tournamentId: widget.tournamentId,
      matchId: widget.matchId,
      onData: (data) => setState(() => live = data),
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
          const SizedBox(height: 16),
          _buildOnFieldStats(),
          const SizedBox(height: 16),
          _buildSquadTabs(),
        ],
      ),
    );
  }

  /// 1. APP BAR LIVE INDICATOR
  Widget _liveAppBarTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: liveRed, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        const Text("LIVE SCORECARD", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }

  /// 2. THE MAIN HEADER SCORE (Team vs Team)
  Widget _buildMainScorecard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text("T20 Match • ${live!["status"] ?? "LIVE"}",
              style: TextStyle(color: accentCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _teamInnings(live!["teamAName"], live!["scoreA"], live!["wicketsA"], live!["oversA"], true),
              const Text("VS", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
              _teamInnings(live!["teamBName"], live!["scoreB"], live!["wicketsB"], live!["oversB"], false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamInnings(String name, dynamic runs, dynamic wickets, dynamic overs, bool isLeading) {
    return Column(
      children: [
        Text(name, style: TextStyle(color: isLeading ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text("$runs/$wickets", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
        Text("($overs ov)", style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  /// 3. ON-FIELD SECTION (Striker, Non-Striker, Bowler)
  Widget _buildOnFieldStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg.withOpacity(0.5), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _fieldPlayerRow("Striker", live!["strikerName"], isStriker: true),
          const Divider(color: Colors.white10, height: 20),
          _fieldPlayerRow("Non-Striker", live!["nonStrikerName"]),
          const Divider(color: Colors.white10, height: 20),
          _fieldPlayerRow("Bowler", live!["bowlerName"], isBowler: true),
        ],
      ),
    );
  }

  Widget _fieldPlayerRow(String label, String? name, {bool isStriker = false, bool isBowler = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
                isBowler ? Icons.sports_baseball : Icons.sports_cricket,
                size: 16,
                color: isStriker ? Colors.orangeAccent : Colors.white38
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
        Text(name ?? "-", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// 4. SQUAD TABS
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
    if (players == null || players.isEmpty) return const Center(child: Text("No Squad Data", style: TextStyle(color: Colors.white24)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
        child: Text(players[i].toString(), style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}