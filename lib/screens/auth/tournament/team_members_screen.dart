import 'package:flutter/material.dart';
import '../../../services/team_service.dart';

class TeamMembersScreen extends StatefulWidget {
  final String teamId;

  const TeamMembersScreen({super.key, required this.teamId, required bool selectable});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  late Future<List<Map<String, dynamic>>> future;

  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
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
        title: const Text(
          "Squad Roster",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryPurple));
          }

          if (snap.hasError) {
            return const Center(
              child: Text("Error loading squad", style: TextStyle(color: Colors.white70)),
            );
          }

          final members = snap.data ?? [];

          if (members.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Member Count Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "${members.length} ACTIVE PLAYERS",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: members.length,
                  itemBuilder: (_, i) {
                    final m = members[i];
                    final String name = m["name"] ?? "Unknown";
                    final String role = m["role"] ?? "Player";
                    final bool isLeader = role.toUpperCase() == "LEADER" || role.toUpperCase() == "CAPTAIN";

                    return _buildPlayerCard(name, role, isLeader);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayerCard(String name, String role, bool isLeader) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLeader ? primaryPurple.withOpacity(0.4) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Player Avatar with Hexagon-like border
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLeader
                      ? [primaryPurple, const Color(0xFFD8B4FE)]
                      : [const Color(0xFF334155), const Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Name and Role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (isLeader) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.verified, color: accentCyan, size: 14),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isLeader ? primaryPurple : accentCyan).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: TextStyle(
                        color: isLeader ? primaryPurple : accentCyan,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tactical Icon
            Icon(
              isLeader ? Icons.star_rounded : Icons.person_outline_rounded,
              color: isLeader ? primaryPurple : Colors.white10,
              size: 24,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          const Text(
            "The squad is currently empty",
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }
}