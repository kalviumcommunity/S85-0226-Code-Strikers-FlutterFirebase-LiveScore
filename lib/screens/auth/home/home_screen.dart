import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Internal Imports (Ensure these paths match your project structure)
import '../../../widgets/glow_bottom_nav.dart';
import 'package:livescore/screens/auth/events/events_screen.dart';
import 'package:livescore/screens/auth/teams/teams_screen.dart';
import '../Live/LiveMatchesScreen.dart';
import '../admin/create_tournament_screen.dart';
import '../live_score_screen.dart';
import '../tournament/TournamentMatchesScreen.dart';


class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Navigation & Data State
  int index = 0;
  List tournaments = [];
  bool loadingTournaments = true;

  // Animation Controllers
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  // Modern Design Palette
  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color primaryPurple = const Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    // viewportFraction 0.85 makes the side cards "peek" in
    _pageController = PageController(viewportFraction: 0.85, initialPage: 0);
    loadTournaments();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// FETCH TOURNAMENTS
  Future<void> loadTournaments() async {
    try {
      final res = await http.get(Uri.parse("https://livescorebackend-production.up.railway.app/get/tournament"));
      if (res.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          tournaments = json.decode(res.body);
          loadingTournaments = false;
        });
        if (tournaments.isNotEmpty) _startAutoSlide();
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  /// AUTO-SLIDE LOGIC
  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < tournaments.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800), // Speed of the move
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  /// DYNAMIC SPORT COLORING
  Color _getSportColor(String? sport) {
    switch (sport?.toUpperCase()) {
      case "CRICKET": return Colors.greenAccent;
      case "FOOTBALL": return Colors.blueAccent;
      case "BASKETBALL": return Colors.orangeAccent;
      case "VOLLEYBALL": return Colors.pinkAccent;
      default: return accentCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.user?["role"] == "ADMIN";

    final pages = [

      _homePage(),            // 0 HOME
      const TeamsScreen(),    // 1 TEAMS
      const SizedBox(),       // 2 CENTER (unused)
      const EventsScreen(),   // 3 EVENTS
      const Center(child: Text("Profile")), // 4 PROFILE

      _homePage(),
      const TeamsScreen(),
      const SizedBox(), // Placeholder for Admin Nav
      const EventsScreen(),
      const Center(child: Text("Profile", style: TextStyle(color: Colors.white))),
    ];

    return Scaffold(
      backgroundColor: darkBg,
      extendBody: true,
      body: pages[index],
      bottomNavigationBar: GlowBottomNav(
        index: index,
        isAdmin: isAdmin,
        onTap: (i) {
          if (i == 2 && isAdmin) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTournamentScreen()));
            return;
          }
          setState(() => index = i);
        },
      ),
    );
  }

  Widget _homePage() {
    return Stack(
      children: [
        // Top-Right Ambient Glow
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryPurple.withOpacity(0.1),
            ),
          ),
        ),

        SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              _buildTopBar(),
              const SizedBox(height: 30),
              _sectionHeader("FEATURED TOURNAMENTS"),
              const SizedBox(height: 16),
              _buildAutoSlider(),
              const SizedBox(height: 10),
              _buildPageIndicator(),
              const SizedBox(height: 32),
              _sectionHeader("LIVE MATCH UPDATES"),
              _buildEmptyLiveState(),
              const SizedBox(height: 100), // Extra space for Bottom Nav
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome back,", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
              Text(widget.user?["name"] ?? "Player",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          Container(
            height: 45, width: 45,
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
            child: Icon(Icons.notifications_none_rounded, color: accentCyan),
          )
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title,
          style: TextStyle(color: accentCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  /// THE AUTO-SLIDING TOURNAMENT CAROUSEL
  Widget _buildAutoSlider() {
    if (loadingTournaments) {
      return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
    }

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        itemCount: tournaments.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) {
          final t = tournaments[i];
          final sColor = _getSportColor(t["sports"]);

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = (_pageController.page! - i);
                value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
              }
              return Center(
                child: Transform.scale(
                  scale: value,
                  child: child,
                ),
              );
            },
            child: _tournamentCard(t, sColor),
          );
        },
      ),
    );
  }

  Widget _tournamentCard(Map t, Color sColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LiveMatchesScreen(
              tournamentId: t["id"],
              tournamentName: t["name"] ?? "Tournament",
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: sColor.withOpacity(0.3)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [sColor.withOpacity(0.1), Colors.transparent],
          ),
          boxShadow: [
            BoxShadow(color: sColor.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _badge(t["sports"]?.toString().toUpperCase() ?? "SPORT", sColor),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
              ],
            ),
            const Spacer(),
            Text(t["name"] ?? "Tournament",
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: sColor, size: 14),
                const SizedBox(width: 4),
                Text(t["location"] ?? "Main Ground",
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(tournaments.length, (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        height: 4,
        width: _currentPage == i ? 20 : 8,
        decoration: BoxDecoration(
          color: _currentPage == i ? accentCyan : Colors.white12,
          borderRadius: BorderRadius.circular(10),
        ),
      )),
    );
  }

  Widget _buildEmptyLiveState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: cardBg.withOpacity(0.3), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          Icon(Icons.sports_baseball_outlined, color: primaryPurple.withOpacity(0.3), size: 40),
          const SizedBox(height: 16),
          const Text("No Match Selected", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Text("Pick a tournament above to see live scores", style: TextStyle(color: Colors.white24, fontSize: 11)),
        ],
      ),
    );
  }
}