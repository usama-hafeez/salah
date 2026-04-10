import 'package:flutter/material.dart';

class AppThemeData {
  final String id;
  final String name;
  final bool isPro;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.isPro,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
  });
}

class AppThemes {
  static const midnight = AppThemeData(
    id: 'midnight', name: 'Midnight', isPro: false,
    primary: Color(0xFF0F4C3A), secondary: Color(0xFF1A6B52),
    accent: Color(0xFFC9A84C), background: Color(0xFF121212),
    surface: Color(0xFF1E2D2A), textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9E9E9E),
  );

  static const parchment = AppThemeData(
    id: 'parchment', name: 'Parchment', isPro: false,
    primary: Color(0xFF5C3D11), secondary: Color(0xFF8B6914),
    accent: Color(0xFFC9A84C), background: Color(0xFFF5F0E8),
    surface: Color(0xFFEDE4D3), textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF6B5B3E),
  );

  static const emerald = AppThemeData(
    id: 'emerald', name: 'Emerald', isPro: true,
    primary: Color(0xFF0F3D2A), secondary: Color(0xFF1A6B52),
    accent: Color(0xFFE8C96A), background: Color(0xFF071A12),
    surface: Color(0xFF0F3022), textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9ECFBA),
  );

  static const violetNight = AppThemeData(
    id: 'violet', name: 'Violet Night', isPro: true,
    primary: Color(0xFF2C1654), secondary: Color(0xFF4A2980),
    accent: Color(0xFFD4B8F0), background: Color(0xFF130B25),
    surface: Color(0xFF1E1040), textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB8A0D0),
  );

  static const golden = AppThemeData(
    id: 'golden', name: 'Golden', isPro: true,
    primary: Color(0xFF8B6914), secondary: Color(0xFFC9A84C),
    accent: Color(0xFFC9A84C), background: Color(0xFFFFF8E8),
    surface: Color(0xFFFFFFFF), textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF8B6914),
  );

  static const maroon = AppThemeData(
    id: 'maroon', name: 'Maroon', isPro: true,
    primary: Color(0xFF4A1020), secondary: Color(0xFF8B1A1A),
    accent: Color(0xFFF5D5C0), background: Color(0xFF1A0510),
    surface: Color(0xFF2A0A18), textPrimary: Color(0xFFF5D5C0),
    textSecondary: Color(0xFFBB8888),
  );

  static const sky = AppThemeData(
    id: 'sky', name: 'Sky', isPro: true,
    primary: Color(0xFF1A5276), secondary: Color(0xFF2E86C1),
    accent: Color(0xFF1A5276), background: Color(0xFFE8F4F8),
    surface: Color(0xFFFFFFFF), textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF5D8AA8),
  );

  static const pureBlack = AppThemeData(
    id: 'pure_black', name: 'Pure Black', isPro: true,
    primary: Color(0xFF0F4C3A), secondary: Color(0xFF1A6B52),
    accent: Color(0xFFC9A84C), background: Color(0xFF000000),
    surface: Color(0xFF111111), textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF888888),
  );

  static const all = [
    midnight, parchment, emerald, violetNight,
    golden, maroon, sky, pureBlack,
  ];

  static AppThemeData getById(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => midnight);
}
