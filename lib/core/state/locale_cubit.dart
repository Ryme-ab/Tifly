import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'selected_locale';

  LocaleCubit() : super(const Locale('en')) {
    loadSavedLocale();
  }

  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        emit(Locale(localeCode));
      }
    } catch (e) {
      // Default to English if error
      emit(const Locale('en'));
    }
  }

  Future<void> changeLocale(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
      emit(Locale(languageCode));
    } catch (e) {
      // Handle error silently, keep current locale
    }
  }
}
