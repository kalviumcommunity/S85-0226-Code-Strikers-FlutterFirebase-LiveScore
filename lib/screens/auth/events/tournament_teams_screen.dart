import 'package:flutter/material.dart';
import '../../../services/tournament_service.dart';
import '../../../services/auth_service.dart';

class TournamentTeamsScreen extends StatefulWidget {
  final String tournamentId;

  const TournamentTeamsScreen({super.key, required this.tournamentId});

  @override
  State<TournamentTeamsScreen> createState() => _TournamentTeamsScreenState();
}

class _TournamentTeamsScreenState extends State<TournamentTeamsScreen> {
  late Future<List<Map<String, dynamic>>> future;

  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color cardBg = const Color(0xFF1E293B).withOpacity(0.4);

  @override
  void initState() {
    super.initState();
    future = TournamentService.getTournamentTeams(widget.tournamentId);
  }

  Future<void> shuffleTeams() async {
    // Show a loading dialog for heavy admin actions
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: accentCyan)),
    );

    final ok = await TournamentService.shuffleFixtures(widget.tournamentId);

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Fixtures generated & shuffled!"),
          backgroundColor: primaryPurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        future = TournamentService.getTournamentTeams(widget.tournamentId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Shuffle failed"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = AuthService.role == "ADMIN";

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Squad Roster",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          /// ⭐ ADMIN CONTROL PANEL
          if (isAdmin) _buildAdminPanel(),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryPurple));
                }

                if (snap.hasError) {
                  return const Center(child: Text("Error loading roster", style: TextStyle(color: Colors.white70)));
                }

                final teams = snap.data ?? [];

                if (teams.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: teams.length,
                  itemBuilder: (_, i) => _buildTeamCard(teams[i], i),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryPurple.withOpacity(0.2), Colors.transparent]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("ADMIN CONTROLS",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
              Text("Generate match fixtures randomly",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: shuffleTeams,
            icon: const Icon(Icons.shuffle_rounded, size: 18),
            label: const Text("SHUFFLE"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> t, int index) {
    final teamName = t["teamName"] ?? "Unknown Team";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              /// RANK INDICATOR
              Container(
                width: 50,
                color: Colors.white.withOpacity(0.02),
                alignment: Alignment.center,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: index < 3 ? accentCyan : Colors.white24,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryPurple, accentCyan]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    teamName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22),
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "VERIFIED SQUAD",
                      style: TextStyle(color: accentCyan.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded, color: Colors.white10),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          const Text("Waiting for squads to join...",
              style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}