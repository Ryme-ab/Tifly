import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents the theme mode preference
enum AppThemeMode {
  light,
  dark,
  system,
}

/// State for theme management
class ThemeState extends Equatable {
  final AppThemeMode mode;

  const ThemeState({
    this.mode = AppThemeMode.system,
  });

  /// Get the actual ThemeMode for MaterialApp based on current mode
  ThemeMode get themeMode {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Helper to check if dark theme is active
  /// This is useful for conditional UI logic
  bool isDark(Brightness systemBrightness) {
    switch (mode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return systemBrightness == Brightness.dark;
    }
  }

  ThemeState copyWith({
    AppThemeMode? mode,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
    );
  }

  @override
  List<Object> get props => [mode];
}
