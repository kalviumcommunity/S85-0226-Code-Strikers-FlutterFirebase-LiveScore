import 'package:flutter/material.dart';
import '../../../models/fixture.dart';
import '../../../services/tournament_service.dart';
import 'fixture_detail_screen.dart';

class TournamentFixturesScreen extends StatefulWidget {
  final String tournamentId;

  const TournamentFixturesScreen({super.key, required this.tournamentId});

  @override
  State<TournamentFixturesScreen> createState() =>
      _TournamentFixturesScreenState();
}

class _TournamentFixturesScreenState extends State<TournamentFixturesScreen> {
  late Future<List<Fixture>> future;

  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color cardBg = const Color(0xFF1E293B).withOpacity(0.4);

  @override
  void initState() {
    super.initState();
    future = TournamentService.getFixtures(widget.tournamentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Match Schedule",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<List<Fixture>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryPurple));
          }

          if (snap.hasError) {
            return const Center(
              child: Text("Failed to load fixtures", style: TextStyle(color: Colors.white70)),
            );
          }

          final fixtures = snap.data ?? [];

          if (fixtures.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: fixtures.length,
            itemBuilder: (_, i) {
              final f = fixtures[i];
              // Group headers could be added here if needed
              return _fixtureCard(f);
            },
          );
        },
      ),
    );
  }

  Widget _fixtureCard(Fixture f) {
    final bool isLive = f.status == "LIVE";

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FixtureDetailScreen(fixture: f)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLive ? accentCyan.withOpacity(0.5) : Colors.white.withOpacity(0.05),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Subtle background "VS" watermark
              Positioned(
                right: -10,
                bottom: -10,
                child: Text("VS", style: TextStyle(color: Colors.white.withOpacity(0.02), fontSize: 80, fontWeight: FontWeight.w900)),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Top Info Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _badge("ROUND ${f.round}", accentCyan.withOpacity(0.1), accentCyan),
                        if (isLive)
                          _liveIndicator()
                        else
                          Text(
                            f.scheduledAt.split(' ').first, // Assuming date part
                            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Teams Row
                    Row(
                      children: [
                        _teamIdentity(f.teamAName, true),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              Text("VS", style: TextStyle(color: Colors.white.withOpacity(0.2), fontWeight: FontWeight.w900, fontSize: 16, fontStyle: FontStyle.italic)),
                              Container(height: 12, width: 1, color: Colors.white.withOpacity(0.1)),
                            ],
                          ),
                        ),
                        _teamIdentity(f.teamBName, false),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Score Footer (if match has started or ended)
                    if (f.status != "UPCOMING")
                      _matchScore(f.scoreA, f.scoreB),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamIdentity(String name, bool isLeft) {
    return Expanded(
      child: Column(
        crossAxisAlignment: isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            isLeft ? "Home" : "Away",
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _matchScore(int scoreA, int scoreB) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "$scoreA - $scoreB",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: textCol, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }

  Widget _liveIndicator() {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        const Text("LIVE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 11)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          const Text("No fixtures generated", style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}