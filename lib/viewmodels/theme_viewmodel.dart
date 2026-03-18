import '../services/local/shared_pref_service.dart';

class ThemeViewModel {
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // ─────────────────────────────────────
  // GET THEME
  // ─────────────────────────────────────

  Future<bool> isDarkMode() async {
    return await _sharedPrefService.isDarkMode();
  }

  // ─────────────────────────────────────
  // SAVE THEME
  // ─────────────────────────────────────

  Future<void> saveTheme(bool isDarkMode) async {
    await _sharedPrefService.saveTheme(isDarkMode);
  }
}
