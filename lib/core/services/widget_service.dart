import 'package:home_widget/home_widget.dart';
import 'package:adhan/adhan.dart';
import 'prayer_service.dart';
import 'location_service.dart';

class WidgetService {
  // Must match the class name registered in AndroidManifest.xml
  static const _androidWidgetName = 'PrayerWidgetProvider';
  static const _iOSWidgetName = 'PrayerWidget';

  /// Update home screen widget with next prayer data.
  /// Fails silently — widget update is non-critical.
  static Future<void> updateWidget() async {
    try {
      final position = await LocationService.getCurrentPosition();
      final times = PrayerService.getPrayerTimes(position);

      var next = times.nextPrayer();
      DateTime? nextTime = times.timeForPrayer(next);

      // After Isha, nextPrayer() returns none — roll over to tomorrow's Fajr
      // so the widget never shows stale data through the night.
      if (next == Prayer.none || nextTime == null) {
        final tomorrow = PrayerService.getPrayerTimesForDate(
          position,
          DateTime.now().add(const Duration(days: 1)),
        );
        next = Prayer.fajr;
        nextTime = tomorrow.fajr;
      }

      final countdown = nextTime.difference(DateTime.now());
      final hours = countdown.inHours;
      final minutes = countdown.inMinutes % 60;

      await HomeWidget.saveWidgetData<String>(
          'next_prayer', _prayerName(next));
      await HomeWidget.saveWidgetData<String>(
          'countdown', '${hours.toString().padLeft(2, '0')}h '
          '${minutes.toString().padLeft(2, '0')}m');
      await HomeWidget.saveWidgetData<String>(
          'prayer_time', _formatTime(nextTime));

      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );
    } catch (_) {
      // Intentional: widget update must never crash the app
    }
  }

  static String _prayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return 'Prayer';
    }
  }

  static String _formatTime(DateTime time) {
    // adhan returns UTC instants — format in device local time.
    final local = time.toLocal();
    final hour = local.hour > 12
        ? local.hour - 12
        : local.hour == 0
            ? 12
            : local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}
