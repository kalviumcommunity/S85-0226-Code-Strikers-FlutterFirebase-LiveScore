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

  @override
  void initState() {
    super.initState();
    future = TournamentService.fetchTournaments();
  }

  Color statusColor(String s) {
    switch (s) {
      case "OPEN":
        return Colors.green;
      case "ONGOING":
        return Colors.orange;
      case "COMPLETED":
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String actionText(String status) {
    switch (status) {
      case "OPEN":
        return "Register Team";
      case "ONGOING":
        return "View";
      case "COMPLETED":
        return "Results";
      default:
        return "View";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text("Tournaments"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Tournament>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(
              child: Text(
                "No tournaments available",
                style: TextStyle(color: Colors.white60),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final t = list[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TournamentDetailScreen(tournament: t),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.location,
                              style:
                              const TextStyle(color: Colors.white60),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor(t.registeration),
                                borderRadius:
                                BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.registeration,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Text(
                        actionText(t.registeration),
                        style: TextStyle(
                          color: Colors.blue[200],
                          fontWeight: FontWeight.w600,
                        ),
                      )
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