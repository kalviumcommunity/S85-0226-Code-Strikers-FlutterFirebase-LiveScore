// lib/theme/auth_theme.dart
import 'package:flutter/material.dart';

class AuthTheme {
  static const primary = Color(0xFF3B82F6);
  static const darkBg = Color(0xFF0B1220);
  static const darkCard = Color(0xFF111827);
  static const lightBg = Colors.white;
  static const fieldLight = Color(0xFFF1F5F9);
  static const fieldDark = Color(0xFF1F2937);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}