extension StringExtensions on String {
  /// "fajr" → "Fajr"
  String get capitalizeFirst =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// "fajr_prayer" → "Fajr Prayer"
  String get toTitleCase => split(RegExp(r'[_\s]'))
      .map((w) => w.capitalizeFirst)
      .join(' ');
}

extension DateTimeExtensions on DateTime {
  /// True if this date is today (ignores time).
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// True if this date is strictly before the start of today.
  bool get isPast => isBefore(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ));

  /// Returns the date with time zeroed.
  DateTime get dateOnly => DateTime(year, month, day);
}

extension DurationExtensions on Duration {
  /// "HH:MM:SS"
  String get toHhMmSs {
    final h = inHours.toString().padLeft(2, '0');
    final m = (inMinutes % 60).toString().padLeft(2, '0');
    final s = (inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Compact: "2h 15m" or "45m"
  String get toHhMm {
    final h = inHours;
    final m = inMinutes % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }
}
