import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String _tokenKey = 'token';
  static const String _isFirstTimeKey = 'isFirstTime';
  static const String _isDarkModeKey = 'isDarkMode';
  static const String _selectedFamilyMemberKey = 'selectedFamilyMember';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';

  // ─────────────────────────────────────
  // TOKEN
  // ─────────────────────────────────────

  // Save token — After Login
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Token nikalo
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Delete token — After Logout
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ─────────────────────────────────────
  // FIRST TIME CHECK
  // ─────────────────────────────────────

  // Pehli baar app khula?
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }

  // Onboarding viewed — save state
  Future<void> setFirstTimeDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, false);
  }

  // ─────────────────────────────────────
  // THEME
  // ─────────────────────────────────────

  // Check if dark mode is active
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkModeKey) ?? false;
  }

  // Save theme
  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, isDarkMode);
  }

  // ─────────────────────────────────────
  // USER INFO
  // ─────────────────────────────────────

  // Save user info
  Future<void> saveUserInfo(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
  }

  // User name nikalo
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // User email nikalo
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // ─────────────────────────────────────
  // FAMILY MEMBER
  // ─────────────────────────────────────

  // Save selected family member
  Future<void> saveSelectedFamilyMember(String memberId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedFamilyMemberKey, memberId);
  }

  // Selected family member nikalo
  Future<String?> getSelectedFamilyMember() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedFamilyMemberKey);
  }

  // ─────────────────────────────────────
  // CLEAR ALL — Logout
  // ─────────────────────────────────────

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
