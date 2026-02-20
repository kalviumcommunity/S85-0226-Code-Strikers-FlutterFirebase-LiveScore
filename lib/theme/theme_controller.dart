import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  void toggle() {
    if (_mode == ThemeMode.light) {
      _mode = ThemeMode.dark;
    } else {
      _mode = ThemeMode.light;
    }
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}