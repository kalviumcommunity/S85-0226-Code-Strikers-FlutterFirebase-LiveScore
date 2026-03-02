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
      if (AuthService.role == "PLAYER" || AuthService.role == "ROLE_PLAYER") {
        final statsResponse = await AuthService.getPlayerStats();
        if (statsResponse["success"]) {
          stats = statsResponse["stats"];
        }
      }
    }
    if (!mounted) return;
    setState(() => loading = false);
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
                  sliver: _buildSliverStatsGrid(),
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