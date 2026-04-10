import 'package:home_widget/home_widget.dart';
import 'package:adhan/adhan.dart';
import 'prayer_service.dart';
import 'location_service.dart';

class WidgetService {
  static const _androidWidgetName = 'PrayerWidgetProvider';
  static const _iOSWidgetName = 'PrayerWidget';

  /// Update home screen widget with next prayer data.
  /// Fails silently — widget update is non-critical.
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
    final hour = time.hour > 12
        ? time.hour - 12
        : time.hour == 0
            ? 12
            : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}
