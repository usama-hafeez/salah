import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    assert(_prefs != null, 'StorageService.init() must be called first');
    return _prefs!;
  }

  // Calculation method: 'Karachi', 'ISNA', 'MWL', 'Egypt', 'Tehran', 'Gulf'
  static String get calculationMethod =>
      prefs.getString('calculation_method') ?? 'Karachi';
  static Future<void> setCalculationMethod(String v) =>
      prefs.setString('calculation_method', v);

  // Madhab: 'Hanafi', 'Shafi'
  static String get madhab => prefs.getString('madhab') ?? 'Hanafi';
  static Future<void> setMadhab(String v) => prefs.setString('madhab', v);

  // Language: 'en', 'ur', 'ar'
  static String get language => prefs.getString('language') ?? 'en';
  static Future<void> setLanguage(String v) => prefs.setString('language', v);

  // Theme: 'midnight', 'parchment', 'emerald', 'violet', 'golden', 'maroon', 'sky', 'pure_black'
  static String get theme => prefs.getString('theme') ?? 'midnight';
  static Future<void> setTheme(String v) => prefs.setString('theme', v);

  // Pro status — all features unlocked for everyone
  static bool get isPro => true;
  static Future<void> setIsPro(bool v) async {}

  // Notification toggles per prayer (all enabled by default)
  static bool notificationEnabled(String prayer) =>
      prefs.getBool('notif_$prayer') ?? true;
  static Future<void> setNotificationEnabled(String prayer, bool v) =>
      prefs.setBool('notif_$prayer', v);

  // Pre-prayer reminder (10 min before) — enabled by default
  static bool get prePrayerReminder =>
      prefs.getBool('pre_prayer_reminder') ?? true;
  static Future<void> setPrePrayerReminder(bool v) =>
      prefs.setBool('pre_prayer_reminder', v);

  // Jumu'a (Friday) reminder — enabled by default
  static bool get jumuaReminder => prefs.getBool('jumua_reminder') ?? true;
  static Future<void> setJumuaReminder(bool v) =>
      prefs.setBool('jumua_reminder', v);

  // Daily verse notification (8 AM) — disabled by default
  static bool get dailyVerseNotification =>
      prefs.getBool('daily_verse_notif') ?? false;
  static Future<void> setDailyVerseNotification(bool v) =>
      prefs.setBool('daily_verse_notif', v);

  // Islamic event notifications — enabled by default
  static bool get islamicEventNotification =>
      prefs.getBool('islamic_event_notif') ?? true;
  static Future<void> setIslamicEventNotification(bool v) =>
      prefs.setBool('islamic_event_notif', v);

  // Azaan sound: 'mecca', 'egypt', 'pakistan', 'turkey', 'short'
  static String get azaanSound =>
      prefs.getString('azaan_sound') ?? 'mecca';
  static Future<void> setAzaanSound(String v) =>
      prefs.setString('azaan_sound', v);

  // Onboarding complete
  static bool get onboardingDone =>
      prefs.getBool('onboarding_done') ?? false;
  static Future<void> setOnboardingDone() =>
      prefs.setBool('onboarding_done', true);

  // Last known latitude/longitude (for offline fallback — defaults to Lahore)
  static double get lastLat => prefs.getDouble('last_lat') ?? 31.5204;
  static double get lastLng => prefs.getDouble('last_lng') ?? 74.3587;
  static Future<void> setLastLocation(double lat, double lng) async {
    await prefs.setDouble('last_lat', lat);
    await prefs.setDouble('last_lng', lng);
  }
}
