import 'package:flutter/material.dart';
import '../../../services/team_service.dart';

class TeamMembersPickerScreen extends StatefulWidget {
  final String teamId;

  const TeamMembersPickerScreen({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamMembersPickerScreen> createState() =>
      _TeamMembersPickerScreenState();
}

class _TeamMembersPickerScreenState
    extends State<TeamMembersPickerScreen> {
  late Future<List<Map<String, dynamic>>> future;

  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color cardBg = const Color(0xFF1E293B).withOpacity(0.4);

  @override
  void initState() {
    super.initState();
    future = TeamService.getTeamMembers(widget.teamId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Select Player"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryPurple),
            );
          }

          if (snap.hasError || snap.data == null) {
            return const Center(
              child: Text("Failed to load players",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final players = snap.data!;

          if (players.isEmpty) {
            return const Center(
              child: Text("No players in squad",
                  style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: players.length,
            itemBuilder: (_, i) {
              final p = players[i];
              final name = p["name"] ?? "Player";
              final role = p["role"] ?? "";

              return GestureDetector(
                onTap: () => Navigator.pop(context, p),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: primaryPurple,
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            if (role.isNotEmpty)
                              Text(role,
                                  style: TextStyle(
                                      color: Colors.white
                                          .withOpacity(0.5),
                                      fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Colors.white30),
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