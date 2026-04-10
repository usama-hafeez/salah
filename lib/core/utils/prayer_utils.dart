import 'package:flutter/material.dart';

class PrayerUtils {
  /// Returns a Material icon for each prayer name.
  static IconData iconFor(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':    return Icons.nights_stay_outlined;
      case 'sunrise': return Icons.wb_sunny_outlined;
      case 'dhuhr':   return Icons.wb_sunny_outlined;
      case 'asr':     return Icons.wb_cloudy_outlined;
      case 'maghrib': return Icons.wb_twilight_outlined;
      case 'isha':    return Icons.nightlight_outlined;
      default:        return Icons.access_time;
    }
  }

  /// Short description shown as a subtitle under each prayer name.
  static String descriptionFor(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':    return 'Dawn prayer';
      case 'dhuhr':   return 'Midday prayer';
      case 'asr':     return 'Afternoon prayer';
      case 'maghrib': return 'Sunset prayer';
      case 'isha':    return 'Night prayer';
      default:        return '';
    }
  }

  /// Returns true if [now] is within [windowMinutes] minutes of [prayerTime].
  /// Used to suppress interstitial ads near prayer times (Business Rule §12.3).
  static bool isNearPrayerTime(
    DateTime prayerTime,
    DateTime now, {
    int windowMinutes = 5,
  }) {
    final diff = prayerTime.difference(now).abs();
    return diff.inMinutes <= windowMinutes;
  }

  /// Ordered list of the five obligatory prayer names.
  static const obligatoryNames = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];
}
