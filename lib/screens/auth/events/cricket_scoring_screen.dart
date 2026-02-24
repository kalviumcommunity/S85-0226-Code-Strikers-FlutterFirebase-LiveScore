import 'package:flutter/material.dart';
import '../../../services/tournament_service.dart';

class CricketScoringScreen extends StatefulWidget {
  final Map match;

  const CricketScoringScreen({super.key, required this.match});

  @override
  State<CricketScoringScreen> createState() => _CricketScoringScreenState();
}

class _CricketScoringScreenState extends State<CricketScoringScreen> {
  bool loading = false;
  List<String> ballHistory = []; // Tracks the current over

  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);

  Future<void> recordBall(int runs, bool wicket) async {
    setState(() {
      loading = true;
      // Add to history for visual feedback
      ballHistory.insert(0, wicket ? "W" : runs.toString());
      if (ballHistory.length > 6) ballHistory.removeLast();
    });

    try {
      await TournamentService.updateBall(
        tournamentId: widget.match["tournamentId"],
        matchId: widget.match["id"],
        runs: runs,
        wicket: wicket,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text("Live Scorer", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          /// 1. MAIN SCOREBOARD
          _buildScoreboard(m),

          /// 2. ACTIVE PLAYERS
          _buildPlayerStats(),

          const Spacer(),

          /// 3. RECENT BALLS TICKER
          _buildRecentBalls(),

          /// 4. CONTROL PAD
          _buildControlPad(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreboard(Map m) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryPurple.withOpacity(0.2), accentCyan.withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            "${m["teamAName"]} Innings",
            style: TextStyle(color: accentCyan, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text("124", style: TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w900)),
              Text(" / 3", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "Overs: 14.2",
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _playerMiniCard("Striker", "Rahul R.", "42(28)", isStriker: true),
          const SizedBox(width: 12),
          _playerMiniCard("Non-Striker", "Rohit S.", "12(10)"),
        ],
      ),
    );
  }

  Widget _playerMiniCard(String label, String name, String stats, {bool isStriker = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isStriker ? accentCyan.withOpacity(0.1) : cardBg.withOpacity(0.4),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isStriker ? accentCyan.withOpacity(0.4) : Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            Text(stats, style: TextStyle(color: accentCyan, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBalls() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("THIS OVER: ", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontSize: 10)),
          const SizedBox(width: 10),
          ...ballHistory.map((b) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: b == "W" ? Colors.redAccent : (b == "4" || b == "6" ? primaryPurple : Colors.white10),
            ),
            child: Text(b, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          )),
        ],
      ),
    );
  }

  Widget _buildControlPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              _scoreBtn(0, "Dot"),
              _scoreBtn(1, "1"),
              _scoreBtn(2, "2"),
              _scoreBtn(3, "3"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _scoreBtn(4, "FOUR", isBoundary: true),
              _scoreBtn(6, "SIX", isBoundary: true),
              _wicketBtn(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreBtn(int r, String label, {bool isBoundary = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: loading ? null : () => recordBall(r, false),
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isBoundary ? primaryPurple : cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isBoundary ? [BoxShadow(color: primaryPurple.withOpacity(0.3), blurRadius: 10)] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget _wicketBtn() {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: loading ? null : () => recordBall(0, true),
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
          ),
          alignment: Alignment.center,
          child: const Text(
            "WKT",
            style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}