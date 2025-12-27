import 'package:shared_preferences/shared_preferences.dart';

/// Repository for persisting theme preferences using SharedPreferences.
/// 
/// Uses SharedPreferences instead of Firestore because:
/// - Fast, synchronous access on app startup (no loading flicker)
/// - Theme is a local UI preference, doesn't need cloud sync
/// - No network dependency
class ThemeRepository {
  static const String _themeKey = 'app_theme_mode';

  /// Save theme mode to local storage.
  /// 
  /// [mode] can be: 'light', 'dark', or 'system'
  Future<void> saveThemeMode(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode);
    } catch (e) {
      // Fail silently - theme will default to system on next load
    }
  }

  /// Load saved theme mode from local storage.
  /// 
  /// Returns: 'light', 'dark', 'system', or null if not set
  Future<String?> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_themeKey);
    } catch (e) {
      return null;
    }
  }

  /// Clear saved theme preference.
  /// Useful for testing or reset functionality.
  Future<void> clearThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeKey);
    } catch (e) {
    }
  }
}
