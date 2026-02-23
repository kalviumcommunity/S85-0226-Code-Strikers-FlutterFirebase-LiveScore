import 'package:flutter/material.dart';
import '../../../models/team/team.dart';
import '../../../services/team_service.dart';
import '../../../services/auth_service.dart';

class TeamDetailScreen extends StatefulWidget {
  final String teamId;

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  late Future<Team> future;

  bool requested = false;
  bool loadingRequest = true;

  @override
  void initState() {
    super.initState();
    future = TeamService.fetchTeamById(widget.teamId);
    _loadRequestStatus();
  }

  Future<void> _loadRequestStatus() async {
    final r = await TeamService.hasRequested(widget.teamId);
    if (mounted) {
      setState(() {
        requested = r;
        loadingRequest = false;
      });
    }
  }

  Future<void> sendRequest(String teamId) async {
    final ok = await TeamService.sendJoinRequest(teamId);

    if (!mounted) return;

    if (ok) {
      setState(() => requested = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Join request sent")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text("Team Details"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Team>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text(
                "Error loading team",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final t = snapshot.data!;

          /// ⭐ LEADER CHECK
          final isLeader = t.leaderId == AuthService.userId;

          /// ⭐ TEAM FULL CHECK
          final isFull = t.currentPlayers >= t.maxPlayers;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TEAM CARD
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _row("Sports", t.sports ?? "-"),
                        _row("Leader", t.leaderId ?? "-"),
                        _row("Status", t.status),
                        _row("Players", "${t.currentPlayers}/${t.maxPlayers}"),
                        _row("Tournament", t.tournamentId ?? "None"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ⭐ JOIN BUTTON LOGIC
                  if (!isLeader && AuthService.isUser())
                    loadingRequest
                        ? const Center(child: CircularProgressIndicator())
                        : requested
                        ? _disabledButton("Request Sent")
                        : isFull
                        ? _disabledButton("Team Full")
                        : _joinButton(t.id),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _joinButton(String teamId) {
    return GestureDetector(
      onTap: () => sendRequest(teamId),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Text(
          "Request to Join",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _disabledButton(String text) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$k: ",
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}