import 'package:flutter/material.dart';
import '../../../services/tournament_service.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final totalTeamsCtrl = TextEditingController();
  final requiredPlayersCtrl = TextEditingController();

  // State Variables
  String sport = "CRICKET";
  String registrationStatus = "OPEN";
  DateTime? startDate;
  DateTime? endDate;
  bool _isSubmitting = false;

  // ✅ 1️⃣ Add state variable
  int? totalOvers;

  // Design Palette
  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color inputBg = const Color(0xFF1E293B).withOpacity(0.5);

  // ✅ 4️⃣ Add overs to submit API
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both start and end dates")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await TournamentService.createTournament(
      name: nameCtrl.text,
      location: locationCtrl.text,
      sports: sport,
      startDate: startDate!,
      endDate: endDate!,
      totalTeams: int.parse(totalTeamsCtrl.text),
      requiredPlayer: int.parse(requiredPlayersCtrl.text),
      registration: registrationStatus,
      totalOvers: sport == "CRICKET" ? totalOvers : null, // ⭐ Added
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tournament Successfully Launched!"),
          backgroundColor: Colors.greenAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to create tournament. Check backend logs."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "New Tournament",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF0B1220)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              _sectionHeader("GENERAL INFORMATION"),
              _buildTextField(nameCtrl, "Tournament Name", Icons.emoji_events_outlined),
              const SizedBox(height: 16),
              _buildTextField(locationCtrl, "Venue / Location", Icons.location_on_outlined),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildSportDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRegistrationDropdown()),
                ],
              ),

              // ✅ 2️⃣ Show overs field only for cricket
              if (sport == "CRICKET") ...[
                const SizedBox(height: 16),
                _buildOversDropdown(),
              ],

              const SizedBox(height: 32),

              _sectionHeader("SCHEDULE"),
              Row(
                children: [
                  Expanded(child: _dateCard("Start Date", startDate, (d) => setState(() => startDate = d))),
                  const SizedBox(width: 16),
                  Expanded(child: _dateCard("End Date", endDate, (d) => setState(() => endDate = d))),
                ],
              ),
              const SizedBox(height: 32),

              _sectionHeader("TOURNAMENT CAPACITY"),
              Row(
                children: [
                  Expanded(child: _buildTextField(totalTeamsCtrl, "Max Teams", Icons.groups_3_outlined, number: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(requiredPlayersCtrl, "Squad Size", Icons.person_add_alt_1_outlined, number: true)),
                ],
              ),

              const SizedBox(height: 50),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ 3️⃣ Overs dropdown widget
  Widget _buildOversDropdown() {
    return DropdownButtonFormField<int>(
      value: totalOvers,
      dropdownColor: const Color(0xFF1E293B),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      onChanged: (v) => setState(() => totalOvers = v),
      items: [1, 2, 4, 6, 8, 10, 12, 15, 20]
          .map((o) => DropdownMenuItem(
        value: o,
        child: Text("$o Overs", style: const TextStyle(fontSize: 13)),
      ))
          .toList(),
      decoration: _inputDecoration("Total Overs", Icons.sports_cricket),
      validator: (v) {
        if (sport == "CRICKET" && v == null) {
          return "Required";
        }
        return null;
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: accentCyan.withOpacity(0.7),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon, {bool number = false}) {
    return TextFormField(
      controller: c,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildSportDropdown() {
    return DropdownButtonFormField<String>(
      value: sport,
      dropdownColor: const Color(0xFF1E293B),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      onChanged: (v) {
        setState(() {
          sport = v!;
          // Reset overs if sport is changed from Cricket to something else
          if (sport != "CRICKET") totalOvers = null;
        });
      },
      items: ["CRICKET", "FOOTBALL", "VOLLEYBALL", "BASKETBALL"]
          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
          .toList(),
      decoration: _inputDecoration("Sport", Icons.sports_score),
    );
  }

  Widget _buildRegistrationDropdown() {
    return DropdownButtonFormField<String>(
      value: registrationStatus,
      dropdownColor: const Color(0xFF1E293B),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      onChanged: (v) => setState(() => registrationStatus = v!),
      items: ["OPEN", "CLOSED"]
          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
          .toList(),
      decoration: _inputDecoration("Status", Icons.app_registration),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      prefixIcon: Icon(icon, color: accentCyan, size: 18),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accentCyan.withOpacity(0.5)),
      ),
      // Styling for error text
      errorStyle: const TextStyle(color: Colors.redAccent),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _dateCard(String label, DateTime? date, Function(DateTime) onPick) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
          initialDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(primary: primaryPurple, onPrimary: Colors.white, surface: const Color(0xFF1E293B)),
              ),
              child: child!,
            );
          },
        );
        if (d != null) onPick(d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: inputBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_month, color: accentCyan, size: 14),
                const SizedBox(width: 8),
                Text(
                  date == null ? "Set Date" : "${date.day}/${date.month}/${date.year}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 60,
        decoration: BoxDecoration(
          gradient: _isSubmitting
              ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900])
              : LinearGradient(colors: [primaryPurple, accentCyan]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isSubmitting ? [] : [
            BoxShadow(color: primaryPurple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        alignment: Alignment.center,
        child: _isSubmitting
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text(
          "LAUNCH TOURNAMENT",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
        ),
      ),
    );
  }
}