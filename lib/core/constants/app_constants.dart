import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(24));
  static const full = BorderRadius.all(Radius.circular(999));
}

class AppTextStyles {
  static TextStyle countdown(Color color) => TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 2,
      );

  static TextStyle prayerTime(Color color) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle prayerName(Color color) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle arabicVerse(Color color) => TextStyle(
        fontFamily: 'Hafs',
        fontSize: 26,
        color: color,
        height: 2.0,
      );

  static TextStyle urduTranslation(Color color) => TextStyle(
        fontFamily: 'NotoNastaliq',
        fontSize: 16,
        color: color,
        height: 1.8,
      );

  static TextStyle englishTranslation(Color color) => TextStyle(
        fontSize: 14,
        color: color,
        height: 1.6,
      );
}

class AppConstants {
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;
  static const int interstitialCooldownMinutes = 10;
  static const int widgetUpdateIntervalSeconds = 60;
  static const int tasbihDefaultGoal = 100;
  static const String supportEmail = 'support@prayerapp.com';
  static const String privacyPolicyUrl = 'https://yoursite.com/privacy';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.prayerapp.muslim';
}
