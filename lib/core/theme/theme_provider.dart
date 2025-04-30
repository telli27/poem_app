import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ThemeMode için provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

// ThemeMode değişikliklerini yöneten notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  // Default olarak karanlık mod
  ThemeModeNotifier() : super(ThemeMode.dark) {
    // Başlangıçta kaydedilen ayarı yükle
    _loadSavedThemeMode();
  }

  // Tema modunu değiştir
  void toggleThemeMode() {
    final newThemeMode =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newThemeMode;
    _saveThemeMode(newThemeMode);
  }

  // Tema modunu ayarla
  void setThemeMode(ThemeMode themeMode) {
    state = themeMode;
    _saveThemeMode(themeMode);
  }

  // Karanlık mod mu kontrol et
  bool isDarkMode() {
    return state == ThemeMode.dark;
  }

  // Kayıtlı tema ayarını yükle
  Future<void> _loadSavedThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString('themeMode');

      if (savedThemeMode != null) {
        if (savedThemeMode == 'light') {
          state = ThemeMode.light;
        } else {
          state = ThemeMode.dark;
        }
      }
    } catch (e) {
      // Hata durumunda varsayılan temayı kullan
      state = ThemeMode.dark;
    }
  }

  // Tema ayarını kaydet
  Future<void> _saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'themeMode', mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      // Hata durumunda gizlice başarısız ol
    }
  }
}

// Kolay tema renkleri erişimi için
extension ThemeDataExtension on ThemeData {
  Color get primaryBackground =>
      brightness == Brightness.dark ? const Color(0xFF1E1E2C) : Colors.white;

  Color get secondaryBackground => brightness == Brightness.dark
      ? const Color(0xFF2D2D3F)
      : const Color(0xFFF8F9FA);

  Color get accentColor => const Color(0xFFE57373);

  Color get primaryTextColor =>
      brightness == Brightness.dark ? Colors.white : Colors.black87;

  Color get secondaryTextColor => brightness == Brightness.dark
      ? Colors.white.withOpacity(0.7)
      : Colors.black54;

  // Açık tema için uygun kart rengi
  Color get cardBackgroundColor =>
      brightness == Brightness.dark ? const Color(0xFF2D2D3F) : Colors.white;

  // Açık tema için uygun gölge rengi
  Color get shadowColor => brightness == Brightness.dark
      ? Colors.black.withOpacity(0.3)
      : Colors.black.withOpacity(0.08);

  // Açık tema için uygun çip arkaplan rengi
  Color get chipBackgroundColor => brightness == Brightness.dark
      ? const Color(0xFF3F51B5).withOpacity(0.3)
      : const Color(0xFF4A5BCC).withOpacity(0.1);

  // Açık tema için uygun buton rengi
  Color get buttonColor => brightness == Brightness.dark
      ? const Color(0xFFE57373)
      : const Color(0xFF4A5BCC);
}
