import 'package:flutter/material.dart';
import '../../../services/tournament_service.dart';
import 'match_setup_screen.dart';

class AdminMatchesScreen extends StatefulWidget {
  final String tournamentId;

  const AdminMatchesScreen({super.key, required this.tournamentId});

  @override
  State<AdminMatchesScreen> createState() => _AdminMatchesScreenState();
}

class _AdminMatchesScreenState extends State<AdminMatchesScreen> {
  late Future<List<Map<String, dynamic>>> future;

  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color accentCyan = const Color(0xFF22D3EE);

  @override
  void initState() {
    super.initState();
    future = TournamentService.getMatches(widget.tournamentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text("Manage Matches"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(
              child: Text("Failed to load matches",
                  style: TextStyle(color: Colors.white)),
            );
          }

          final matches = snap.data ?? [];

          if (matches.isEmpty) {
            return const Center(
              child: Text("No matches",
                  style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (_, i) {
              final m = matches[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchSetupScreen(match: m),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${m["teamAName"]} vs ${m["teamBName"]}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Status: ${m["status"]}",
                        style: TextStyle(
                          color: accentCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}