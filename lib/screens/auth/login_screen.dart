import 'package:flutter/material.dart';
import '../../../widgets/auth_textfield.dart';
import '../../../widgets/auth_segmented.dart';
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

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    setState(() => loading = true);

    final loginResult = await AuthService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    if (!loginResult["success"]) {
      setState(() => loading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loginResult["message"])));
      return;
    }

    final meResult = await AuthService.getMe();

    setState(() => loading = false);

    if (!mounted) return;

    if (meResult["success"]) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(user: meResult["user"]),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(meResult["message"])));
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
                child: const Icon(
                  Icons.emoji_events,
                  color: AuthTheme.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),

              Text(
                "Welcome Champion",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: dark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                "Sign in to track live matches and tournaments.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark ? Colors.white60 : Colors.grey,
                ),
              ),

              const SizedBox(height: 26),

              AuthSegmented(
                isLogin: true,
                onLogin: () {},
                onSignup: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SignupScreen(
                        themeController: widget.themeController,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 26),

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

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                    color: AuthTheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              AuthButton(
                text: "Login →",
                loading: loading,
                onTap: handleLogin,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}