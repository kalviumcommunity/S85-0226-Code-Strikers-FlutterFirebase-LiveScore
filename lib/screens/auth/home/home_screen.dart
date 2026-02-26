import 'package:flutter/material.dart';
import '../../../widgets/glow_bottom_nav.dart';
import 'package:livescore/screens/auth/events/events_screen.dart';
import 'package:livescore/screens/auth/teams/teams_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final bool isAdmin = user?["role"] == "ADMIN";

    final pages = [
      _homePage(),            // 0 HOME
      const TeamsScreen(),    // 1 TEAMS
      const SizedBox(),       // 2 CENTER (unused)
      const EventsScreen(),   // 3 EVENTS
      const Center(child: Text("Profile")), // 4 PROFILE
    ];

    return Scaffold(
      extendBody: true,
      body: pages[index],
      bottomNavigationBar: GlowBottomNav(
        index: index,
        isAdmin: isAdmin,
        onTap: (i) {
          if (i == 2) {
            if (!isAdmin) return;
            Navigator.pushNamed(context, '/createTournament');
            return;
          }

          setState(() => index = i);
        },
      ),
    );
  }

  Widget _homePage() {
    final user = widget.user;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Livescore Home",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (user != null) ...[
              Text("Name: ${user["name"]}"),
              Text("Email: ${user["email"]}"),
              Text("UID: ${user["id"]}"),
              Text("Role: ${user["role"]}"),
            ],
          ],
        ),
      ),
    );
  }
}