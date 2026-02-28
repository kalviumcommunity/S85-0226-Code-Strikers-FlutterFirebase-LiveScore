import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/auth_theme.dart';
import '../../theme/theme_controller.dart';
import 'login_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  final String password;
  final ThemeController themeController;

  const OtpVerifyScreen({
    super.key,
    required this.email,
    required this.password,
    required this.themeController
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final otpController = TextEditingController();
  bool loading = false;

  final Color neonCyan = const Color(0xFF22D3EE);
  final Color royalPurple = const Color(0xFF6366F1);

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /* ================= VERIFY OTP ================= */

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      _show("Enter OTP");
      return;
    }

    setState(() => loading = true);

    final res = await AuthService.verifySignupOtp(
      email: widget.email,
      otp: otp,
    );

    setState(() => loading = false);

    if (!res["success"]) {
      _show(res["message"]);
      return;
    }

    /// ⭐ auto login after OTP
    await AuthService.login(
      email: widget.email,
      password: widget.password,
    );

    await AuthService.getMe();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          themeController: widget.themeController, // ⭐ pass
        ),
      ),
          (_) => false,
    );
  }

  /* ================= RESEND OTP ================= */

  Future<void> _resendOtp() async {
    final res = await AuthService.resendSignupOtp(
      email: widget.email,
    );

    _show(res["success"] ? "OTP resent" : "Failed to resend OTP");
  }

  @override
  Widget build(BuildContext context) {
    final dark = AuthTheme.isDark(context);

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF020617) : Colors.white,
      body: Stack(
        children: [
          _bg(dark),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  Text(
                    "VERIFY OTP",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: dark ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Code sent to ${widget.email}",
                    style: const TextStyle(color: Colors.white38),
                  ),

                  const SizedBox(height: 40),

                  _otpField(dark),

                  const SizedBox(height: 30),

                  _verifyButton(),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: _resendOtp,
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: neonCyan,
                        fontWeight: FontWeight.bold,
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

  Widget _otpField(bool dark) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [royalPurple.withOpacity(0.4), neonCyan.withOpacity(0.4)],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: dark ? Colors.black.withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 22,
            letterSpacing: 8,
            color: dark ? Colors.white : Colors.black,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "------",
          ),
        ),
      ),
    );
  }

  Widget _verifyButton() {
    return ElevatedButton(
      onPressed: loading ? null : _verifyOtp,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        backgroundColor: neonCyan,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: loading
          ? const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : const Text(
        "VERIFY",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _bg(bool dark) {
    if (!dark) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned(top: -50, right: -50, child: _sphere(royalPurple)),
        Positioned(bottom: 0, left: -50, child: _sphere(neonCyan)),
      ],
    );
  }

  Widget _sphere(Color color) => Container(
    width: 300,
    height: 300,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(0.1),
    ),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(color: Colors.transparent),
    ),
  );
}