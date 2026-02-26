import 'package:flutter/material.dart';
import 'package:livescore/models/tournament.dart';
import 'package:livescore/services/auth_service.dart';
import 'package:livescore/services/tournament_service.dart';

class TournamentDetailScreen extends StatelessWidget {
  const TournamentDetailScreen({super.key});

  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color darkBg = const Color(0xFF0F172A);

  Color statusColor(String s) {
    switch (s.toUpperCase()) {
      case "OPEN":
        return Colors.greenAccent;
      case "ONGOING":
        return Colors.orangeAccent;
      case "COMPLETED":
        return Colors.white24;
      default:
        return accentCyan;
    }
  }

  Map<String, dynamic> getSportTheme(String sport) {
    switch (sport.toUpperCase()) {
      case "CRICKET":
        return {
          "color": Colors.greenAccent,
          "icon": Icons.sports_cricket_rounded,
          "label": "Cricket",
        };
      case "FOOTBALL":
        return {
          "color": Colors.blueAccent,
          "icon": Icons.sports_soccer_rounded,
          "label": "Football",
        };
      case "BASKETBALL":
        return {
          "color": Colors.orangeAccent,
          "icon": Icons.sports_basketball_rounded,
          "label": "Basketball",
        };
      case "VOLLEYBALL":
        return {
          "color": Colors.pinkAccent,
          "icon": Icons.sports_volleyball_rounded,
          "label": "Volleyball",
        };
      default:
        return {
          "color": accentCyan,
          "icon": Icons.sports_rounded,
          "label": sport,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final Tournament t =
    ModalRoute.of(context)!.settings.arguments as Tournament;

    final sportTheme = getSportTheme(t.sports);

    return Scaffold(
      backgroundColor: darkBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                (sportTheme["color"] as Color).withOpacity(0.1),
              ),
            ),
          ),

          ListView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 40),
            children: [
              /// SPORT ICON
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryPurple,
                        sportTheme["color"]
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    sportTheme["icon"],
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// NAME
              Center(
                child: Text(
                  t.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// LOCATION
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: sportTheme["color"], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      t.location.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// STATUS + ADMIN
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor(t.registeration)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor(t.registeration)
                              .withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        t.registeration,
                        style: TextStyle(
                          color:
                          statusColor(t.registeration),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    if (AuthService.isAdmin()) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/adminMatches',
                            arguments: t.id,
                          );
                        },
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6),
                          decoration: BoxDecoration(
                            color:
                            accentCyan.withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "MANAGE",
                            style: TextStyle(
                              color: Colors.cyan,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// TEAMS
              _actionCard(
                context,
                label: "View Teams",
                icon: Icons.groups_rounded,
                route: '/tournamentTeams',
                arguments: {
                  "tournamentId": t.id,
                  "sport": t.sports,
                },
              ),

              const SizedBox(height: 16),

              /// FIXTURES
              _actionCard(
                context,
                label: "View Fixtures",
                icon: Icons.sports_kabaddi_rounded,
                route: '/tournamentFixtures',
                arguments: t.id,
              ),

              const SizedBox(height: 30),

              _buildRegisterButton(context, t.id),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context,
      {required String label,
        required IconData icon,
        required String route,
        required dynamic arguments}) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          route,
          arguments: arguments,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentCyan),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton(
      BuildContext context, String tournamentId) {
    return GestureDetector(
      onTap: () async {
        if (!AuthService.isLeader()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                Text("Only team leaders can register")),
          );
          return;
        }

        final teamId = AuthService.teamId;

        if (teamId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("No team found")),
          );
          return;
        }

        final msg =
        await TournamentService.registerTeam(
          teamId: teamId,
          tournamentId: tournamentId,
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      },
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [primaryPurple, accentCyan]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "REGISTER TEAM",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}