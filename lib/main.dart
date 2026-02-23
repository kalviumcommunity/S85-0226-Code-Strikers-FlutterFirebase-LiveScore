import 'package:flutter/material.dart';
import 'package:livescore/screens/auth/login_screen.dart';
import 'package:livescore/theme/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LiveScoreApp());
}

class LiveScoreApp extends StatefulWidget {
  const LiveScoreApp({super.key});

  @override
  State<LiveScoreApp> createState() => _LiveScoreAppState();
}

class _LiveScoreAppState extends State<LiveScoreApp> {
  final ThemeController controller = ThemeController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LiveScore',
          themeMode: controller.mode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: LoginScreen(themeController: controller),
        );
      },
    );
  }
}