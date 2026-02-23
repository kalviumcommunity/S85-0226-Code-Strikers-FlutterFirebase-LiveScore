import 'package:flutter/material.dart';
import '../../../models/fixture.dart';

class FixtureDetailScreen extends StatelessWidget {
  final Fixture fixture;

  const FixtureDetailScreen({super.key, required this.fixture});

  // Design Constants
  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color cardBg = const Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("MATCH CENTER",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Top Ambient Glow
          _buildTopGlow(),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
            child: Column(
              children: [
                /// ROUND & STATUS TOP BAR
                _buildStatusHeader(),

                const SizedBox(height: 40),

                /// THE BATTLEFIELD (Teams & Scores)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _teamIdentity(fixture.teamAName, fixture.scoreA, true),
                          _vsDivider(),
                          _teamIdentity(fixture.teamBName, fixture.scoreB, false),
                        ],
                      ),
                      const SizedBox(height: 40),
                      _scoreDisplay(),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// MATCH INFO SECTION
                _infoTile(Icons.calendar_month_rounded, "SCHEDULED AT", fixture.scheduledAt),
                _infoTile(Icons.sports_rounded, "MATCH TYPE", "Tournament Bracket"),
                _infoTile(Icons.verified_user_rounded, "REFEREE", "Official System"),

                const SizedBox(height: 40),

                /// REFRESH/ACTION BUTTON
                _buildActionButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ROUND ${fixture.round}",
                style: TextStyle(color: accentCyan, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const Text("Official Fixture", style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: fixture.status == "LIVE" ? Colors.redAccent.withOpacity(0.1) : accentCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: fixture.status == "LIVE" ? Colors.redAccent : accentCyan.withOpacity(0.5)),
          ),
          child: Text(
            fixture.status,
            style: TextStyle(
                color: fixture.status == "LIVE" ? Colors.redAccent : accentCyan,
                fontWeight: FontWeight.bold,
                fontSize: 12
            ),
          ),
        ),
      ],
    );
  }

  Widget _teamIdentity(String name, int score, bool isTeamA) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isTeamA ? [primaryPurple, Colors.deepPurple] : [accentCyan, Colors.blue],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                    color: (isTeamA ? primaryPurple : accentCyan).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8)
                )
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _vsDivider() {
    return Column(
      children: [
        const Text("VS", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontSize: 22, fontStyle: FontStyle.italic)),
        Container(height: 20, width: 1, color: Colors.white10),
      ],
    );
  }

  Widget _scoreDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _scoreText(fixture.scoreA, fixture.scoreA > fixture.scoreB),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(":", style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 40, fontWeight: FontWeight.w200)),
        ),
        _scoreText(fixture.scoreB, fixture.scoreB > fixture.scoreA),
      ],
    );
  }

  Widget _scoreText(int score, bool isWinner) {
    return Text(
      "$score",
      style: TextStyle(
        color: isWinner ? Colors.white : Colors.white38,
        fontSize: 54,
        fontWeight: FontWeight.w900,
        shadows: isWinner ? [Shadow(color: accentCyan.withOpacity(0.5), blurRadius: 20)] : [],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentCyan, size: 20),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTopGlow() {
    return Positioned(
      top: -100,
      left: 50,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryPurple.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: const Text("BACK TO FIXTURES", style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
}