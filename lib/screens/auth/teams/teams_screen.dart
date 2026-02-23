import 'package:flutter/material.dart';
import 'package:livescore/screens/auth/teams/team_detail_screen.dart';
import 'package:livescore/screens/auth/teams/team_requests_screen.dart';

import '../../../models/team/team.dart';
import '../../../services/team_service.dart';
import '../../../services/auth_service.dart';
import 'create_team_screen/create_team_screen.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  late Future<List<Team>> future;

  // Modern Neon Colors
  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color cardBg = const Color(0xFF1E293B).withOpacity(0.4);

  @override
  void initState() {
    super.initState();
    future = TeamService.fetchTeams();
  }

  void openTeam(String teamId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TeamDetailScreen(teamId: teamId)),
    );
  }

  void openRequests(String teamId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TeamRequestsScreen(teamId: teamId)),
    );
  }

  String shortId(String? id) {
    if (id == null || id.isEmpty) return "Unknown";
    if (id.length <= 10) return id;
    return "${id.substring(0, 6)}...${id.substring(id.length - 4)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Midnight Blue
      appBar: AppBar(
        title: const Text(
          "Discover Teams",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: primaryPurple),
              ),
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateTeamScreen()),
                );
                if (created == true) {
                  setState(() {
                    future = TeamService.fetchTeams();
                  });
                }
              },
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Team>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryPurple));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading teams", style: TextStyle(color: Colors.white)));
          }

          final teams = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
            itemCount: teams.length,
            itemBuilder: (_, i) {
              final t = teams[i];
              final isLeader = t.leaderId == AuthService.userId;
              final progress = t.currentPlayers / t.maxPlayers;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  gradient: LinearGradient(
                    colors: [cardBg, const Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () => openTeam(t.id),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              /// Team Icon with Gradient Glow
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [primaryPurple, accentCyan]),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(color: primaryPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  t.name[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.person, size: 14, color: Colors.white.withOpacity(0.5)),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Leader: ${shortId(t.leaderId)}",
                                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Join Button / Status
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: t.status == "OPEN" ? primaryPurple : Colors.white10,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      t.status == "OPEN" ? "JOIN" : "FULL",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          /// Progress Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Capacity",
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                              ),
                              Text(
                                "${t.currentPlayers}/${t.maxPlayers} Players",
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [primaryPurple, accentCyan]),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(color: primaryPurple.withOpacity(0.5), blurRadius: 6)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          /// Leader Actions
                          if (isLeader) ...[
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => openRequests(t.id),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: primaryPurple.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.mail_outline, size: 16, color: primaryPurple),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Manage Requests",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
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