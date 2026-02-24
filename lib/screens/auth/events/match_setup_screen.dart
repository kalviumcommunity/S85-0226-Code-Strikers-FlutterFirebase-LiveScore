import 'package:flutter/material.dart';
import '../../../services/team_service.dart';
import '../../../services/tournament_service.dart';
import 'cricket_scoring_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  final Map match;

  const MatchSetupScreen({super.key, required this.match});

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  List membersA = [];
  List membersB = [];

  String? strikerId;
  String? nonStrikerId;
  String? bowlerId;

  bool loading = false;

  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color primaryPurple = const Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    final a = await TeamService.getTeamMembers(widget.match["teamAId"]);
    final b = await TeamService.getTeamMembers(widget.match["teamBId"]);

    if (!mounted) return;

    setState(() {
      membersA = a;
      membersB = b;
    });
  }

  Future<void> startInningsFlow() async {
    if (strikerId == null || nonStrikerId == null || bowlerId == null) {
      _showSnackBar("Please select all opening players");
      return;
    }

    if (strikerId == nonStrikerId) {
      _showSnackBar("Striker and Non-Striker cannot be same");
      return;
    }

    setState(() => loading = true);

    try {
      final tid = widget.match["tournamentId"];
      final mid = widget.match["id"];

      /// ⭐ STEP 1 — start match
      await TournamentService.startMatch(
        tournamentId: tid,
        matchId: mid,
      );

      /// ⭐ STEP 2 — start innings
      await TournamentService.startInnings(
        tournamentId: tid,
        matchId: mid,
        strikerId: strikerId!,
        nonStrikerId: nonStrikerId!,
        bowlerId: bowlerId!,
      );

      if (!mounted) return;

      _showSnackBar("Match & Innings Started!", isError: false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CricketScoringScreen(match: widget.match),
        ),
      );// back to match list
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text(
          "Match Setup",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [darkBg, const Color(0xFF0B1220)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            _buildMatchHeader(m),

            const SizedBox(height: 30),

            /// BATSMEN
            _sectionLabel("OPENING BATSMEN (${m["teamAName"]})"),
            const SizedBox(height: 12),

            _playerSelector(
              label: "Striker",
              icon: Icons.sports_cricket,
              value: strikerId,
              items: membersA,
              onChanged: (v) => setState(() => strikerId = v),
              accentColor: accentCyan,
            ),

            const SizedBox(height: 16),

            _playerSelector(
              label: "Non-Striker",
              icon: Icons.front_hand_outlined,
              value: nonStrikerId,
              items: membersA,
              onChanged: (v) => setState(() => nonStrikerId = v),
              accentColor: accentCyan,
            ),

            const SizedBox(height: 32),

            /// BOWLER
            _sectionLabel("OPENING BOWLER (${m["teamBName"]})"),
            const SizedBox(height: 12),

            _playerSelector(
              label: "Bowler",
              icon: Icons.sports_baseball,
              value: bowlerId,
              items: membersB,
              onChanged: (v) => setState(() => bowlerId = v),
              accentColor: primaryPurple,
            ),

            const SizedBox(height: 40),

            _buildStartButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader(Map m) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _teamInitials(m["teamAName"], accentCyan),
          Column(
            children: [
              const Text(
                "VS",
                style: TextStyle(
                  color: Colors.white24,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                m["venue"] ?? "Ground A",
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _teamInitials(m["teamBName"], primaryPurple),
        ],
      ),
    );
  }

  Widget _teamInitials(String name, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.1),
          child: Text(
            name[0].toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _playerSelector({
    required String label,
    required IconData icon,
    required String? value,
    required List items,
    required Function(String?) onChanged,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value != null
              ? accentColor.withOpacity(0.4)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: cardBg,
        value: value,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: accentColor),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: accentColor, size: 20),
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        items: items.map<DropdownMenuItem<String>>((p) {
          return DropdownMenuItem(
            value: p["userId"]?.toString(),
            child: Text(
              p["name"] ?? "Player",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: loading ? null : startInningsFlow,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 60,
        decoration: BoxDecoration(
          gradient: loading
              ? LinearGradient(
              colors: [Colors.grey.shade800, Colors.grey.shade900])
              : LinearGradient(colors: [primaryPurple, accentCyan]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: loading
              ? []
              : [
            BoxShadow(
              color: primaryPurple.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          "START INNINGS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}