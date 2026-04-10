import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
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

    await _plugin.initialize(settings: settings);

    // Request notification permission on Android 13+
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  /// Schedule Azaan notifications for today and tomorrow.
  /// Call this on app start and whenever settings change.
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
      id: id,
      title: prayerName,
      body: 'Time for $prayerName prayer',
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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
