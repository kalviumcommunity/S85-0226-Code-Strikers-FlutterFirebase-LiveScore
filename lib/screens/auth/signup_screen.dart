import 'package:flutter/material.dart';
import '../../widgets/auth_textfield.dart';
import '../../widgets/auth_segmented.dart';
import '../../widgets/auth_button.dart';
import '../../theme/auth_theme.dart';
import '../../theme/theme_controller.dart';
import '../../services/auth_service.dart';

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

  Future<void> handleSignup() async {
    setState(() => loading = true);

    // call your backend signup here if needed

    setState(() => loading = false);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _header() {
    final dark = AuthTheme.isDark(context);

    return Row(
      children: [
        const Icon(Icons.bolt, color: AuthTheme.primary),
        const SizedBox(width: 6),
        Text(
          "LIVESCORE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: dark ? Colors.white : Colors.black,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: widget.themeController.toggle,
          icon: Icon(dark ? Icons.dark_mode : Icons.light_mode),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = AuthTheme.isDark(context);

    return Scaffold(
      backgroundColor: dark ? AuthTheme.darkBg : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _header(),
              const SizedBox(height: 30),

              AuthTextField(
                controller: nameController,
                hint: "Full Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 14),

              AuthTextField(
                controller: emailController,
                hint: "Email",
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 14),

              AuthTextField(
                controller: passwordController,
                hint: "Password",
                icon: Icons.lock_outline,
                obscure: true,
              ),

              const SizedBox(height: 24),

              AuthButton(
                text: "Create Account →",
                loading: loading,
                onTap: handleSignup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}