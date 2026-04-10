# Prayer Time + Quran Widget — Flutter App
## CLAUDE.md — Full Implementation Plan

> **Instructions for Claude Code:**
> This file is your complete source of truth for building this Flutter Android app.
> Read this entire file before writing a single line of code.
> Work section by section, in order. After completing each section, confirm completion before moving to the next.
> Never skip ahead. Never assume — if something is unclear, ask before proceeding.
> All code must be production-ready, not placeholder/demo code.

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Tech Stack & Dependencies](#2-tech-stack--dependencies)
3. [Folder Structure](#3-folder-structure)
4. [Implementation Order](#4-implementation-order)
5. [Phase 1 — Project Setup](#5-phase-1--project-setup)
6. [Phase 2 — Core Services](#6-phase-2--core-services)
7. [Phase 3 — Home Screen & Prayer Times](#7-phase-3--home-screen--prayer-times)
8. [Phase 4 — Notifications & Widget](#8-phase-4--notifications--widget)
9. [Phase 5 — Quran Reader](#9-phase-5--quran-reader)
10. [Phase 6 — Remaining Screens](#10-phase-6--remaining-screens)
11. [Phase 7 — Theming System](#11-phase-7--theming-system)
12. [Phase 8 — AdMob Integration](#12-phase-8--admob-integration)
13. [Phase 9 — In-App Purchases](#13-phase-9--in-app-purchases)
14. [Phase 10 — Settings & Localization](#14-phase-10--settings--localization)
15. [Design Tokens](#15-design-tokens)
16. [Data Models](#16-data-models)
17. [Key Business Rules](#17-key-business-rules)
18. [Testing Checklist](#18-testing-checklist)

---

## 1. Project Overview

**App Name:** Prayer Times & Quran Widget
**Package ID:** `com.prayerapp.muslim`
**Platform:** Android first (iOS later)
**Language:** Dart / Flutter
**Min SDK:** 21 (Android 5.0+)
**Target SDK:** 34

### What this app does
A lightweight Islamic prayer time app that:
- Shows accurate prayer times based on GPS location
- Provides a home screen widget showing the next prayer + countdown
- Sends Azaan notification alerts at each prayer time
- Includes a full Quran reader (Arabic + Urdu + English)
- Shows a Hijri calendar with Islamic events
- Has a Qibla compass, Tasbih counter, and Qaza tracker
- Monetizes via AdMob ads (free users) and in-app purchase (Pro upgrade)

### Revenue model
- **Free tier:** AdMob banner + interstitial ads
- **Pro — one-time $1.99:** All premium themes (6 themes)
- **Pro — one-time $0.99:** Remove ads forever
- **Pro — annual $0.99/yr:** Full Pro (themes + no ads + all features)

---

## 2. Tech Stack & Dependencies

### pubspec.yaml — complete dependencies

```yaml
name: prayer_app
description: Prayer Times & Quran Widget
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Prayer time calculation (fully offline, no API needed)
  adhan: ^2.0.4

  # GPS location for prayer times
  geolocator: ^11.0.0
  permission_handler: ^11.3.1

  # Home screen widget (Android + iOS)
  home_widget: ^0.7.0

  # Azaan notifications
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.4

  # Quran SQLite database
  sqflite: ^2.3.3
  path_provider: ^2.1.3
  path: ^1.9.0

  # AdMob
  google_mobile_ads: ^5.1.0

  # In-app purchase
  in_app_purchase: ^3.1.13

  # Persistent settings
  shared_preferences: ^2.3.2

  # Qibla compass
  flutter_compass: ^0.7.0

  # Audio (Azaan)
  just_audio: ^0.9.39

  # Haptic feedback (Tasbih)
  vibration: ^1.9.0

  # SVG icons
  flutter_svg: ^2.0.10+1

  # State management
  provider: ^6.1.2

  # Hijri calendar
  hijri: ^2.0.1

  # HTTP (for future features)
  http: ^1.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true

  assets:
    - assets/audio/
    - assets/fonts/
    - assets/images/
    - assets/db/
    - assets/icons/

  fonts:
    - family: Hafs
      fonts:
        - asset: assets/fonts/Hafs.ttf
    - family: NotoNastaliq
      fonts:
        - asset: assets/fonts/NotoNastaliqUrdu.ttf
```

---

## 3. Folder Structure

> **Instruction for Claude:** Create ALL of these files when setting up the project. Empty files with just a comment `// TODO` are acceptable at setup stage — they will be filled in later phases.

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # All theme color definitions
│   │   ├── app_strings.dart         # All UI strings (EN + UR + AR)
│   │   ├── app_assets.dart          # Asset path constants
│   │   └── app_constants.dart       # App-wide magic numbers/values
│   │
│   ├── services/
│   │   ├── prayer_service.dart      # Wraps adhan, returns PrayerTimes
│   │   ├── quran_service.dart       # SQLite Quran database access
│   │   ├── notification_service.dart # Schedule all Azaan notifications
│   │   ├── location_service.dart    # GPS permission + coordinates
│   │   ├── storage_service.dart     # SharedPreferences wrapper
│   │   ├── ad_service.dart          # AdMob banner + interstitial
│   │   ├── purchase_service.dart    # In-app purchase + Pro status
│   │   └── widget_service.dart      # Home screen widget data update
│   │
│   └── utils/
│       ├── date_utils.dart          # Hijri/Gregorian helpers
│       ├── prayer_utils.dart        # Calculation method helpers
│       └── extensions.dart          # Dart extension methods
│
├── models/
│   ├── prayer_model.dart
│   ├── verse_model.dart
│   ├── surah_model.dart
│   ├── user_settings_model.dart
│   └── prayer_status.dart           # Enum: passed, next, upcoming
│
├── providers/
│   ├── prayer_provider.dart         # Prayer times state
│   ├── quran_provider.dart          # Quran reading state
│   ├── settings_provider.dart       # User settings state
│   ├── theme_provider.dart          # Active theme state
│   └── purchase_provider.dart       # Pro status state
│
├── features/
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   └── method_picker_screen.dart
│   │
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── next_prayer_card.dart
│   │       ├── prayer_list_tile.dart
│   │       ├── date_header_widget.dart
│   │       └── moon_phase_widget.dart
│   │
│   ├── calendar/
│   │   ├── hijri_calendar_screen.dart
│   │   └── widgets/
│   │       └── islamic_event_badge.dart
│   │
│   ├── quran/
│   │   ├── quran_home_screen.dart   # Surah list
│   │   ├── surah_reader_screen.dart # Ayah-by-ayah reader
│   │   ├── verse_of_day_screen.dart
│   │   └── quran_bookmarks_screen.dart
│   │
│   ├── qibla/
│   │   └── qibla_screen.dart
│   │
│   ├── tasbih/
│   │   └── tasbih_screen.dart
│   │
│   ├── qaza/
│   │   └── qaza_tracker_screen.dart
│   │
│   ├── ramadan/
│   │   ├── ramadan_screen.dart
│   │   └── fasting_tracker_screen.dart
│   │
│   ├── settings/
│   │   ├── settings_screen.dart
│   │   ├── notification_settings_screen.dart
│   │   └── theme_picker_screen.dart
│   │
│   └── premium/
│       └── paywall_screen.dart
│
└── shared/
    ├── bottom_nav_bar.dart
    ├── app_bar_widget.dart
    ├── ad_banner_widget.dart
    ├── premium_lock_widget.dart     # Lock icon overlay for Pro features
    └── loading_widget.dart

android/
  app/src/main/
    AndroidManifest.xml              # AdMob App ID + permissions
    res/xml/
      home_widget_info.xml           # Widget configuration

assets/
  audio/
    azaan_mecca.mp3
    azaan_egypt.mp3
    azaan_pakistan.mp3
    azaan_turkey.mp3
    azaan_short.mp3                  # Short tone (30 seconds)
  fonts/
    Hafs.ttf                         # Arabic Quran font
    NotoNastaliqUrdu.ttf             # Urdu font
  images/
    logo.png
    kaaba.svg
    compass_needle.svg
  db/
    quran.db                         # Pre-built SQLite Quran database
  icons/
    fajr.svg
    dhuhr.svg
    asr.svg
    maghrib.svg
    isha.svg
```

---

## 4. Implementation Order

> **Instruction for Claude:** Always follow this order. Do not implement Phase N+1 until Phase N is complete and confirmed working.

```
Phase 1  →  Project scaffolding, folder structure, pubspec.yaml
Phase 2  →  Core services (prayer, location, storage, notification)
Phase 3  →  Home screen with live prayer times
Phase 4  →  Azaan notifications + home screen widget
Phase 5  →  Quran reader (SQLite database + UI)
Phase 6  →  Remaining screens (Qibla, Tasbih, Calendar, Ramadan, Qaza)
Phase 7  →  8-theme system + theme picker
Phase 8  →  AdMob integration
Phase 9  →  In-app purchase (Pro unlock)
Phase 10 →  Settings, localization (Urdu/English), final polish
```

---

## 5. Phase 1 — Project Setup

### 5.1 Create Flutter project
```bash
flutter create --org com.prayerapp --project-name prayer_app prayer_app
cd prayer_app
```

### 5.2 Replace pubspec.yaml
Replace the entire `pubspec.yaml` with the content from Section 2 above.

### 5.3 Android permissions
Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

Add inside `<application>` tag:
```xml
<!-- AdMob App ID — REPLACE with real ID before release -->
<meta-data
  android:name="com.google.android.gms.ads.APPLICATION_ID"
  android:value="ca-app-pub-3940256099942544~3347511713"/>

<!-- Required for exact alarm scheduling (Azaan notifications) -->
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
  android:exported="true">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
  </intent-filter>
</receiver>
```

### 5.4 Set minimum SDK
In `android/app/build.gradle`:
```gradle
defaultConfig {
    minSdkVersion 21
    targetSdkVersion 34
}
```

### 5.5 Create all empty files
Create every file listed in Section 3 with a comment `// TODO: implement` so imports don't break.

### 5.6 Install dependencies
```bash
flutter pub get
```

**Phase 1 complete when:** `flutter run` launches a blank app without errors.

---

## 6. Phase 2 — Core Services

Implement all 8 services in `lib/core/services/`. Each must be fully working before Phase 3 starts.

---

### 6.1 storage_service.dart

```dart
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

  // Pro status
  static bool get isPro => prefs.getBool('is_pro') ?? false;
  static Future<void> setIsPro(bool v) => prefs.setBool('is_pro', v);

  // Notification toggles per prayer (all enabled by default)
  static bool notificationEnabled(String prayer) =>
      prefs.getBool('notif_$prayer') ?? true;
  static Future<void> setNotificationEnabled(String prayer, bool v) =>
      prefs.setBool('notif_$prayer', v);

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

  // Last known latitude/longitude (for offline use)
  static double get lastLat => prefs.getDouble('last_lat') ?? 31.5204;
  static double get lastLng => prefs.getDouble('last_lng') ?? 74.3587;
  static Future<void> setLastLocation(double lat, double lng) async {
    await prefs.setDouble('last_lat', lat);
    await prefs.setDouble('last_lng', lng);
  }
}
```

---

### 6.2 location_service.dart

```dart
import 'package:geolocator/geolocator.dart';
import 'storage_service.dart';

class LocationService {
  /// Returns current GPS position.
  /// Falls back to last saved location if permission denied.
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _fallback();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _fallback();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return _fallback();
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      // Save for offline fallback
      await StorageService.setLastLocation(pos.latitude, pos.longitude);
      return pos;
    } catch (_) {
      return _fallback();
    }
  }

  static Position _fallback() {
    return Position(
      latitude: StorageService.lastLat,
      longitude: StorageService.lastLng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}
```

---

### 6.3 prayer_service.dart

```dart
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

class PrayerService {
  /// Calculate today's prayer times based on position and saved settings.
  static PrayerTimes getPrayerTimes(Position position) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = _getCalculationParameters();
    final dateComponents = DateComponents.from(DateTime.now());
    return PrayerTimes(coordinates, dateComponents, params);
  }

  /// Get prayer times for a specific date.
  static PrayerTimes getPrayerTimesForDate(Position position, DateTime date) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = _getCalculationParameters();
    final dateComponents = DateComponents.from(date);
    return PrayerTimes(coordinates, dateComponents, params);
  }

  static CalculationParameters _getCalculationParameters() {
    CalculationParameters params;
    switch (StorageService.calculationMethod) {
      case 'ISNA':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'MWL':
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'Egypt':
        params = CalculationMethod.egyptian.getParameters();
        break;
      case 'Tehran':
        params = CalculationMethod.tehran.getParameters();
        break;
      case 'Gulf':
        params = CalculationMethod.kuwait.getParameters();
        break;
      case 'Karachi':
      default:
        params = CalculationMethod.karachi.getParameters();
        break;
    }

    // Madhab affects Asr time
    if (StorageService.madhab == 'Hanafi') {
      params.madhab = Madhab.hanafi;
    } else {
      params.madhab = Madhab.shafi;
    }

    return params;
  }

  /// Returns the name of the currently active or next prayer.
  static Prayer currentPrayer(PrayerTimes times) {
    return times.currentPrayer();
  }

  /// Returns DateTime for a specific prayer.
  static DateTime? timeForPrayer(PrayerTimes times, Prayer prayer) {
    return times.timeForPrayer(prayer);
  }

  /// Returns map of prayer name → DateTime for display.
  static Map<String, DateTime?> allPrayerTimes(PrayerTimes times) {
    return {
      'Fajr': times.fajr,
      'Sunrise': times.sunrise,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };
  }

  /// The 5 obligatory prayers only (excludes Sunrise).
  static Map<String, DateTime?> obligatoryPrayers(PrayerTimes times) {
    return {
      'Fajr': times.fajr,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };
  }
}
```

---

### 6.4 notification_service.dart

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:adhan/adhan.dart';
import 'prayer_service.dart';
import 'location_service.dart';
import 'storage_service.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
  }

  /// Schedule Azaan notifications for today and tomorrow.
  /// Call this on app start and when settings change.
  static Future<void> scheduleAllNotifications() async {
    await _plugin.cancelAll();

    final position = await LocationService.getCurrentPosition();
    final prayers = PrayerService.getPrayerTimes(position);
    final tomorrowPrayers = PrayerService.getPrayerTimesForDate(
      position,
      DateTime.now().add(const Duration(days: 1)),
    );

    final allDays = [prayers, tomorrowPrayers];
    int notifId = 0;

    for (final day in allDays) {
      final times = PrayerService.obligatoryPrayers(day);
      for (final entry in times.entries) {
        final prayerName = entry.key;
        final prayerTime = entry.value;

        if (prayerTime == null) continue;
        if (prayerTime.isBefore(DateTime.now())) continue;
        if (!StorageService.notificationEnabled(prayerName)) continue;

        await _scheduleAzaan(
          id: notifId++,
          prayerName: prayerName,
          scheduledTime: prayerTime,
        );
      }
    }
  }

  static Future<void> _scheduleAzaan({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
  }) async {
    final soundFile = _getSoundFile();

    final androidDetails = AndroidNotificationDetails(
      'azaan_channel',
      'Prayer Time',
      channelDescription: 'Azaan notification at prayer time',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(soundFile),
      playSound: true,
      enableVibration: true,
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      prayerName,
      'Time for $prayerName prayer',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static String _getSoundFile() {
    switch (StorageService.azaanSound) {
      case 'egypt':
        return 'azaan_egypt';
      case 'pakistan':
        return 'azaan_pakistan';
      case 'turkey':
        return 'azaan_turkey';
      case 'short':
        return 'azaan_short';
      case 'mecca':
      default:
        return 'azaan_mecca';
    }
  }

  static Future<void> cancelAll() => _plugin.cancelAll();
}
```

---

### 6.5 quran_service.dart

```dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/surah_model.dart';
import '../../models/verse_model.dart';

class QuranService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'quran.db');

    final exists = await File(path).exists();
    if (!exists) {
      // Copy bundled DB from assets to writable location on first run
      final data = await rootBundle.load('assets/db/quran.db');
      final bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(path, readOnly: true);
  }

  static Future<List<SurahModel>> getAllSurahs() async {
    final db = await database;
    final result = await db.query('surahs', orderBy: 'id ASC');
    return result.map((r) => SurahModel.fromMap(r)).toList();
  }

  static Future<List<VerseModel>> getAyahs(int surahId) async {
    final db = await database;
    final result = await db.query(
      'ayahs',
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'ayah_number ASC',
    );
    return result.map((r) => VerseModel.fromMap(r)).toList();
  }

  static Future<VerseModel> getVerseOfDay() async {
    final db = await database;
    final dayOfYear = DateTime.now().difference(
          DateTime(DateTime.now().year, 1, 1),
        ).inDays +
        1;
    final result = await db.query(
      'daily_verses',
      where: 'day_of_year = ?',
      whereArgs: [dayOfYear],
    );
    if (result.isEmpty) {
      // Fallback to Al-Fatiha ayah 1
      final fallback = await db.query('ayahs', where: 'id = 1');
      return VerseModel.fromMap(fallback.first);
    }
    final ref = result.first;
    final ayah = await db.query(
      'ayahs',
      where: 'surah_id = ? AND ayah_number = ?',
      whereArgs: [ref['surah_id'], ref['ayah_number']],
    );
    return VerseModel.fromMap(ayah.first);
  }

  // Bookmarks (stored in a separate local DB or same DB with a bookmarks table)
  static Future<void> addBookmark(int surahId, int ayahNumber) async {
    final db = await openDatabase(
      join((await getApplicationDocumentsDirectory()).path, 'user_data.db'),
      version: 1,
      onCreate: (db, v) => db.execute(
        'CREATE TABLE bookmarks (id INTEGER PRIMARY KEY AUTOINCREMENT, surah_id INTEGER, ayah_number INTEGER, created_at TEXT)',
      ),
    );
    await db.insert('bookmarks', {
      'surah_id': surahId,
      'ayah_number': ayahNumber,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
```

---

### 6.6 ad_service.dart

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'storage_service.dart';

class AdService {
  // TEST IDs — replace with real IDs before Play Store submission
  static const _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // REAL IDs (comment out test IDs above and uncomment these for release)
  // static const _bannerAdUnitId = 'YOUR_REAL_BANNER_ID';
  // static const _interstitialAdUnitId = 'YOUR_REAL_INTERSTITIAL_ID';

  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static bool _bannerLoaded = false;
  static int _interstitialShowCount = 0;

  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  /// Load banner ad. Call once per screen that shows a banner.
  static Future<BannerAd?> loadBanner() async {
    if (StorageService.isPro) return null; // Pro users = no ads

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _bannerLoaded = true,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );

    await _bannerAd!.load();
    return _bannerAd;
  }

  /// Pre-load interstitial. Call this early so it's ready when needed.
  static Future<void> preloadInterstitial() async {
    if (StorageService.isPro) return;

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  /// Show interstitial. Max once per 10 minutes (don't spam the user).
  static void showInterstitial() {
    if (StorageService.isPro) return;
    if (_interstitialAd == null) return;

    _interstitialAd!.show();
    _interstitialAd = null;
    preloadInterstitial(); // Pre-load next one
  }

  static bool get isBannerLoaded => _bannerLoaded && _bannerAd != null;
  static BannerAd? get bannerAd => _bannerAd;
}
```

---

### 6.7 purchase_service.dart

```dart
import 'package:in_app_purchase/in_app_purchase.dart';
import 'storage_service.dart';

class PurchaseService {
  // Product IDs — must match exactly what you create in Play Console
  static const proThemesId = 'pro_themes_lifetime';
  static const removeAdsId = 'remove_ads_lifetime';
  static const proAnnualId = 'pro_annual';
  static const proMonthlyId = 'pro_monthly';

  static final _iap = InAppPurchase.instance;

  static Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    // Listen to purchase updates
    _iap.purchaseStream.listen(_handlePurchaseUpdates);

    // Restore previous purchases on startup
    await _iap.restorePurchases();
  }

  static void _handlePurchaseUpdates(
      List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await StorageService.setIsPro(true);
        await _iap.completePurchase(purchase);
      }
      if (purchase.status == PurchaseStatus.error) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  static Future<void> buyProThemes() =>
      _buyProduct(proThemesId);
  static Future<void> buyRemoveAds() =>
      _buyProduct(removeAdsId);
  static Future<void> buyProAnnual() =>
      _buyProduct(proAnnualId);

  static Future<void> _buyProduct(String productId) async {
    final response = await _iap.queryProductDetails({productId});
    if (response.productDetails.isEmpty) return;

    final purchaseParam = PurchaseParam(
      productDetails: response.productDetails.first,
    );
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  static Future<void> restorePurchases() =>
      _iap.restorePurchases();
}
```

---

### 6.8 widget_service.dart

```dart
import 'package:home_widget/home_widget.dart';
import 'package:adhan/adhan.dart';
import 'prayer_service.dart';
import 'location_service.dart';

class WidgetService {
  static const _appGroupId = 'group.com.prayerapp.muslim';
  static const _iOSWidgetName = 'PrayerWidget';
  static const _androidWidgetName = 'PrayerWidgetProvider';

  static Future<void> updateWidget() async {
    try {
      final position = await LocationService.getCurrentPosition();
      final times = PrayerService.getPrayerTimes(position);
      final next = times.nextPrayer();
      final nextTime = times.timeForPrayer(next);

      if (nextTime == null) return;

      final countdown = nextTime.difference(DateTime.now());
      final hours = countdown.inHours;
      final minutes = countdown.inMinutes % 60;

      await HomeWidget.saveWidgetData('next_prayer', _prayerName(next));
      await HomeWidget.saveWidgetData(
          'countdown', '${hours}h ${minutes}m');
      await HomeWidget.saveWidgetData(
          'prayer_time', _formatTime(nextTime));

      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );
    } catch (_) {
      // Widget update is non-critical — fail silently
    }
  }

  static String _prayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return 'Fajr';
      case Prayer.dhuhr: return 'Dhuhr';
      case Prayer.asr: return 'Asr';
      case Prayer.maghrib: return 'Maghrib';
      case Prayer.isha: return 'Isha';
      default: return 'Prayer';
    }
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}
```

**Phase 2 complete when:** All 8 service files compile without errors and basic unit test of `PrayerService.getPrayerTimes()` returns valid times.

---

## 7. Phase 3 — Home Screen & Prayer Times

### 7.1 prayer_provider.dart

```dart
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/prayer_service.dart';
import '../core/services/location_service.dart';
import '../core/services/widget_service.dart';

class PrayerProvider extends ChangeNotifier {
  PrayerTimes? _prayerTimes;
  Position? _position;
  bool _loading = true;
  String? _error;

  PrayerTimes? get prayerTimes => _prayerTimes;
  Position? get position => _position;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadPrayerTimes() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _position = await LocationService.getCurrentPosition();
      _prayerTimes = PrayerService.getPrayerTimes(_position!);
      await WidgetService.updateWidget();
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Prayer? get nextPrayer => _prayerTimes?.nextPrayer();
  Prayer? get currentPrayer => _prayerTimes?.currentPrayer();

  Duration? get timeToNextPrayer {
    if (_prayerTimes == null) return null;
    final next = _prayerTimes!.nextPrayer();
    final nextTime = _prayerTimes!.timeForPrayer(next);
    if (nextTime == null) return null;
    return nextTime.difference(DateTime.now());
  }
}
```

### 7.2 home_screen.dart structure

The Home screen must contain:
- `DateHeaderWidget` at top (Hijri date left, Gregorian date right)
- `NextPrayerCard` — shows next prayer name, time, and live countdown timer using `Timer.periodic`
- List of 5 prayer rows using `PrayerListTile`
- `AdBannerWidget` at bottom (only when not Pro)
- `BottomNavBar`

**NextPrayerCard countdown logic:**
```dart
// Update countdown every second
Timer.periodic(const Duration(seconds: 1), (_) {
  final remaining = provider.timeToNextPrayer;
  if (remaining != null) {
    setState(() {
      _countdownText =
        '${remaining.inHours.toString().padLeft(2, '0')}:'
        '${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:'
        '${(remaining.inSeconds % 60).toString().padLeft(2, '0')}';
    });
  }
});
```

**PrayerListTile visual states:**
- **Passed prayer:** Icon tinted green, time text grayed out, green checkmark on right
- **Next prayer:** Row highlighted with accent gold background, bold text
- **Upcoming prayer:** Normal state, icon color matches theme primary

**Phase 3 complete when:** App shows real prayer times based on GPS, countdown updates every second, correct prayer is highlighted.

---

## 8. Phase 4 — Notifications & Widget

### 8.1 Android widget setup

Create `android/app/src/main/res/xml/home_widget_info.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="110dp"
    android:minHeight="40dp"
    android:updatePeriodMillis="1800000"
    android:initialLayout="@layout/prayer_widget_layout"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen">
</appwidget-provider>
```

Create `android/app/src/main/res/layout/prayer_widget_layout.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#0F4C3A"
    android:orientation="vertical"
    android:padding="12dp">

  <TextView android:id="@+id/next_prayer_name"
      android:layout_width="wrap_content"
      android:layout_height="wrap_content"
      android:textColor="#FFFFFF"
      android:textSize="16sp"
      android:textStyle="bold"
      android:text="Asr"/>

  <TextView android:id="@+id/countdown"
      android:layout_width="wrap_content"
      android:layout_height="wrap_content"
      android:textColor="#C9A84C"
      android:textSize="22sp"
      android:textStyle="bold"
      android:text="01:32:44"/>

  <TextView android:id="@+id/prayer_time"
      android:layout_width="wrap_content"
      android:layout_height="wrap_content"
      android:textColor="#9E9E9E"
      android:textSize="12sp"
      android:text="4:12 PM"/>

</LinearLayout>
```

Register the widget provider in `AndroidManifest.xml`:
```xml
<receiver android:name="es.antonborri.home_widget.HomeWidgetProvider"
    android:exported="true">
  <intent-filter>
    <action android:name="android.appwidget.action.APPWIDGET_UPDATE"/>
  </intent-filter>
  <meta-data
      android:name="android.appwidget.provider"
      android:resource="@xml/home_widget_info"/>
</receiver>
```

**Phase 4 complete when:** Azaan notification fires at correct prayer time. Home screen widget shows next prayer and updates after app opens.

---

## 9. Phase 5 — Quran Reader

### 9.1 Quran database

Download the pre-built SQLite from:
- `https://github.com/meequraan/db` (or equivalent open-source Quran SQLite)

Place the `.db` file at `assets/db/quran.db`.

The DB must have these tables (if downloaded DB has different column names, adapt `QuranService` accordingly):
```sql
-- surahs table
CREATE TABLE surahs (
  id          INTEGER PRIMARY KEY,
  name_arabic TEXT NOT NULL,
  name_english TEXT NOT NULL,
  name_urdu   TEXT,
  revelation  TEXT,
  ayah_count  INTEGER NOT NULL
);

-- ayahs table
CREATE TABLE ayahs (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  surah_id     INTEGER NOT NULL,
  ayah_number  INTEGER NOT NULL,
  text_arabic  TEXT NOT NULL,
  text_english TEXT,
  text_urdu    TEXT,
  juz          INTEGER
);

-- daily_verses table (365 rows — one verse per day of year)
CREATE TABLE daily_verses (
  day_of_year INTEGER PRIMARY KEY,
  surah_id    INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL
);
```

### 9.2 Quran reader UI requirements

`surah_reader_screen.dart` must implement:
- Arabic text: right-aligned, RTL direction, Hafs font, 26sp
- Translation text below each verse: 14sp, left-aligned, `textSecondary` color
- Ayah number: accentGold circle, 12sp
- Basmala displayed above verse 1 of every surah (except Al-Fatiha and At-Tawbah)
- Long-press on any ayah → bottom sheet with options: Bookmark, Share, Copy
- Pro gate: Quran reader requires Pro if user has not unlocked. Show `PaywallScreen` if not Pro.

**Phase 5 complete when:** User can browse all 114 surahs, read any surah with Arabic + English, and bookmark verses.

---

## 10. Phase 6 — Remaining Screens

Implement these screens in order. Each must be visually complete and functional.

### 10.1 qibla_screen.dart
- Use `flutter_compass` stream to get compass heading
- Calculate Qibla angle from user's coordinates using formula:
  ```dart
  // Kaabah coordinates
  const kaabaLat = 21.4225;
  const kaabaLng = 39.8262;

  double getQiblaAngle(double userLat, double userLng) {
    final dLng = (kaabaLng - userLng) * (pi / 180);
    final lat1 = userLat * (pi / 180);
    final lat2 = kaabaLat * (pi / 180);
    final x = sin(dLng) * cos(lat2);
    final y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    return (atan2(x, y) * (180 / pi) + 360) % 360;
  }
  ```
- Rotate a compass needle SVG using `Transform.rotate` with the calculated angle minus compass bearing
- Show "Facing Qibla" text when angle error < 5 degrees
- **Pro gated feature**

### 10.2 tasbih_screen.dart
- Large circular counter (animated ring fills as count increases)
- Default Dhikr: SubhanAllah (33), Alhamdulillah (33), AllahuAkbar (34) = 100 total
- Haptic feedback on each tap using `Vibration.vibrate(duration: 30)`
- Reset button with confirmation dialog
- Daily count saved to `SharedPreferences`

### 10.3 hijri_calendar_screen.dart
- Use `hijri` package to convert each day of the month
- Mark Islamic events (defined as a static map of Hijri month+day → event name):
  ```dart
  static const islamicEvents = {
    '1-1': 'Islamic New Year',
    '1-10': 'Ashura',
    '3-12': 'Mawlid an-Nabi',
    '7-27': 'Isra and Mi\'raj',
    '8-15': 'Shab e Barat',
    '9-1': 'Ramadan Begins',
    '9-27': 'Laylat al-Qadr',
    '10-1': 'Eid al-Fitr',
    '12-10': 'Eid al-Adha',
  };
  ```
- Today highlighted in `accentGold`
- Event days show a green dot below the date number

### 10.4 ramadan_screen.dart
- Show Sehri and Iftar times (= Fajr and Maghrib times from `PrayerService`)
- Large countdown to next Sehri or Iftar
- 30-day timetable (scrollable list)
- Days remaining in Ramadan (calculate from Hijri date)

### 10.5 qaza_tracker_screen.dart
- List of 5 prayers with a counter for each (how many Qaza remaining)
- + and - buttons to adjust count
- Persist to `SharedPreferences` using key `qaza_{prayerName}`
- Total Qaza debt displayed prominently at top

**Phase 6 complete when:** All 5 screens above are accessible from the bottom nav or settings and work without crashes.

---

## 11. Phase 7 — Theming System

### 11.1 AppTheme class

Create `lib/core/constants/app_colors.dart` with all 8 themes:

```dart
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

  static AppThemeData getById(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => midnight);
  }
}
```

### 11.2 ThemeProvider

```dart
class ThemeProvider extends ChangeNotifier {
  AppThemeData _current = AppThemes.midnight;

  AppThemeData get current => _current;

  void load() {
    _current = AppThemes.getById(StorageService.theme);
    notifyListeners();
  }

  Future<void> setTheme(AppThemeData theme) async {
    if (theme.isPro && !StorageService.isPro) return; // Enforce Pro gate
    _current = theme;
    await StorageService.setTheme(theme.id);
    notifyListeners();
  }

  ThemeData get materialTheme => ThemeData(
    primaryColor: _current.primary,
    scaffoldBackgroundColor: _current.background,
    appBarTheme: AppBarTheme(
      backgroundColor: _current.primary,
      foregroundColor: _current.textPrimary,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _current.surface,
      selectedItemColor: _current.accent,
      unselectedItemColor: _current.textSecondary,
    ),
  );
}
```

**Phase 7 complete when:** Switching themes in `theme_picker_screen.dart` immediately changes the entire app's visual appearance. Pro themes show a lock icon for free users.

---

## 12. Phase 8 — AdMob Integration

### 12.1 Init in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await NotificationService.init();
  await AdService.init();        // <-- add this
  await PurchaseService.init();
  runApp(const PrayerApp());
}
```

### 12.2 ad_banner_widget.dart

```dart
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});
  @override State<AdBannerWidget> createState() => _State();
}

class _State extends State<AdBannerWidget> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    AdService.loadBanner().then((ad) {
      if (mounted) setState(() => _ad = ad);
    });
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ad == null) return const SizedBox.shrink();
    return SizedBox(
      height: _ad!.size.height.toDouble(),
      width: double.infinity,
      child: AdWidget(ad: _ad!),
    );
  }
}
```

### 12.3 Ad placement rules (MUST follow)

| Location | Ad type | Condition |
|---|---|---|
| Home screen bottom | Banner | Free users only |
| Hijri Calendar bottom | Banner | Free users only |
| Tasbih screen bottom | Banner | Free users only |
| Opening Qibla screen | Interstitial | Free users, max 1 per 10 min |
| After saving bookmark | Interstitial | Free users, max 1 per session |

**NEVER show ads on:** Quran reader, during active prayer countdown, Ramadan Sehri countdown, paywall screen.

**Phase 8 complete when:** Ads display on correct screens for free users. Pro users see zero ads.

---

## 13. Phase 9 — In-App Purchases

### 13.1 Create these products in Play Console

Before implementing, create these products at:
`Play Console → Your App → Monetize → Products`

| Product ID | Type | Price |
|---|---|---|
| `pro_themes_lifetime` | One-time (managed) | $1.99 |
| `remove_ads_lifetime` | One-time (managed) | $0.99 |
| `pro_annual` | Subscription | $0.99/year |
| `pro_monthly` | Subscription | $0.49/month |

### 13.2 paywall_screen.dart

Must include:
- Feature comparison: Free vs Pro columns
- Three purchase buttons: Pro Annual, Pro Monthly, Remove Ads only
- "Restore Purchase" text button at bottom
- Price fetched live from Play Store (use `queryProductDetails`)

### 13.3 premium_lock_widget.dart

```dart
// Overlay this on Pro screens when user is not Pro
class PremiumLockWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onUpgrade;

  const PremiumLockWidget({
    super.key, required this.child, required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isPro = StorageService.isPro;
    if (isPro) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Container(
            color: Colors.black54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                const Text('Pro Feature',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onUpgrade,
                  child: const Text('Unlock Pro'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

**Phase 9 complete when:** Purchase flow works end-to-end with a Play Store test account. Buying Pro removes ads and unlocks themes.

---

## 14. Phase 10 — Settings & Localization

### 14.1 settings_screen.dart sections

- **Language** — Dropdown: English / اردو / العربية
- **Calculation method** — Dropdown: Karachi, ISNA, MWL, Egypt, Tehran, Gulf
- **Madhab** — Toggle: Hanafi / Shafi
- **Notifications** — Link to `notification_settings_screen.dart`
- **Azaan sound** — Radio: Mecca / Egypt / Pakistan / Turkey / Short
- **Theme** — Link to `theme_picker_screen.dart`
- **Pro status** — "Upgrade to Pro" or "Pro Active" banner
- **Restore Purchase** — Text button
- **About** — Version, privacy policy link, rate app

### 14.2 Localization (minimum for launch)

Implement `app_strings.dart` with English and Urdu strings for:
- All prayer names (Fajr = فجر, Dhuhr = ظہر, Asr = عصر, Maghrib = مغرب, Isha = عشاء)
- Navigation labels
- Button labels
- Screen titles
- Notification text

Use `StorageService.language` to select the active language throughout the app.

### 14.3 notification_settings_screen.dart

Toggle per prayer (5 toggles), toggle for:
- Pre-prayer reminder (10 min before)
- Jumua reminder (Fridays only)
- Daily verse notification (morning)
- Islamic event notifications

On any toggle change → call `NotificationService.scheduleAllNotifications()`.

**Phase 10 complete when:** App fully works in English and Urdu. All settings persist across restarts.

---

## 15. Design Tokens

> **Instruction for Claude:** Use these exact values everywhere. Never hardcode colors inline.

### Spacing scale
```dart
class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
```

### Border radius
```dart
class Radius {
  static const sm = BorderRadius.all(Radius.circular(8));
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
  static const xl = BorderRadius.all(Radius.circular(24));
  static const full = BorderRadius.all(Radius.circular(999));
}
```

### Typography
```dart
class AppTextStyles {
  static TextStyle countdown(Color color) =>
    TextStyle(fontSize: 36, fontWeight: FontWeight.w500, color: color, letterSpacing: 2);

  static TextStyle prayerTime(Color color) =>
    TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color);

  static TextStyle prayerName(Color color) =>
    TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: color);

  static TextStyle arabicVerse(Color color) =>
    TextStyle(fontFamily: 'Hafs', fontSize: 26, color: color, height: 2.0);

  static TextStyle urduTranslation(Color color) =>
    TextStyle(fontFamily: 'NotoNastaliq', fontSize: 16, color: color, height: 1.8);

  static TextStyle englishTranslation(Color color) =>
    TextStyle(fontSize: 14, color: color, height: 1.6);
}
```

### App constants
```dart
class AppConstants {
  static const kaabaLat = 21.4225;
  static const kaabaLng = 39.8262;
  static const interstitialCooldownMinutes = 10;
  static const widgetUpdateIntervalSeconds = 60;
  static const tasbihDefaultGoal = 100;
  static const supportEmail = 'support@prayerapp.com';
  static const privacyPolicyUrl = 'https://yoursite.com/privacy';
  static const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.prayerapp.muslim';
}
```

---

## 16. Data Models

### prayer_model.dart
```dart
class PrayerModel {
  final String name;
  final DateTime time;
  final PrayerStatus status; // passed, next, upcoming
  final String iconAsset;

  const PrayerModel({
    required this.name,
    required this.time,
    required this.status,
    required this.iconAsset,
  });
}

enum PrayerStatus { passed, next, upcoming }
```

### surah_model.dart
```dart
class SurahModel {
  final int id;
  final String nameArabic;
  final String nameEnglish;
  final String? nameUrdu;
  final String? revelation;
  final int ayahCount;

  const SurahModel({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    this.nameUrdu,
    this.revelation,
    required this.ayahCount,
  });

  factory SurahModel.fromMap(Map<String, dynamic> map) => SurahModel(
    id: map['id'],
    nameArabic: map['name_arabic'],
    nameEnglish: map['name_english'],
    nameUrdu: map['name_urdu'],
    revelation: map['revelation'],
    ayahCount: map['ayah_count'],
  );
}
```

### verse_model.dart
```dart
class VerseModel {
  final int id;
  final int surahId;
  final int ayahNumber;
  final String textArabic;
  final String? textEnglish;
  final String? textUrdu;
  final int? juz;

  const VerseModel({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.textArabic,
    this.textEnglish,
    this.textUrdu,
    this.juz,
  });

  factory VerseModel.fromMap(Map<String, dynamic> map) => VerseModel(
    id: map['id'],
    surahId: map['surah_id'],
    ayahNumber: map['ayah_number'],
    textArabic: map['text_arabic'],
    textEnglish: map['text_english'],
    textUrdu: map['text_urdu'],
    juz: map['juz'],
  );
}
```

### user_settings_model.dart
```dart
class UserSettings {
  final String calculationMethod;
  final String madhab;
  final String language;
  final String theme;
  final bool isPro;
  final String azaanSound;
  final Map<String, bool> notificationToggles;

  const UserSettings({
    required this.calculationMethod,
    required this.madhab,
    required this.language,
    required this.theme,
    required this.isPro,
    required this.azaanSound,
    required this.notificationToggles,
  });
}
```

---

## 17. Key Business Rules

> **Instruction for Claude:** These rules are non-negotiable. Enforce them in code.

1. **Never show ads during Quran reading.** Check `ModalRoute` or screen context before loading any ad.

2. **Never show ads during active prayer time.** If current time is within 5 minutes of a prayer time, suppress interstitials.

3. **Pro gate enforcement:** Before showing any Pro screen (Qibla, Quran reader, themes), check `StorageService.isPro`. If false, show `PaywallScreen` instead.

4. **Notification rescheduling:** Every time the user changes calculation method, madhab, or location → call `NotificationService.scheduleAllNotifications()`.

5. **Widget update:** Call `WidgetService.updateWidget()` every time the app comes to foreground (use `WidgetsBindingObserver`) and after prayer times are loaded.

6. **Onboarding flow:** If `StorageService.onboardingDone == false`, the first screen shown must be `OnboardingScreen`, not `HomeScreen`.

7. **Offline first:** Prayer times must work without internet. All calculation is local via `adhan` package. Only feature requiring network is ad loading.

8. **Countdown accuracy:** The home screen countdown must update every second using `Timer.periodic`. Cancel the timer in `dispose()` to prevent memory leaks.

9. **Interstitial frequency cap:** Never show an interstitial more than once every 10 minutes. Store last shown timestamp in memory.

10. **Restore purchase:** Always call `PurchaseService.restorePurchases()` on app startup so returning users get their Pro status back.

---

## 18. Testing Checklist

Before asking for Play Store review, verify every item:

### Prayer times
- [ ] Fajr, Dhuhr, Asr, Maghrib, Isha times match islamicfinder.org for Lahore
- [ ] Changing calculation method updates times correctly
- [ ] Changing madhab (Hanafi vs Shafi) changes Asr time
- [ ] Countdown timer updates every second without freezing
- [ ] Prayer highlighting changes correctly at prayer time

### Notifications
- [ ] Azaan fires at correct time (test with a 2-minute offset)
- [ ] Disabling a prayer toggle cancels its notification
- [ ] Notifications reschedule after phone reboot
- [ ] Azaan sound plays correctly

### Widget
- [ ] Widget shows correct next prayer after app open
- [ ] Widget is visible in Android widget picker

### Quran
- [ ] All 114 surahs load correctly
- [ ] Arabic text displays with Hafs font
- [ ] RTL direction is correct
- [ ] Bookmarking works and persists

### Qibla
- [ ] Compass needle points toward Mecca (verify physically)
- [ ] "Facing Qibla" text shows at correct angle

### Monetization
- [ ] Banner ad shows on Home for free users
- [ ] Banner ad does NOT show for Pro users
- [ ] Pro purchase unlocks themes
- [ ] Restore purchase restores Pro status
- [ ] Interstitial shows max once per 10 minutes

### Themes
- [ ] All 8 themes apply correctly to every screen
- [ ] Pro themes show lock icon for free users
- [ ] Theme persists after app restart

### Settings
- [ ] All settings persist after restart
- [ ] Language switch changes all visible text
- [ ] Privacy policy link opens in browser

---

## Final Notes for Claude

- **Ask before assuming.** If a package API is unclear, check its documentation before guessing.
- **Production code only.** Every file must be complete — no TODOs left in submitted code.
- **Handle errors gracefully.** Every async call must have a try-catch. Never let the app crash.
- **Dispose everything.** Every `Timer`, `StreamSubscription`, and `AnimationController` must be disposed in `dispose()`.
- **Test as you go.** Run `flutter analyze` after each phase. Zero warnings allowed.
- **Asset files:** Audio and font files must be downloaded by the user and placed in the correct assets folders. Provide download links and exact filenames expected.

---

*This CLAUDE.md was generated to guide the full implementation of the Prayer Times & Quran Widget Flutter app. Feed this file to Claude Code at the start of each session.*
