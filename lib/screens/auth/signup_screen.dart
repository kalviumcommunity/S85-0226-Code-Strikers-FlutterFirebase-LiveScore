import 'package:flutter/material.dart';
import '../../../widgets/auth_textfield.dart';
import '../../../widgets/auth_segmented.dart';
import '../../../widgets/auth_button.dart';
import '../../../theme/auth_theme.dart';
import '../../../theme/theme_controller.dart';
import '../../../services/auth_service.dart';

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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleSignup() async {
    setState(() => loading = true);

    final result = await AuthService.signup(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() => loading = false);

    if (!mounted) return;

    if (result["success"]) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result["message"])));
    }
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
              const SizedBox(height: 26),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: dark ? AuthTheme.darkCard : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.person_add_alt_1,
                    color: AuthTheme.primary, size: 36),
              ),
              const SizedBox(height: 18),

              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: dark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                "Join LiveScore to follow matches live.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark ? Colors.white60 : Colors.grey,
                ),
              ),

              const SizedBox(height: 26),

              AuthSegmented(
                isLogin: false,
                onLogin: () => Navigator.pop(context),
                onSignup: () {},
              ),

              const SizedBox(height: 26),

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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}