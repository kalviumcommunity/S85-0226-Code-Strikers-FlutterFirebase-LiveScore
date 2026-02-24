import 'package:flutter/material.dart';

import '../teams/team_members_picker_screen.dart';
import '../tournament/team_members_screen.dart';

class StartInningsScreen extends StatefulWidget {
  final Map match;

  const StartInningsScreen({super.key, required this.match});

  @override
  State<StartInningsScreen> createState() => _StartInningsScreenState();
}

class _StartInningsScreenState extends State<StartInningsScreen> {
  Map<String, dynamic>? striker;
  Map<String, dynamic>? nonStriker;
  Map<String, dynamic>? bowler;

  final Color primaryPurple = const Color(0xFF8B5CF6);

  Future<void> pickStriker() async {
    final player = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamMembersPickerScreen(
          teamId: widget.match["teamAId"],
        ),
      ),
    );

    if (player != null) {
      setState(() => striker = player);
    }
  }

  Future<void> pickNonStriker() async {
    final player = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamMembersScreen(
          teamId: widget.match["teamAId"],
          selectable: true,
        ),
      ),
    );

    if (player != null) {
      setState(() => nonStriker = player);
    }
  }

  Future<void> pickBowler() async {
    final player = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamMembersScreen(
          teamId: widget.match["teamBId"],
          selectable: true,
        ),
      ),
    );

    if (player != null) {
      setState(() => bowler = player);
    }
  }

  void startInnings() {
    if (striker == null || nonStriker == null || bowler == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select all players")),
      );
      return;
    }

    final strikerId = striker!["playerId"];
    final nonStrikerId = nonStriker!["playerId"];
    final bowlerId = bowler!["playerId"];

    // TODO: call API
    print("Start innings: $strikerId $nonStrikerId $bowlerId");
  }

  Widget _tile(String title, Map<String, dynamic>? player, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        title: Text(title),
        subtitle: Text(player?["name"] ?? "Select"),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.match["teamAName"]} vs ${widget.match["teamBName"]}",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _tile("Striker", striker, pickStriker),
            _tile("Non-Striker", nonStriker, pickNonStriker),
            _tile("Bowler", bowler, pickBowler),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: startInnings,
                child: const Text(
                  "Start Innings",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}