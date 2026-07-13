# Prayer Times & Quran Widget — Flutter App

**Package ID:** `com.prayerapp.muslim` | **Platform:** Android (iOS later) | **Min SDK:** 21 | **Target SDK:** 34

## What this app does
A lightweight Islamic prayer time app that:
- Shows accurate prayer times based on GPS location
- Provides a home screen widget showing the next prayer + countdown
- Sends Azaan notification alerts at each prayer time
- Includes a full Quran reader (Arabic + Urdu + English)
- Shows a Hijri calendar with Islamic events
- Has a Qibla compass, Tasbih counter, and Qaza tracker
- Monetizes via AdMob ads (free users) and in-app purchase (Pro upgrade)

## Revenue model
- **Free tier:** AdMob banner + interstitial ads
- **Pro — one-time $1.99:** All premium themes (6 themes)
- **Pro — one-time $0.99:** Remove ads forever
- **Pro — annual $0.99/yr:** Full Pro (themes + no ads + all features)

### Play Console product IDs
| Product ID | Type | Price |
|---|---|---|
| `pro_themes_lifetime` | One-time (managed) | $1.99 |
| `remove_ads_lifetime` | One-time (managed) | $0.99 |
| `pro_annual` | Subscription | $0.99/year |
| `pro_monthly` | Subscription | $0.49/month |

---

## Key Business Rules

1. **Never show ads during Quran reading.**
2. **Never show ads during active prayer time.** Suppress interstitials within 5 minutes of any prayer time.
3. **Pro gate enforcement:** Before showing any Pro screen (Qibla, Quran reader, themes), check `StorageService.isPro`. If false, show `PaywallScreen`.
4. **Notification rescheduling:** On calculation method, madhab, or location change → call `NotificationService.scheduleAllNotifications()`.
5. **Widget update:** Call `WidgetService.updateWidget()` on foreground resume and after prayer times load.
6. **Onboarding flow:** If `StorageService.onboardingDone == false`, show `OnboardingScreen` first.
7. **Offline first:** All prayer time calculation is local via `adhan`. No network required except for ads.
8. **Countdown accuracy:** Home screen countdown updates every second via `Timer.periodic`. Cancel timer in `dispose()`.
9. **Interstitial frequency cap:** Max once per 10 minutes. Track last shown timestamp in memory.
10. **Restore purchase:** Call `PurchaseService.restorePurchases()` on app startup.

---

## Ad Placement Rules

| Location | Ad type | Condition |
|---|---|---|
| Home screen bottom | Banner | Free users only |
| Hijri Calendar bottom | Banner | Free users only |
| Tasbih screen bottom | Banner | Free users only |
| Opening Qibla screen | Interstitial | Free users, max 1 per 10 min |
| After saving bookmark | Interstitial | Free users, max 1 per session |

**Never show ads on:** Quran reader, active prayer countdown, Ramadan Sehri countdown, paywall screen.

---

## Design Tokens

### Spacing
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

### App Constants
```dart
class AppConstants {
  static const kaabaLat = 21.4225;
  static const kaabaLng = 39.8262;
  static const interstitialCooldownMinutes = 10;
  static const widgetUpdateIntervalSeconds = 60;
  static const tasbihDefaultGoal = 100;
  static const supportEmail = 'support@prayerapp.com';
}
```

---

## Themes (8 total)

| ID | Name | Free/Pro |
|---|---|---|
| `midnight` | Midnight | Free |
| `parchment` | Parchment | Free |
| `emerald` | Emerald | Pro |
| `violet` | Violet Night | Pro |
| `golden` | Golden | Pro |
| `maroon` | Maroon | Pro |
| `sky` | Sky | Pro |
| `pure_black` | Pure Black | Pro |

---

## Testing Checklist

### Prayer times
- [ ] Times match islamicfinder.org for Lahore
- [ ] Changing calculation method updates times
- [ ] Hanafi vs Shafi changes Asr time
- [ ] Countdown updates every second without freezing

### Notifications
- [ ] Azaan fires at correct time
- [ ] Disabling a prayer toggle cancels its notification
- [ ] Notifications reschedule after phone reboot

### Widget
- [ ] Shows correct next prayer after app open
- [ ] Visible in Android widget picker

### Quran
- [ ] All 114 surahs load correctly
- [ ] Arabic text displays with Hafs font (RTL)
- [ ] Bookmarking persists

### Monetization
- [ ] Banner ad shows on Home for free users, hidden for Pro
- [ ] Pro purchase unlocks themes and removes ads
- [ ] Restore purchase works
- [ ] Interstitial max once per 10 minutes

### Settings
- [ ] All settings persist after restart
- [ ] Language switch changes all visible text
