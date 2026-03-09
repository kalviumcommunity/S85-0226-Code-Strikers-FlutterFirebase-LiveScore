import 'package:flutter/material.dart';
import 'package:livescore/theme/theme_controller.dart';
import 'package:livescore/screens/auth/login_screen.dart';
import 'package:livescore/screens/auth/signup_screen.dart';
import 'package:livescore/screens/auth/home/home_screen.dart';
import 'package:livescore/screens/auth/events/events_screen.dart';
import 'package:livescore/screens/auth/teams/teams_screen.dart';
import 'package:livescore/screens/auth/admin/create_tournament_screen.dart';

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

          // ✅ Start Screen
          initialRoute: '/login',

          // ✅ Named Routes
          routes: {
            '/login': (context) =>
                LoginScreen(themeController: controller),
            '/signup': (context) =>
                SignupScreen(themeController: controller),
            '/home': (context) => const HomeScreen(),
            '/events': (context) => const EventsScreen(),
            '/teams': (context) => const TeamsScreen(),
            '/createTournament': (context) =>
            const CreateTournamentScreen(),
          },
        );
      },
    );
  }
}