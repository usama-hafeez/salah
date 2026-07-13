import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'prayer_service.dart';
import 'location_service.dart';
import 'storage_service.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _tzChannel = MethodChannel('com.prayerapp.muslim/timezone');

  static Future<void> init() async {
    tz.initializeTimeZones();

    // Get device IANA timezone directly from Android via MethodChannel
    try {
      final timeZoneName =
          await _tzChannel.invokeMethod<String>('getLocalTimezone') ?? 'UTC';
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    // White silhouette status-bar icon (not the full-color launcher, which
    // would render as a solid white square on Android 5+).
    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_stat_azaan');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: settings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Request POST_NOTIFICATIONS permission (Android 13+)
    await androidPlugin?.requestNotificationsPermission();

    // Request exact alarm permission (Android 12+) — needed for on-time Azaan
    await androidPlugin?.requestExactAlarmsPermission();
  }

  /// Schedule Azaan notifications for today and tomorrow.
  /// Call this on app start and whenever prayer settings change.
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
    final now = DateTime.now();

    for (final day in allDays) {
      final times = PrayerService.obligatoryPrayers(day);
      for (final entry in times.entries) {
        final prayerName = entry.key;
        final prayerTime = entry.value;

        if (prayerTime == null) continue;
        if (prayerTime.isBefore(now)) continue;

        // Azaan notification
        if (StorageService.notificationEnabled(prayerName)) {
          await _scheduleAzaan(
            id: notifId++,
            prayerName: prayerName,
            scheduledTime: prayerTime,
          );
        }

        // Pre-prayer reminder (10 min before)
        if (StorageService.prePrayerReminder) {
          final reminderTime =
              prayerTime.subtract(const Duration(minutes: 10));
          if (reminderTime.isAfter(now)) {
            await _scheduleReminder(
              id: notifId++,
              title: '$prayerName in 10 minutes',
              body: 'Time to prepare for $prayerName prayer',
              scheduledTime: reminderTime,
            );
          }
        }

        // Jumu'a reminder — fire at Dhuhr time on Fridays
        if (StorageService.jumuaReminder &&
            prayerName == 'Dhuhr' &&
            prayerTime.weekday == DateTime.friday) {
          await _scheduleReminder(
            id: notifId++,
            title: "Jumu'a Prayer",
            body: "Don't forget Jumu'a prayer today",
            scheduledTime:
                prayerTime.subtract(const Duration(minutes: 30)),
          );
        }
      }
    }

    // Daily verse notification at 8:00 AM
    if (StorageService.dailyVerseNotification) {
      final today8am = DateTime(now.year, now.month, now.day, 8, 0);
      final tomorrow8am = today8am.add(const Duration(days: 1));
      final verseTime = today8am.isAfter(now) ? today8am : tomorrow8am;
      await _scheduleReminder(
        id: notifId++,
        title: 'Verse of the Day',
        body: 'Open the app to read today\'s verse',
        scheduledTime: verseTime,
        channelId: 'verse_channel',
        channelName: 'Verse of the Day',
      );
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
      icon: '@drawable/ic_stat_azaan',
      sound: RawResourceAndroidNotificationSound(soundFile),
      playSound: true,
      enableVibration: true,
    );

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final details = NotificationDetails(android: androidDetails);

    // Try exact scheduling first; fall back to inexact if permission denied
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: prayerName,
        body: 'Time for $prayerName prayer',
        scheduledDate: tzTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id: id,
        title: prayerName,
        body: 'Time for $prayerName prayer',
        scheduledDate: tzTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    }
  }

  static Future<void> _scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String channelId = 'reminder_channel',
    String channelName = 'Prayer Reminders',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Prayer reminders and alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_stat_azaan',
      enableVibration: true,
    );

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final details = NotificationDetails(android: androidDetails);

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    }
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
