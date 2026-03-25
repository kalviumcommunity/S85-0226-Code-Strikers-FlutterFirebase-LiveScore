import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for input formatters
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
    required this.themeController,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  // Using a single controller but you can also use PinCodeTextField packages
  final otpController = TextEditingController();
  bool loading = false;

  final Color neonCyan = const Color(0xFF22D3EE);
  final Color royalPurple = const Color(0xFF6366F1);
  final Color darkBg = const Color(0xFF020617);

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: royalPurple,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length < 4) { // Basic length check
      _show("Please enter the full code");
      return;
    }

    setState(() => loading = true);
    final res = await AuthService.verifySignupOtp(email: widget.email, otp: otp);
    setState(() => loading = false);

    if (!res["success"]) {
      _show(res["message"]);
      return;
    }

    await AuthService.login(email: widget.email, password: widget.password);
    await AuthService.getMe();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(themeController: widget.themeController)),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = AuthTheme.isDark(context);

    return Scaffold(
      backgroundColor: dark ? darkBg : Colors.grey[50],
      body: Stack(
        children: [
          _buildBackgroundBlur(dark),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Top Icon/Graphic
                  _buildHeaderIcon(),

                  const SizedBox(height: 40),
                  Text(
                    "Verification Code",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: dark ? Colors.white : Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "We have sent a 6-digit code to\n${widget.email}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: dark ? Colors.white54 : Colors.black54,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // The Interactive OTP Field
                  _buildModernOtpInput(dark),

                  const SizedBox(height: 40),
                  _buildVerifyButton(),

                  const SizedBox(height: 24),
                  _buildResendSection(dark),
                ],
              ),
            ),
          ),
          if (Navigator.canPop(context))
            SafeArea(child: BackButton(color: dark ? Colors.white : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: royalPurple.withOpacity(0.1),
      ),
      child: Icon(Icons.mark_email_read_outlined, size: 80, color: neonCyan),
    );
  }

  Widget _buildModernOtpInput(bool dark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: otpController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 25, // Creates the visual "box" separation
          color: neonCyan,
        ),
        decoration: InputDecoration(
          hintText: "000000",
          hintStyle: TextStyle(color: dark ? Colors.white10 : Colors.black12),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: royalPurple.withOpacity(0.3), width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: neonCyan, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [royalPurple, royalPurple.withBlue(255)]),
        boxShadow: [
          BoxShadow(
            color: royalPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text(
          "VERIFY & PROCEED",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.1),
        ),
      ),
    );
  }

  Widget _buildResendSection(bool dark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive code?",
          style: TextStyle(color: dark ? Colors.white38 : Colors.black45),
        ),
        TextButton(
          onPressed: _resendOtp,
          child: Text(
            "Resend Now",
            style: TextStyle(color: neonCyan, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundBlur(bool dark) {
    if (!dark) return const SizedBox.shrink();
    return Stack(
      children: [
        Positioned(top: -100, right: -80, child: _blurSphere(royalPurple.withOpacity(0.15))),
        Positioned(bottom: -50, left: -80, child: _blurSphere(neonCyan.withOpacity(0.15))),
      ],
    );
  }

  Widget _blurSphere(Color color) => Container(
    width: 400,
    height: 400,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
      child: Container(color: Colors.transparent),
    ),
  );

  Future<void> _resendOtp() async {
    setState(() => loading = true);
    final res = await AuthService.resendSignupOtp(email: widget.email);
    setState(() => loading = false);
    _show(res["success"] ? "New code sent to your email!" : "Failed to resend. Try again.");
  }
}