import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../live_score_screen.dart';

class LiveMatchesScreen extends StatefulWidget {
  final String tournamentId;
  final String tournamentName;

  const LiveMatchesScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<LiveMatchesScreen> createState() => _LiveMatchesScreenState();
}

class _LiveMatchesScreenState extends State<LiveMatchesScreen> {
  List liveMatches = [];
  bool loading = true;
  Timer? _refreshTimer;

  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color primaryPurple = const Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    fetchLiveMatches();
    // Auto-refresh data every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchLiveMatches(showLoading: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchLiveMatches({bool showLoading = true}) async {
    if (showLoading) setState(() => loading = true);
    try {
      final res = await http.get(
          Uri.parse("https://livescorebackend-production.up.railway.app/live/${widget.tournamentId}")
      );
      if (res.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          liveMatches = json.decode(res.body);
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Live API Error: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "${widget.tournamentName} Live",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => fetchLiveMatches(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchLiveMatches(showLoading: false),
        color: accentCyan,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : liveMatches.isEmpty
            ? _buildEmptyState()
            : _buildMatchList(),
      ),
    );
  }

  Widget _buildMatchList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: liveMatches.length,
      itemBuilder: (context, i) => _matchCard(liveMatches[i]),
    );
  }

  Widget _matchCard(Map m) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LiveScoreScreen(
            tournamentId: widget.tournamentId,
            matchId: m["matchId"].toString(),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            /// 1. TOP STATUS BAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _liveBadge(),
                Text(
                  m["status"] ?? "LIVE",
                  style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// 2. MAIN SCOREBOARD
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _teamScoreColumn(
                  m["teamAName"].toString(),
                  m["scoreA"].toString(),
                  m["wicketsA"].toString(),
                  m["oversA"].toString(),
                  isBatting: m["status"] == "LIVE", // Simplified logic
                ),
                _vsDivider(),
                _teamScoreColumn(
                  m["teamBName"].toString(),
                  m["scoreB"].toString(),
                  m["wicketsB"].toString(),
                  m["oversB"].toString(),
                  isBatting: false,
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white10, thickness: 1),
            ),

            /// 3. ACTIVE PLAYERS (Striker, Non-Striker, Bowler)
            Row(
              children: [
                // Batsmen Info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _playerStatRow(m["strikerName"].toString(), "★", isStriker: true),
                      const SizedBox(height: 4),
                      _playerStatRow(m["nonStrikerName"].toString(), "", isStriker: false),
                    ],
                  ),
                ),
                // Bowler Info
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("BOWLING", style: TextStyle(color: Colors.white24, fontSize: 8)),
                      Text(
                        m["bowlerName"].toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamScoreColumn(String name, String runs, String wickets, String overs, {required bool isBatting}) {
    return Expanded(
      child: Column(
        children: [
          Text(name.toUpperCase(),
              style: TextStyle(
                color: isBatting ? Colors.white : Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 6),
          Text("$runs/$wickets",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),
          Text("$overs ov",
              style: TextStyle(color: isBatting ? accentCyan : Colors.white24, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _playerStatRow(String name, String tag, {required bool isStriker}) {
    return Row(
      children: [
        Icon(Icons.sports_cricket, size: 12, color: isStriker ? Colors.orangeAccent : Colors.white24),
        const SizedBox(width: 6),
        Text(
          name,
          style: TextStyle(
            color: isStriker ? Colors.white : Colors.white60,
            fontSize: 12,
            fontWeight: isStriker ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isStriker)
          Text(" *", style: TextStyle(color: accentCyan, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _vsDivider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text("VS",
          style: TextStyle(color: primaryPurple, fontStyle: FontStyle.italic, fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }

  Widget _liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          const Text("LIVE", style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_cricket_outlined, color: Colors.white10, size: 80),
          const SizedBox(height: 20),
          const Text("Waiting for the match to start...", style: TextStyle(color: Colors.white38, fontSize: 14)),
          TextButton(onPressed: () => fetchLiveMatches(), child: Text("Check Again", style: TextStyle(color: accentCyan)))
        ],
      ),
    );
  }
}