<<<<<<< HEAD
This application will be used for the fidning the prayer timings
=======
# Salah — Prayer Times & Quran Widget

A full-featured Islamic prayer app for Android built with Flutter.

## Features

- **Accurate Prayer Times** — Offline calculation via the `adhan` library using GPS or last known location. Supports 6 calculation methods (Karachi, ISNA, MWL, Egypt, Tehran, Gulf) and both Hanafi and Shafi madhabs.
- **Live Countdown** — Home screen shows a real-time countdown to the next prayer, updated every second.
- **Azaan Notifications** — Scheduled local notifications at each prayer time with 5 authentic Azaan audio choices.
- **Home Screen Widget** — Android widget showing next prayer name, time, and countdown.
- **Quran Reader** — Full 114-surah Quran with Arabic (Hafs font), English translation, and Urdu translation. Bookmarking supported.
- **Hijri Calendar** — Month view with Hijri dates overlaid on Gregorian calendar. Islamic events highlighted with green dots.
- **Ramadan Timetable** — 30-day Sehri/Iftar timetable with live countdown. Includes a fasting tracker.
- **Qibla Compass** — Real-time compass needle pointing toward the Kaabah.
- **Tasbih Counter** — Digital counter with haptic feedback and daily progress tracking.
- **Qaza Tracker** — Track missed prayers with per-prayer counters.
- **8 Themes** — 2 free (Midnight, Parchment) + 6 Pro (Emerald, Violet Night, Golden, Maroon, Sky, Pure Black).
- **Multilingual** — English, Urdu, and Arabic UI strings.
- **Monetization** — AdMob ads for free users; one-time and subscription Pro purchases to remove ads and unlock themes.

---

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter 3.x / Dart 3 |
| State management | Provider |
| Prayer calculation | adhan |
| Location | geolocator |
| Notifications | flutter_local_notifications + timezone |
| Home widget | home_widget |
| Quran database | sqflite (SQLite) |
| Ads | google_mobile_ads (AdMob) |
| Purchases | in_app_purchase |
| Qibla compass | flutter_compass |
| Hijri dates | hijri |
| Audio | just_audio |
| Haptics | vibration |
| SVG assets | flutter_svg |

---

## Project Structure

```
lib/
├── main.dart                        # App entry point, service initialisation
├── app.dart                         # MaterialApp, routes, providers
├── core/
│   ├── constants/                   # Colors (8 themes), strings (EN/UR/AR), assets, constants
│   ├── services/                    # Prayer, location, storage, notifications, ads, IAP, widget
│   └── utils/                       # Date helpers, prayer utils, extensions
├── models/                          # PrayerModel, VerseModel, SurahModel, etc.
├── providers/                       # Prayer, Quran, Settings, Theme, Purchase
├── features/
│   ├── onboarding/                  # Welcome + calculation method picker
│   ├── home/                        # Prayer times home screen + widgets
│   ├── calendar/                    # Hijri calendar
│   ├── quran/                       # Surah list, reader, bookmarks, verse of day
│   ├── qibla/                       # Compass screen
│   ├── tasbih/                      # Counter screen
│   ├── qaza/                        # Missed prayer tracker
│   ├── ramadan/                     # Timetable + fasting tracker
│   ├── settings/                    # Settings, notifications, theme picker
│   └── premium/                     # Paywall / Pro upgrade screen
└── shared/                          # Reusable widgets (AppBar, AdBanner, BottomNav, etc.)

assets/
├── audio/      # azaan_mecca.mp3, azaan_egypt.mp3, azaan_pakistan.mp3, azaan_turkey.mp3, azaan_short.mp3
├── fonts/      # Hafs.ttf, NotoNastaliqUrdu.ttf
├── images/     # SVG illustrations
├── icons/      # Prayer time SVG icons
├── db/         # quran.db (SQLite)
└── store/      # Play Store graphics
```

---

## Prerequisites

Before you can build and run the app, make sure the following are installed:

1. **Flutter SDK** (3.10 or later) — [flutter.dev/get-started](https://flutter.dev/get-started/install)
2. **Android Studio** or **VS Code** with the Flutter + Dart extensions
3. **Android SDK** (installed via Android Studio → SDK Manager)
   - Minimum SDK 21 (Android 5.0)
   - Target SDK 34
4. **Java 17** (bundled with Android Studio, or set `JAVA_HOME` manually)
5. **USB Debugging** enabled on your Android phone (see below)

Verify your setup:
```bash
flutter doctor
```
All items should show a green checkmark before proceeding.

---

## Required Assets (not in repository)

Place these files manually before building:

| File | Location | Notes |
|---|---|---|
| `Hafs.ttf` | `assets/fonts/Hafs.ttf` | Arabic Quran font (Uthmanic Hafs) |
| `NotoNastaliqUrdu.ttf` | `assets/fonts/NotoNastaliqUrdu.ttf` | Urdu font from Google Fonts |
| `quran.db` | `assets/db/quran.db` | Pre-built SQLite Quran database |
| `azaan_mecca.mp3` | `assets/audio/azaan_mecca.mp3` | |
| `azaan_egypt.mp3` | `assets/audio/azaan_egypt.mp3` | |
| `azaan_pakistan.mp3` | `assets/audio/azaan_pakistan.mp3` | |
| `azaan_turkey.mp3` | `assets/audio/azaan_turkey.mp3` | |
| `azaan_short.mp3` | `assets/audio/azaan_short.mp3` | Short ~30s tone |

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/usama-hafeez/salah.git
cd salah
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Generate app icons (optional, icons already committed)

```bash
python generate_icons.py   # Requires cairosvg: pip install cairosvg
flutter pub run flutter_launcher_icons
```

### 4. Run on a connected device

```bash
flutter run
```

For a release build (faster, no debug overhead):
```bash
flutter run --release
```

---

## Building for Release (APK / AAB)

### Debug APK (for testing)

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (for sideloading)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (for Play Store)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

> **Note:** For a signed release build (required for Play Store), you must create a keystore and configure `android/key.properties`. See [flutter.dev/deployment/android](https://docs.flutter.dev/deployment/android).

---

## Before Play Store Release

Replace all test IDs with real ones:

1. **AdMob App ID** — `android/app/src/main/AndroidManifest.xml`
   ```xml
   android:value="YOUR_REAL_ADMOB_APP_ID"
   ```

2. **Banner + Interstitial ad unit IDs** — `lib/core/services/ad_service.dart`
   ```dart
   static const _bannerAdUnitId = 'YOUR_REAL_BANNER_ID';
   static const _interstitialAdUnitId = 'YOUR_REAL_INTERSTITIAL_ID';
   ```

3. **In-app purchase product IDs** — must match exactly what you create in Play Console:
   - `pro_themes_lifetime` — $1.99 one-time
   - `remove_ads_lifetime` — $0.99 one-time
   - `pro_annual` — $0.99/year subscription
   - `pro_monthly` — $0.49/month subscription

4. **Support email + privacy policy URL** — `lib/core/constants/app_constants.dart`

---

## Environment Notes

- This project is developed on **Windows with WSL2**. Flutter commands work in both WSL and Windows terminal, but `git push` to GitHub requires running from **Windows terminal / Git Bash** (WSL lacks access to Windows Credential Manager).
- The `flutter` command in WSL must point to the Windows Flutter SDK, or a native Linux Flutter installation must be present.

---

## License

Private — all rights reserved. Not for redistribution.
>>>>>>> fix/app-icons-splash-images
