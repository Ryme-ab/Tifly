import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/theme/data/theme_repository.dart';
import 'package:tifli/features/theme/presentation/cubit/theme_state.dart';

/// Cubit for managing app theme state.
/// 
/// Responsibilities:
/// - Load saved theme preference on initialization
/// - Toggle between light/dark modes
/// - Set specific theme mode (light, dark, system)
/// - Persist theme changes via repository
class ThemeCubit extends Cubit<ThemeState> {
  final ThemeRepository _repository;

  ThemeCubit({ThemeRepository? repository})
      : _repository = repository ?? ThemeRepository(),
        super(const ThemeState());

  /// Load saved theme preference from storage.
  /// Call this during app initialization.
  Future<void> loadSavedTheme() async {
    final savedMode = await _repository.getThemeMode();
    
    if (savedMode != null) {
      final mode = _stringToThemeMode(savedMode);
      emit(state.copyWith(mode: mode));
    }
    // If null, keeps default (system)
  }

  /// Toggle between light and dark themes.
  /// If currently on system mode, switches to dark.
  /// If on light, switches to dark.
  /// If on dark, switches to light.
  Future<void> toggleTheme() async {
    AppThemeMode newMode;
    
    switch (state.mode) {
      case AppThemeMode.light:
        newMode = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        newMode = AppThemeMode.light;
        break;
      case AppThemeMode.system:
        newMode = AppThemeMode.dark;
        break;
    }
    
    await setTheme(newMode);
  }

  /// Set specific theme mode.
  /// 
  /// [mode] - The theme mode to apply
  Future<void> setTheme(AppThemeMode mode) async {
    emit(state.copyWith(mode: mode));
    await _repository.saveThemeMode(_themeModeToString(mode));
  }

  /// Convert string to AppThemeMode
  AppThemeMode _stringToThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.system;
    }
  }

  /// Convert AppThemeMode to string for storage
  String _themeModeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }
}
