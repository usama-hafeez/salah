import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  AppThemeData _current = AppThemes.midnight;

  AppThemeData get current => _current;

  void load() {
    _current = AppThemes.getById(StorageService.theme);
    notifyListeners();
  }

  Future<void> setTheme(AppThemeData theme) async {
    _current = theme;
    await StorageService.setTheme(theme.id);
    notifyListeners();
  }

  ThemeData get materialTheme => ThemeData(
        scaffoldBackgroundColor: _current.background,
        colorScheme: ColorScheme.dark(
          primary: _current.primary,
          onPrimary: _current.onPrimary,
          secondary: _current.accent,
          onSecondary: _current.onPrimary,
          surface: _current.surface,
          onSurface: _current.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: _current.primary,
          foregroundColor: _current.onPrimary,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: _current.surface,
          selectedItemColor: _current.accent,
          unselectedItemColor: _current.textSecondary,
        ),
      );
}
