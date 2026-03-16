import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Internal Imports
import '../../../theme/theme_controller.dart';
import '../../../widgets/glow_bottom_nav.dart';
import 'package:livescore/screens/auth/events/events_screen.dart';
import 'package:livescore/screens/auth/teams/teams_screen.dart';
import '../Live/LiveMatchesScreen.dart';
import '../admin/create_tournament_screen.dart';
import '../profile/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  bool isLogin = true;

  void submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    _formKey.currentState!.save();

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? "Authentication failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              key: const ValueKey("email"),
              decoration: const InputDecoration(labelText: "Email"),
              validator: (value) {
                if (value == null || !value.contains("@")) {
                  return "Enter valid email";
                }
                return null;
              },
              onSaved: (value) {
                email = value!;
              },
            ),
            TextFormField(
              key: const ValueKey("password"),
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return "Password must be 6+ chars";
                }
                return null;
              },
              onSaved: (value) {
                password = value!;
              },
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: submit,
              child: Text(isLogin ? "Login" : "Signup"),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(isLogin
                  ? "Create new account"
                  : "Already have account? Login"),
            )
          ],
        ),
      ),
    );
  }
}
import '../widgets/info_card.dart';
class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final ThemeController themeController;

  const HomeScreen({super.key, this.user, required this.themeController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  List tournaments = [];
  bool loadingTournaments = true;

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color primaryPurple = const Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85, initialPage: 0);
    loadTournaments();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadTournaments() async {
    try {
      final res = await http.get(
        Uri.parse(
            "https://livescorebackend-production.up.railway.app/get/tournament"),
      );

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
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  Color _getSportColor(String? sport) {
    switch (sport?.toUpperCase()) {
      case "CRICKET":
        return Colors.greenAccent;
      case "FOOTBALL":
        return Colors.blueAccent;
      case "BASKETBALL":
        return Colors.orangeAccent;
      case "VOLLEYBALL":
        return Colors.pinkAccent;
      default:
        return accentCyan;
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
      const SizedBox(),
      const EventsScreen(),
      ProfileScreen(themeController: widget.themeController),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CreateTournamentScreen()),
            );
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
            physics: const BouncingScrollPhysics(),
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
              const SizedBox(height: 32),
              _sectionHeader("QUICK INSIGHTS"),
              const SizedBox(height: 16),
              _buildQuickStats(),
              const SizedBox(height: 32),
              _sectionHeader("UPCOMING EVENTS"),
              _buildUpcomingList(),
              const SizedBox(height: 120),
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
              Text("Welcome back,",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 13)),
              Text(
                widget.user?["name"] ?? "Player",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
          _iconButton(Icons.notifications_none_rounded),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Icon(icon, color: accentCyan),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: TextStyle(
            color: accentCyan,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildAutoSlider() {
    if (loadingTournaments) {
      return const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()));
    }
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        itemCount: tournaments.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
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
                  child: Transform.scale(scale: value, child: child));
            },
            child: _tournamentCard(t, sColor),
          );
        },
      ),
    );
  }

  Widget _tournamentCard(Map t, Color sColor) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => LiveMatchesScreen(
                  tournamentId: t["id"],
                  tournamentName: t["name"] ?? "Tournament"))),
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
              colors: [sColor.withOpacity(0.1), Colors.transparent]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _badge(
                    t["sports"]?.toString().toUpperCase() ?? "SPORT", sColor),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white24, size: 14),
              ],
            ),
            const Spacer(),
            Text(t["name"] ?? "Tournament",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: sColor, size: 14),
                const SizedBox(width: 4),
                Text(t["location"] ?? "Main Ground",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 13)),
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
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        tournaments.length,
            (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 4,
          width: _currentPage == i ? 20 : 8,
          decoration: BoxDecoration(
              color: _currentPage == i ? accentCyan : Colors.white12,
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildEmptyLiveState() {
    return const SizedBox(
      height: 120,
      width: double.infinity,
      child: _CricketAnimation(),
    );
  }

  Widget _buildQuickStats() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          _statItem("🏆", "12 Active", "Tournaments"),
          _statItem("🏃", "450+", "Players"),
          _statItem("📍", "8 Venues", "Registered"),
        ],
      ),
    );
  }

  Widget _statItem(String emoji, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      width: 130,
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          Text(sub,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildUpcomingList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg.withOpacity(0.2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                  backgroundColor: accentCyan.withOpacity(0.1),
                  child: Icon(Icons.event, color: accentCyan, size: 20)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Weekend Championship",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Text("Starts in 2 days • Kalam Block",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white24, size: 14),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CRICKET ANIMATION  (bat hits ball → ball flies off with trail)
// ─────────────────────────────────────────────────────────────────────────────

class _CricketAnimation extends StatefulWidget {
  const _CricketAnimation();

  @override
  State<_CricketAnimation> createState() => _CricketAnimationState();
}

class _CricketAnimationState extends State<_CricketAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _ballX;
  late Animation<double> _ballY;
  late Animation<double> _ballOpacity;
  late Animation<double> _batAngle;
  late Animation<double> _flashOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: false);

    _ballX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 130.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 40),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 180.0).chain(CurveTween(curve: Curves.linear)), weight: 55),
    ]).animate(_controller);

    _ballY = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(6.0), weight: 40),
      TweenSequenceItem(tween: ConstantTween(6.0), weight: 5),
      TweenSequenceItem(
        tween: TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 6.0, end: -60.0).chain(CurveTween(curve: Curves.easeOut)), weight: 45),
          TweenSequenceItem(tween: Tween(begin: -60.0, end: 6.0).chain(CurveTween(curve: Curves.easeIn)), weight: 55),
        ]),
        weight: 55,
      ),
    ]).animate(_controller);

    _ballOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 92),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 8),
    ]).animate(_controller);

    _batAngle = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: -1.1).chain(CurveTween(curve: Curves.easeInExpo)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: -1.1, end: -1.5).chain(CurveTween(curve: Curves.easeOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -1.5, end: 0.9).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
    ]).animate(_controller);

    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 43),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 7),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: double.infinity,
          height: 110,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ── Ground shadow ──────────────────────────────────────────────
              Positioned(
                bottom: 12,
                child: Container(
                  width: 60,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // ── Bat ──────────────────────────────────
              Transform.translate(
                offset: const Offset(-20, 10),
                child: Transform.rotate(
                  angle: _batAngle.value,
                  alignment: Alignment.topCenter,
                  child: CustomPaint(
                    size: const Size(22, 72),
                    painter: _BatPainter(),
                  ),
                ),
              ),

              // ── Impact flash ───────────────────────────────────
              Opacity(
                opacity: _flashOpacity.value,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellowAccent.withOpacity(0.6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellowAccent.withOpacity(0.8),
                        blurRadius: 20,
                        spreadRadius: 6,
                      )
                    ],
                  ),
                ),
              ),

              // ── Ball ──────────────────────────────────────────────────────
              Transform.translate(
                offset: Offset(_ballX.value, _ballY.value),
                child: Opacity(
                  opacity: _ballOpacity.value,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFF7F1D1D)],
                        center: Alignment(-0.3, -0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: CustomPaint(painter: _BallSeamPainter()),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painters
// ─────────────────────────────────────────────────────────────────────────────

class _BatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bladePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [Color(0xFFB45309), Color(0xFFD97706), Color(0xFFF59E0B)],
      ).createShader(Rect.fromLTWH(0, size.height * 0.28, size.width, size.height * 0.72));

    final bladePath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.30)
      ..lineTo(size.width * 0.85, size.height * 0.30)
      ..lineTo(size.width * 1.0, size.height * 0.75)
      ..quadraticBezierTo(size.width, size.height, size.width * 0.5, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height * 0.75)
      ..close();

    canvas.drawPath(bladePath, bladePaint);

    final edgePaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(bladePath, edgePaint);

    final grainPaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (double x in [0.3, 0.5, 0.7]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.38),
        Offset(size.width * x, size.height * 0.92),
        grainPaint,
      );
    }

    final handlePaint = Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFF334155), Color(0xFF1E293B)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(size.width * 0.32, 0, size.width * 0.36, size.height * 0.34));

    final handleRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.32, 0, size.width * 0.36, size.height * 0.34),
      const Radius.circular(4),
    );
    canvas.drawRRect(handleRRect, handlePaint);

    final gripPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double y = 0.05; y < 0.32; y += 0.07) {
      canvas.drawLine(
        Offset(size.width * 0.32, size.height * y),
        Offset(size.width * 0.68, size.height * y),
        gripPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BallSeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final seamPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..cubicTo(
        size.width * 0.2, size.height * 0.35,
        size.width * 0.8, size.height * 0.65,
        size.width * 0.5, size.height * 0.9,
      );
    canvas.drawPath(path, seamPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}