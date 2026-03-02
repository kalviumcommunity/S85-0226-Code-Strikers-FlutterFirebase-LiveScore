import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/auth_textfield.dart';
import '../../../widgets/auth_button.dart';
import '../../../theme/auth_theme.dart';
import '../../../theme/theme_controller.dart';
import '../../../services/auth_service.dart';
import 'signup_screen.dart';
import 'package:livescore/screens/auth/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  final ThemeController themeController;
  const LoginScreen({super.key, required this.themeController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool _startAnim = false;

  final Color neonCyan = const Color(0xFF22D3EE);
  final Color royalPurple = const Color(0xFF6366F1);

  Map<String, dynamic>? get userData => null;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _startAnim = true);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /* ================= LOGIN (MERGED) ================= */

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _show("Enter email & password");
      return;
    }

    setState(() => loading = true);

    final loginResult = await AuthService.login(
      email: email,
      password: password,
    );

    if (!loginResult["success"]) {
      setState(() => loading = false);
      _show(loginResult["message"] ?? "Login failed");
      return;
    }

    final meResult = await AuthService.getMe();

    setState(() => loading = false);

    if (!mounted) return;

    if (meResult["success"]) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            user: userData,
            themeController: widget.themeController, // Handing over the baton
          ),
        ),
      );
      return;
    }

    _show(meResult["message"] ?? "Auth failed");
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AuthTheme.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
      body: Stack(
        children: [
          _buildPulsingBackdrop(isDark),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(isDark),
                  const SizedBox(height: 30),

                  Hero(
                    tag: 'auth_icon',
                    child: AnimatedScale(
                      scale: _startAnim ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                      child: _buildGlassLogo(),
                    ),
                  ),

                  const SizedBox(height: 40),
                  _buildTypography(isDark),
                  const SizedBox(height: 40),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutBack,
                    transform: Matrix4.translationValues(0, _startAnim ? 0 : 120, 0),
                    child: _buildGlassForm(isDark),
                  ),

                  const SizedBox(height: 40),

                  AuthButton(
                    text: "ENTER ARENA",
                    loading: loading,
                    onTap: _login,
                  ),

                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignupScreen(
                            themeController: widget.themeController,
                          ),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "New Athlete? ",
                        style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                        children: [
                          TextSpan(
                            text: "Create Profile",
                            style: TextStyle(color: neonCyan, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI (UNCHANGED FROM 2nd CODE) ----------

  Widget _buildGlassForm(bool dark) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            neonCyan.withOpacity(0.4),
            Colors.transparent,
            royalPurple.withOpacity(0.4)
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: dark ? Colors.black.withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          children: [
            AuthTextField(
              controller: emailController,
              hint: "Email",
              icon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: 20),
            AuthTextField(
              controller: passwordController,
              hint: "Password",
              icon: Icons.lock_open_rounded,
              obscure: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool dark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Hero(
          tag: 'brand_name',
          child: Material(
            color: Colors.transparent,
            child: Text(
              "LIVESCORE",
              style: TextStyle(
                color: neonCyan,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: widget.themeController.toggle,
          icon: Icon(
            dark ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassLogo() => Container(
    width: 110,
    height: 110,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      color: Colors.white.withOpacity(0.05),
      border: Border.all(color: Colors.white10),
    ),
    child: Icon(Icons.emoji_events_rounded, color: neonCyan, size: 50),
  );

  Widget _buildTypography(bool dark) => Column(
    children: [
      Text(
        "ARENA LOGIN",
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: dark ? Colors.white : Colors.black,
        ),
      ),
      const Text(
        "Step into the game.",
        style: TextStyle(color: Colors.white38),
      ),
    ],
  );

  Widget _buildPulsingBackdrop(bool dark) {
    if (!dark) return const SizedBox.shrink();
    return Stack(children: [
      Positioned(top: -50, left: -50, child: _blurSphere(royalPurple.withOpacity(0.1))),
      Positioned(bottom: 0, right: -50, child: _blurSphere(neonCyan.withOpacity(0.1))),
    ]);
  }

  Widget _blurSphere(Color color) => Container(
    width: 300,
    height: 300,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(color: Colors.transparent),
    ),
  );
}