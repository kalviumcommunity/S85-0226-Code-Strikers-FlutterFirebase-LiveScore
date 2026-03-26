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

  Future<void> _fetchInitialData() async {
    try {
      final res = await http.get(
        Uri.parse("http://127.0.1.1:8080/live/${widget.tournamentId}"),
      );

      if (res.statusCode == 200) {
        List list = json.decode(res.body);
        if (list.isNotEmpty && mounted) {
          final selectedMatch = list.firstWhere(
                (m) => m["matchId"].toString() == widget.matchId,
            orElse: () => list[0],
          );
          setState(() => live = Map<String, dynamic>.from(selectedMatch));
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

  /// 🏆 WINNING LOGIC HELPER
  String _getMatchStatus() {
    if (live == null) return "LIVE";

    final int sA = live!["scoreA"] ?? 0;
    final int sB = live!["scoreB"] ?? 0;
    final String tA = live!["teamAName"] ?? "Team A";
    final String tB = live!["teamBName"] ?? "Team B";

    // If 2nd innings hasn't started or just started
    if (sB == 0 && (live!["oversB"] == 0 || live!["oversB"] == 0.0)) {
      return "$tA IS BATTING";
    }

    // Win conditions
    if (sB > sA) {
      return "🏆 $tB WON THE MATCH";
    } else if (sA > sB && (live!["wicketsB"] == 10 || live!["oversB"] >= 20)) {
      // Assuming 20 overs match, adjust based on your tournament rules
      return "🏆 $tA WON THE MATCH";
    } else {
      int runsNeeded = (sA - sB) + 1;
      return "$tB NEEDS $runsNeeded RUNS TO WIN";
    }
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
        body: Center(child: CircularProgressIndicator(color: accentCyan)),
      );
    }

    bool isTeamABatting = (live!["teamAPlayers"] ?? []).contains(live!["strikerName"]);
    final battingList = isTeamABatting ? live!["battingA"] : live!["battingB"];
    final bowlingList = isTeamABatting ? live!["bowlingB"] : live!["bowlingA"];
    final battingTeamName = isTeamABatting ? live!["teamAName"] : live!["teamBName"];
    final bowlingTeamName = isTeamABatting ? live!["teamBName"] : live!["teamAName"];

    final String matchStatus = _getMatchStatus();
    final bool isGameOver = matchStatus.contains("WON");

    return Scaffold(
      backgroundColor: darkBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMainScorecard(matchStatus, isGameOver),
                  const SizedBox(height: 16),
                  if (!isGameOver) _buildOnFieldMiniCard(),
                  const SizedBox(height: 24),
                  _sectionTitle("BATTING • $battingTeamName"),
                  _buildStatTable(battingList, true),
                  const SizedBox(height: 24),
                  _sectionTitle("BOWLING • $bowlingTeamName"),
                  _buildStatTable(bowlingList, false),
                  const SizedBox(height: 24),
                  _sectionTitle("TEAM SQUADS"),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildSquadTabs(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: darkBg,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: _liveAppBarTitle(),
      centerTitle: true,
    );
  }

  Widget _buildMainScorecard(String status, bool isWin) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isWin ? accentCyan.withOpacity(0.4) : Colors.white10),
        boxShadow: [
          if (isWin) BoxShadow(color: accentCyan.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          // Dynamic Status Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isWin ? accentCyan.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Text(
              status.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isWin ? accentCyan : Colors.white70,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _teamInnings(live!["teamAName"], live!["scoreA"], live!["wicketsA"], live!["oversA"], true),
                Text("VS", style: TextStyle(color: accentCyan.withOpacity(0.3), fontWeight: FontWeight.w900)),
                _teamInnings(live!["teamBName"], live!["scoreB"], live!["wicketsB"], live!["oversB"], false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamInnings(String name, runs, wickets, overs, bool isLeft) {
    return Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(name, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text("$runs/$wickets", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
        Text("$overs ov", style: TextStyle(color: accentCyan, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildOnFieldMiniCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _fieldPlayerInfo("STRIKER", live!["strikerName"], true),
          _fieldPlayerInfo("BOWLER", live!["bowlerName"], false),
        ],
      ),
    );
  }

  Widget _fieldPlayerInfo(String label, String name, bool isStriker) {
    return Column(
      crossAxisAlignment: isStriker ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (isStriker) Icon(Icons.bolt, color: accentCyan, size: 14),
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatTable(List players, bool isBatting) {
    return Container(
      decoration: BoxDecoration(color: cardBg.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: players.map<Widget>((p) {
          return ListTile(
            title: Text(p["playerName"], style: const TextStyle(color: Colors.white, fontSize: 14)),
            trailing: Text(
              isBatting ? "${p["runs"]} (${p["balls"]})" : "${p["wickets"]}/${p["runs"]}",
              style: TextStyle(color: isBatting ? Colors.white : accentCyan, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSquadTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: accentCyan,
          tabs: [Tab(text: live!["teamAName"]), Tab(text: live!["teamBName"])],
        ),
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _playerList(live!["teamAPlayers"]),
              _playerList(live!["teamBPlayers"]),
            ],
          ),
        )
      ],
    );
  }

  Widget _playerList(List players) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: players.length,
      itemBuilder: (_, i) => ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white10, radius: 15, child: Text("${i+1}", style: const TextStyle(fontSize: 10, color: Colors.white))),
        title: Text(players[i], style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title, style: TextStyle(color: accentCyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
    );
  }

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
          const Icon(Icons.circle, color: Colors.red, size: 8),
          const SizedBox(width: 8),
          const Text("LIVE SCORE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}