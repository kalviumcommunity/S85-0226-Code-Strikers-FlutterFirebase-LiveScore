import 'package:flutter/material.dart';
import 'package:livescore/models/tournament.dart';

class TournamentDetailScreen extends StatelessWidget {
  final Tournament tournament;

  TournamentDetailScreen({super.key, required this.tournament});
  // Modern Design Palette
  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color cardBg = const Color(0xFF1E293B).withOpacity(0.4);

  Color statusColor(String s) {
    switch (s) {
      case "OPEN":
        return Colors.greenAccent;
      case "ONGOING":
        return Colors.orangeAccent;
      case "COMPLETED":
        return Colors.white24;
      default:
        return accentCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = tournament;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Glow effect
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryPurple.withOpacity(0.15),
              ),
            ),
          ),

          ListView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
            children: [
              /// TOURNAMENT HEADER
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryPurple, accentCyan]),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: primaryPurple.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: const Icon(Icons.emoji_events_rounded, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  t.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined, color: accentCyan, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      t.location.toUpperCase(),
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Status Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor(t.registeration).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor(t.registeration).withOpacity(0.5)),
                  ),
                  child: Text(
                    t.registeration,
                    style: TextStyle(color: statusColor(t.registeration), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// STATS GRID
              Row(
                children: [
                  _statCard("STARTS", t.startDate, Icons.calendar_today_rounded),
                  const SizedBox(width: 16),
                  _statCard("ENDS", t.endDate, Icons.flag_rounded),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _statCard("SLOTS", "${t.registeredTeams}/${t.totalTeams}", Icons.groups_rounded),
                  const SizedBox(width: 16),
                  _statCard("TEAM SIZE", "${t.requiredPlayer} Players", Icons.person_add_alt_1_rounded),
                ],
              ),

              const SizedBox(height: 40),

              /// REGISTER BUTTON
              GestureDetector(
                onTap: () {
                  // Add logic here
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryPurple, accentCyan]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: primaryPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "REGISTER TEAM",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Read Tournament Rules & Guidelines",
                  style: TextStyle(color: Colors.white38, fontSize: 12, decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentCyan, size: 20),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}