import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/auth_service.dart';
import '../../../../theme/theme_controller.dart';
import '../../login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ThemeController themeController; // 1. Add this field

  // 2. Add it to the constructor
  const ProfileScreen({super.key, required this.themeController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  Map<String, dynamic>? stats;
  bool loading = true;

  final Color neonCyan = const Color(0xFF22D3EE);
  final Color royalPurple = const Color(0xFF6366F1);
  final Color darkBg = const Color(0xFF020617);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final meResponse = await AuthService.getMe();

    if (meResponse["success"]) {
      user = meResponse["user"];

      final role = AuthService.role;

      Map<String, dynamic>? statsResponse;

      if (role == "PLAYER" || role == "ROLE_PLAYER") {
        statsResponse = await AuthService.getPlayerStats();
      }
      else if (role == "TEAM_LEADER") {
        statsResponse = await AuthService.getTeamLeaderStats();
      }
      else if (role == "USER" || role == "ROLE_USER") {
        statsResponse = await AuthService.getUserStats();
      }
      else if (role == "ADMIN" || role == "ROLE_ADMIN") {
        statsResponse = await AuthService.getAdminStats();
      }

      if (statsResponse != null && statsResponse["success"]) {
        stats = statsResponse["stats"];
      }
    }

    if (!mounted) return;
    setState(() => loading = false);
  }
  Widget _buildTeamLeaderStats() {
    final items = [
      {"l": "TEAM", "v": stats!["teamName"] ?? "-", "i": Icons.group},
      {"l": "PLAYERS", "v": stats!["currentPlayers"].toString(), "i": Icons.people},
      {"l": "MATCHES", "v": stats!["totalMatches"].toString(), "i": Icons.sports},
      {"l": "WINS", "v": stats!["wins"].toString(), "i": Icons.emoji_events},
      {"l": "LOSSES", "v": stats!["losses"].toString(), "i": Icons.close},
      {"l": "DRAWS", "v": stats!["draws"].toString(), "i": Icons.horizontal_rule},
    ];

    return _buildGenericGrid(items);
  }
  Widget _buildUserStats() {
    final items = [
      {"l": "AVAILABLE TEAMS", "v": stats!["availableTeams"].toString(), "i": Icons.group},
      {"l": "TOURNAMENTS", "v": stats!["openTournaments"].toString(), "i": Icons.emoji_events},
      {"l": "MATCHES", "v": stats!["upcomingMatches"].toString(), "i": Icons.sports},
      {"l": "REQUESTS", "v": stats!["pendingTeamRequests"].toString(), "i": Icons.mail},
      {"l": "NOTIFICATIONS", "v": stats!["unreadNotifications"].toString(), "i": Icons.notifications},
    ];

    return _buildGenericGrid(items);
  }
  Widget _buildAdminStats() {
    final items = [
      {"l": "USERS", "v": stats!["totalUsers"].toString(), "i": Icons.people},
      {"l": "TEAMS", "v": stats!["totalTeams"].toString(), "i": Icons.group_work},
      {"l": "MATCHES", "v": stats!["totalMatches"].toString(), "i": Icons.sports},
      {"l": "LIVE", "v": stats!["liveMatches"].toString(), "i": Icons.wifi},
      {"l": "TOURNAMENTS", "v": stats!["totalTournaments"].toString(), "i": Icons.emoji_events},
      {"l": "REQUESTS", "v": stats!["pendingJoinRequests"].toString(), "i": Icons.pending},
    ];

    return _buildGenericGrid(items);
  }
  Widget _buildGenericGrid(List<Map<String, dynamic>> items) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final item = items[index];
          return _statCard(
            item['l'],
            item['v'],
            item['i'],
          );
        },
        childCount: items.length,
      ),
    );
  }
  Widget _buildPlayerStats() {
    return _buildSliverStatsGrid();
  }

  Widget _buildRoleBasedStats() {
    final role = AuthService.role;

    if (role == "PLAYER" || role == "ROLE_PLAYER") {
      return _buildPlayerStats();
    } else if (role == "TEAM_LEADER") {
      return _buildTeamLeaderStats();
    } else if (role == "USER" || role == "ROLE_USER") {
      return _buildUserStats();
    } else if (role == "ADMIN" || role == "ROLE_ADMIN") {
      return _buildAdminStats();
    }

    return const SliverToBoxAdapter(child: Text("No stats available"));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: darkBg,
        body: Center(child: CircularProgressIndicator(color: neonCyan)),
      );
    }

    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // 1. AMBIENT BACKGROUND GLOW
          Positioned(top: -100, right: -50, child: _blurSphere(royalPurple.withOpacity(0.15))),
          Positioned(bottom: -50, left: -50, child: _blurSphere(neonCyan.withOpacity(0.1))),

          // 2. MAIN SCROLLABLE CONTENT
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),

              // Profile Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 40),
                  child: _buildProfileHeader(),
                ),
              ),

              // Statistics Section Label
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "CAREER STATISTICS",
                    style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 2),
                  ),
                ),
              ),

              // 3. STATS GRID (Using Slivers for perfect scrolling)
              if (stats != null)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: _buildRoleBasedStats(),
                ),
              // Bottom Spacer for clean finish
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                HapticFeedback.mediumImpact(); // Professional tactile feel

                // 1. Clear session data (Security)
                AuthService.token = null;
                AuthService.role = null;
                AuthService.userId = null;

                // 2. Wipe the stack and return to Login
                // This removes every previous screen so the user cannot go "Back"
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(
                      themeController: widget.themeController, // Pass the controller back
                    ),
                  ),
                      (route) => false, // This condition 'false' tells Flutter to remove all routes
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.redAccent, size: 16),
                    SizedBox(width: 4),
                    Text("EXIT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar with animated-style border
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [neonCyan, royalPurple]),
          ),
          child: CircleAvatar(
            radius: 54,
            backgroundColor: darkBg,
            child: Text(
              user!["name"][0].toUpperCase(),
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          user!["name"].toUpperCase(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            AuthService.role?.replaceAll("ROLE_", "") ?? "PLAYER",
            style: TextStyle(color: neonCyan, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverStatsGrid() {
    int runs = stats!["runs"] ?? 0;
    int balls = stats!["ballsFaced"] ?? 0;
    int runsConceded = stats!["runsConceded"] ?? 0;
    int ballsBowled = stats!["ballsBowled"] ?? 0;
    double sr = balls == 0 ? 0 : ((runs / balls) * 100);
    double eco = ballsBowled == 0 ? 0 : (runsConceded / (ballsBowled / 6));

    final items = [
      {"l": "MATCHES", "v": stats!["matches"].toString(), "i": Icons.sports_cricket},
      {"l": "RUNS", "v": runs.toString(), "i": Icons.bolt},
      {"l": "STRIKE RATE", "v": sr.toStringAsFixed(1), "i": Icons.speed},
      {"l": "WICKETS", "v": stats!["wickets"].toString(), "i": Icons.adjust},
      {"l": "ECONOMY", "v": eco.toStringAsFixed(2), "i": Icons.trending_down},
      {"l": "BOUNDARIES", "v": (stats!["fours"] + stats!["sixes"]).toString(), "i": Icons.star},
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) => _statCard(items[index]['l'] as String, items[index]['v'] as String, items[index]['i'] as IconData),
        childCount: items.length,
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: neonCyan.withOpacity(0.4), size: 18),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _blurSphere(Color color) => Container(
    width: 300, height: 300,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90), child: Container(color: Colors.transparent)),
  );
}