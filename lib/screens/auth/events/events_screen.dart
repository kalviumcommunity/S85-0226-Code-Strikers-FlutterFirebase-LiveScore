import 'package:flutter/material.dart';
import 'package:livescore/models/tournament.dart';
import 'package:livescore/screens/auth/events/tournament_detail_screen.dart';
import 'package:livescore/services/tournament_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late Future<List<Tournament>> future;

  // Modern Design Palette
  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);

  @override
  void initState() {
    super.initState();
    future = TournamentService.fetchTournaments();
  }

  Color getStatusColor(String s) {
    switch (s) {
      case "OPEN":
        return Colors.greenAccent;
      case "ONGOING":
        return Colors.orangeAccent;
      case "COMPLETED":
        return Colors.white38;
      default:
        return accentCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Navy
      appBar: AppBar(
        title: const Text(
          "Tournaments",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<List<Tournament>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryPurple));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading events",
                style: TextStyle(color: Colors.redAccent.withOpacity(0.8)),
              ),
            );
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(
              child: Text(
                "No active tournaments",
                style: TextStyle(color: Colors.white38),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final t = list[i];
              final color = getStatusColor(t.registeration);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TournamentDetailScreen(tournament: t),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.05), Colors.transparent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Subtle Background decoration
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Icon(Icons.emoji_events_rounded,
                              size: 100, color: color.withOpacity(0.03)),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              /// Icon/Trophy Area
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(Icons.military_tech_rounded,
                                    color: color, size: 32),
                              ),

                              const SizedBox(width: 16),

                              /// Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.name.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 12, color: Colors.white38),
                                        const SizedBox(width: 4),
                                        Text(
                                          t.location,
                                          style: const TextStyle(color: Colors.white38, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: color.withOpacity(0.2)),
                                      ),
                                      child: Text(
                                        t.registeration,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              /// Action Arrow
                              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
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