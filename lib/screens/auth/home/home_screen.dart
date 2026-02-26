import 'package:flutter/material.dart';
import '../../../widgets/glow_bottom_nav.dart';
import 'package:livescore/screens/auth/events/events_screen.dart';
import 'package:livescore/screens/auth/teams/teams_screen.dart';

import '../admin/create_tournament_screen.dart';
import '../live_score_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final bool isAdmin = user?["role"] == "ADMIN";

    final pages = [
      _homePage(),
      const TeamsScreen(),
      const SizedBox(),
      const EventsScreen(),
      const Center(child: Text("Profile")),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[index],
      bottomNavigationBar: GlowBottomNav(
        index: index,
        isAdmin: isAdmin,
        onTap: (i) {
          if (i == 2) {
            if (!isAdmin) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateTournamentScreen(),
              ),
            );
            return;
          }

          setState(() => index = i);
        },
      ),
    );
  }

  Widget _homePage() {
    final user = widget.user;

    /// 🔥 TEMP HARDCODE LIVE MATCH
    final liveMatches = [
      {
        "tournamentId": "c9efa3f0-084f-42a7-b24e-4eafc8283798",
        "matchId": "c25b2774-fb06-4405-bb0f-52cfd0ea6a2a",
        "teamAName": "Lucifer crick",
        "teamBName": "lame"
      }
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Livescore Home",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            /// USER INFO
            if (user != null) ...[
              Text("Name: ${user["name"]}"),
              Text("Role: ${user["role"]}"),
              const SizedBox(height: 20),
            ],

            const Text(
              "LIVE MATCHES",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            /// LIVE MATCH CARDS
            ...liveMatches.map(
                  (m) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LiveScoreScreen(
                        tournamentId: m["tournamentId"]!,
                        matchId: m["matchId"]!,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m["teamAName"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("VS"),
                      Text(
                        m["teamBName"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}