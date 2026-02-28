import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/auth_textfield.dart';
import '../../widgets/auth_button.dart';
import '../../theme/auth_theme.dart';
import '../../theme/theme_controller.dart';
import '../../services/auth_service.dart';
import 'otp_verify_screen.dart';   // ✅ ADD

class SignupScreen extends StatefulWidget {
  final ThemeController themeController;
  const SignupScreen({super.key, required this.themeController});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool _startAnim = false;

  final Color neonCyan = const Color(0xFF22D3EE);
  final Color royalPurple = const Color(0xFF6366F1);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _startAnim = true);
    });
  }

  /* ================= SIGNUP ACTION ================= */

  Future<void> _signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _show("Please fill all fields");
      return;
    }

    setState(() => loading = true);

    final result = await AuthService.signup(
      name: name,
      email: email,
      password: password,
    );

    setState(() => loading = false);

    if (result["success"]) {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerifyScreen(
            email: email,
            password: password,
              themeController: widget.themeController
            // ⭐ pass for auto login later
          ),
        ),
      );
      return;
    }

    _show(result["message"] ?? "Signup failed");
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
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      child: _buildUserIcon(),
                    ),
                  ),

                  const SizedBox(height: 30),
                  _buildTypography(isDark),
                  const SizedBox(height: 30),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutBack,
                    transform: Matrix4.translationValues(0, _startAnim ? 0 : 100, 0),
                    child: _buildGlassSignupForm(isDark),
                  ),

                  const SizedBox(height: 32),

                  /// ✅ CONNECTED BUTTON
                  AuthButton(
                    text: "JOIN THE LEAGUE",
                    loading: loading,
                    onTap: _signup,
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: "Already a member? ",
                        style: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                        children: [
                          TextSpan(
                            text: "Sign In",
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

  // ---------- UI (UNCHANGED) ----------

  Widget _buildGlassSignupForm(bool dark) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [royalPurple.withOpacity(0.4), Colors.transparent, neonCyan.withOpacity(0.4)],
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
            AuthTextField(controller: nameController, hint: "Full Name", icon: Icons.person_outline_rounded),
            const SizedBox(height: 16),
            AuthTextField(controller: emailController, hint: "Email", icon: Icons.alternate_email_rounded),
            const SizedBox(height: 16),
            AuthTextField(controller: passwordController, hint: "Password", icon: Icons.lock_open_rounded, obscure: true),
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
              style: TextStyle(color: dark ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
        ),
        IconButton(
          onPressed: widget.themeController.toggle,
          icon: Icon(dark ? Icons.light_mode : Icons.dark_mode, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildUserIcon() => Container(
    width: 90,
    height: 90,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.05),
      border: Border.all(color: Colors.white10),
    ),
    child: Icon(Icons.person_add_rounded, color: neonCyan, size: 40),
  );

  Widget _buildTypography(bool dark) => Column(children: [
    Text(
      "CREATE PROFILE",
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: dark ? Colors.white : Colors.black),
    ),
    const Text("Your journey starts here.", style: TextStyle(color: Colors.white38)),
  ]);

  Widget _buildPulsingBackdrop(bool dark) {
    if (!dark) return const SizedBox.shrink();
    return Stack(children: [
      Positioned(top: -50, right: -50, child: _blurSphere(royalPurple.withOpacity(0.1))),
      Positioned(bottom: 0, left: -50, child: _blurSphere(neonCyan.withOpacity(0.1))),
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