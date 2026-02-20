import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'theme/theme_controller.dart';

void main() {
  runApp(LiveScoreApp());
}

class LiveScoreApp extends StatelessWidget {
  final ThemeController controller = ThemeController();

  LiveScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LiveScore',

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0B1220),
          ),

          themeMode: controller.mode,

          home: LoginScreen(themeController: controller),
        );
      },
    );
  }
}