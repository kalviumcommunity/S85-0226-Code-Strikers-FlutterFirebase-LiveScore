import 'package:flutter/material.dart';
import '../../../../services/team_service.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final nameController = TextEditingController();
  final maxPlayersController = TextEditingController();
  String sports = "CRICKET";
  bool loading = false;

  // Design Constants
  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color cardBg = const Color(0xFF1E293B).withOpacity(0.4);

  Future<void> submit() async {
    if (nameController.text.isEmpty || maxPlayersController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => loading = true);

    final ok = await TeamService.createTeam(
      name: nameController.text.trim(),
      maxPlayers: int.tryParse(maxPlayersController.text) ?? 0,
      sports: sports,
    );

    setState(() => loading = false);

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create team")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Matching deep navy
      appBar: AppBar(
        title: const Text(
          "Formation Center", // Cooler name than "Create Team"
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Instruction
            Text(
              "BUILD YOUR SQUAD",
              style: TextStyle(
                color: accentCyan,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Set your team details and start recruiting players.",
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Input Fields
            _fieldHeader("Team Identity"),
            _field(
                nameController,
                "Enter Team Name",
                Icons.shield_outlined
            ),

            const SizedBox(height: 24),

            _fieldHeader("Squad Size"),
            _field(
                maxPlayersController,
                "Max Players (e.g. 11)",
                Icons.groups_3_outlined,
                keyboard: TextInputType.number
            ),

            const SizedBox(height: 24),

            _fieldHeader("Select Sport"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _inputBoxDec(),
              child: DropdownButtonFormField<String>(
                value: sports,
                dropdownColor: const Color(0xFF1E293B),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.sports_esports_outlined, color: Colors.white38),
                ),
                items: const [
                  DropdownMenuItem(value: "CRICKET", child: Text("Cricket")),
                  DropdownMenuItem(value: "FOOTBALL", child: Text("Football")),
                  DropdownMenuItem(value: "VOLLEYBALL", child: Text("Volleyball")),
                  DropdownMenuItem(value: "BASKETBALL", child: Text("Basketball")),
                ],
                onChanged: (v) => setState(() => sports = v!),
              ),
            ),

            const SizedBox(height: 48),

            // Neon Gradient Button
            GestureDetector(
              onTap: loading ? null : submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: loading
                        ? [Colors.grey.shade800, Colors.grey.shade900]
                        : [primaryPurple, accentCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    if (!loading)
                      BoxShadow(
                        color: primaryPurple.withOpacity(0.4),
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
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                )
                    : const Text(
                  "INITIALIZE TEAM",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _fieldHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return Container(
      decoration: _inputBoxDec(),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.white38, size: 22),
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: InputBorder.none,
        ),
      ),
    );
  }

  BoxDecoration _inputBoxDec() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    );
  }
}