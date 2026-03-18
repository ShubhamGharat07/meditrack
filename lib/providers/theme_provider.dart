import 'package:flutter/material.dart';
import '../viewmodels/theme_viewmodel.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeViewModel _themeViewModel = ThemeViewModel();

  // ─────────────────────────────────────
  // STATES
  // ─────────────────────────────────────

  bool _isDarkMode = false;

  // Getter
  bool get isDarkMode => _isDarkMode;

  // ThemeMode — Will be used in MaterialApp
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // ─────────────────────────────────────
  // LOAD THEME — App start pe
  // ─────────────────────────────────────

  Future<void> loadTheme() async {
    // SharedPref se saved theme lo
    // ViewModel → SharedPrefService → SharedPreferences
    _isDarkMode = await _themeViewModel.isDarkMode();
    notifyListeners();
  }

  // ─────────────────────────────────────
  // TOGGLE THEME
  // ─────────────────────────────────────

  Future<void> toggleTheme() async {
    // Toggle theme
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // UI instantly update

    // Save in SharedPref
    // ViewModel → SharedPrefService → SharedPreferences
    await _themeViewModel.saveTheme(_isDarkMode);
  }
}
