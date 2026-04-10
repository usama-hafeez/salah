import 'package:hijri/hijri_calendar.dart';

class AppDateUtils {
  /// Returns current Hijri date as formatted string, e.g. "12 Rajab 1446".
  static String hijriDateString() {
    final h = HijriCalendar.now();
    return '${h.hDay} ${_hijriMonthName(h.hMonth)} ${h.hYear}';
  }

  /// Returns Gregorian date as formatted string, e.g. "Thursday, April 10".
  static String gregorianDateString([DateTime? date]) {
    final d = date ?? DateTime.now();
    return '${_dayName(d.weekday)}, ${_monthName(d.month)} ${d.day}';
  }

  static String _hijriMonthName(int month) {
    const names = [
      '',
      'Muharram',
      'Safar',
      "Rabi' al-Awwal",
      "Rabi' al-Thani",
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      "Sha'ban",
      'Ramadan',
      'Shawwal',
      "Dhul Qi'dah",
      'Dhul Hijjah',
    ];
    return (month >= 1 && month <= 12) ? names[month] : '';
  }

  static String _monthName(int month) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month];
  }

  static String _dayName(int weekday) {
    const names = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday];
  }

  /// Formats DateTime as "h:mm AM/PM".
  static String formatTime(DateTime time) {
    final rawHour = time.hour;
    final hour = rawHour == 0 ? 12 : (rawHour > 12 ? rawHour - 12 : rawHour);
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = rawHour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  /// Formats a Duration as "HH:MM:SS".
  static String formatCountdown(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
