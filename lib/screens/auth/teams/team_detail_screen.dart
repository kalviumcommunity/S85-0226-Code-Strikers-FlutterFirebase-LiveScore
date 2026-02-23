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

  // Modern Palette
  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color cardBg = const Color(0xFF1E293B).withOpacity(0.4);

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

  String shortId(String? id) {
    if (id == null || id.isEmpty || id == "None") return "None";
    if (id.length <= 12) return id;
    return "${id.substring(0, 8)}...${id.substring(id.length - 4)}";
  }

  Future<void> sendRequest(String teamId) async {
    final ok = await TeamService.sendJoinRequest(teamId);
    if (!mounted) return;
    if (ok) {
      setState(() => requested = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Join request sent successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send request")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Squad Profile", style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Team>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryPurple));
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Error loading team", style: TextStyle(color: Colors.white70)));
          }

          final t = snapshot.data!;
          final isLeader = t.leaderId == AuthService.userId;
          final isFull = t.currentPlayers >= t.maxPlayers;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// HERO AVATAR
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryPurple, accentCyan]),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: primaryPurple.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    t.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  t.name,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                ),

                Text(
                  t.sports?.toUpperCase() ?? "GENERAL",
                  style: TextStyle(color: accentCyan, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),

                const SizedBox(height: 32),

                /// STATS GRID
                Row(
                  children: [
                    _infoBox("LEADER", shortId(t.leaderId), Icons.person_outline),
                    const SizedBox(width: 16),
                    _infoBox("STATUS", t.status, Icons.info_outline, color: t.status == "OPEN" ? Colors.greenAccent : Colors.redAccent),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _infoBox("CAPACITY", "${t.currentPlayers}/${t.maxPlayers}", Icons.groups_2_outlined),
                    const SizedBox(width: 16),
                    _infoBox("TOURNAMENT", shortId(t.tournamentId), Icons.emoji_events_outlined),
                  ],
                ),

                const SizedBox(height: 40),

                /// JOIN LOGIC
                if (isLeader)
                  _statusLabel("You are the leader of this squad")
                else if (AuthService.isUser())
                  loadingRequest
                      ? CircularProgressIndicator(color: primaryPurple)
                      : requested
                      ? _disabledButton("REQUEST PENDING", Icons.hourglass_empty_rounded)
                      : isFull
                      ? _disabledButton("SQUAD FULL", Icons.block_flipped)
                      : _joinButton(t.id),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoBox(String label, String value, IconData icon, {Color? color}) {
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
            Icon(icon, color: color ?? accentCyan, size: 20),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _joinButton(String teamId) {
    return GestureDetector(
      onTap: () => sendRequest(teamId),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primaryPurple, accentCyan]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: primaryPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        alignment: Alignment.center,
        child: const Text("REQUEST TO JOIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _disabledButton(String text, IconData icon) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white24, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _statusLabel(String text) {
    return Text(text, style: const TextStyle(color: Colors.white38, fontSize: 14, fontStyle: FontStyle.italic));
  }
}