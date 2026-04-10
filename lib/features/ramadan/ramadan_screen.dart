import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/theme_provider.dart';

class RamadanScreen extends StatefulWidget {
  const RamadanScreen({super.key});

  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen> {
  Timer? _timer;
  String _countdown = '--:--:--';
  String _countdownLabel = '';
  bool _loading = true;
  List<_RamadanDay> _timetable = [];
  int _daysRemaining = 0;
  bool _isInRamadan = false;
  int _ramadanHijriYear = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    Position? pos;
    try {
      pos = await LocationService.getCurrentPosition();
    } catch (_) {}

    final effectivePos = pos ?? _fallbackPosition();
    final hToday = HijriCalendar.now();
    _isInRamadan = hToday.hMonth == 9;
    _ramadanHijriYear = hToday.hYear;

    // Find Ramadan 1 in Gregorian
    final DateTime ramadanStart = _findRamadanStart(hToday);

    // Days remaining (only meaningful when in Ramadan)
    if (_isInRamadan) {
      _daysRemaining = 30 - hToday.hDay + 1;
    }

    // Build 30-day timetable
    _timetable = List.generate(30, (i) {
      final date = ramadanStart.add(Duration(days: i));
      try {
        final times = PrayerService.getPrayerTimesForDate(effectivePos, date);
        return _RamadanDay(
          gregDate: date,
          hijriDay: i + 1,
          sehri: times.fajr,
          iftar: times.maghrib,
        );
      } catch (_) {
        return _RamadanDay(
            gregDate: date, hijriDay: i + 1, sehri: null, iftar: null);
      }
    });

    if (mounted) {
      setState(() => _loading = false);
      _updateCountdown();
      _timer = Timer.periodic(
          const Duration(seconds: 1), (_) => _updateCountdown());
    }
  }

  DateTime _findRamadanStart(HijriCalendar hToday) {
    // If currently in Ramadan, back-calculate to day 1
    if (hToday.hMonth == 9) {
      return DateTime.now()
          .subtract(Duration(days: hToday.hDay - 1))
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    }

    // Otherwise, scan forward from today to find next Ramadan 1
    DateTime d = DateTime.now();
    for (int i = 0; i < 380; i++) {
      final h = HijriCalendar.fromDate(d);
      if (h.hMonth == 9 && h.hDay == 1) return d;
      d = d.add(const Duration(days: 1));
    }
    return DateTime.now(); // should never happen
  }

  Position _fallbackPosition() {
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

  void _updateCountdown() {
    if (_timetable.isEmpty) return;
    final now = DateTime.now();

    // Find today's and tomorrow's timetable entries
    _RamadanDay? todayEntry;
    _RamadanDay? tomorrowEntry;
    for (int i = 0; i < _timetable.length; i++) {
      final d = _timetable[i];
      if (_isSameDay(d.gregDate, now)) {
        todayEntry = d;
        if (i + 1 < _timetable.length) tomorrowEntry = _timetable[i + 1];
        break;
      }
    }

    if (todayEntry == null) {
      if (mounted) {
        setState(() {
          _countdown = '--:--:--';
          _countdownLabel = '';
        });
      }
      return;
    }

    Duration? diff;
    String label = '';
    final sehri = todayEntry.sehri;
    final iftar = todayEntry.iftar;

    if (sehri != null && now.isBefore(sehri)) {
      diff = sehri.difference(now);
      label = 'Until Sehri ends (Fajr)';
    } else if (iftar != null && now.isBefore(iftar)) {
      diff = iftar.difference(now);
      label = 'Until Iftar (Maghrib)';
    } else if (tomorrowEntry?.sehri != null) {
      diff = tomorrowEntry!.sehri!.difference(now);
      label = 'Until Sehri ends (Fajr)';
    }

    if (diff != null && diff.isNegative) diff = null;

    if (mounted) {
      setState(() {
        _countdownLabel = label;
        _countdown = diff != null
            ? AppDateUtils.formatCountdown(diff)
            : '--:--:--';
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    final now = DateTime.now();

    _RamadanDay? todayEntry;
    for (final d in _timetable) {
      if (_isSameDay(d.gregDate, now)) {
        todayEntry = d;
        break;
      }
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Ramadan', style: TextStyle(color: theme.textPrimary)),
        backgroundColor: theme.primary,
        elevation: 0,
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                  color: theme.accent, strokeWidth: 2))
          : ListView(
              children: [
                _RamadanHeader(
                  theme: theme,
                  isInRamadan: _isInRamadan,
                  daysRemaining: _daysRemaining,
                  hijriYear: _ramadanHijriYear,
                ),
                _CountdownCard(
                  theme: theme,
                  countdown: _countdown,
                  label: _countdownLabel,
                ),
                if (todayEntry != null)
                  _TodayCard(theme: theme, day: todayEntry),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    '30-Day Ramadan Timetable',
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                ..._timetable.map((d) => _TimetableRow(
                      day: d,
                      theme: theme,
                      isToday: _isSameDay(d.gregDate, now),
                    )),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

// ── Data model ──────────────────────────────────────────────────────────────

class _RamadanDay {
  final DateTime gregDate;
  final int hijriDay;
  final DateTime? sehri;
  final DateTime? iftar;

  const _RamadanDay({
    required this.gregDate,
    required this.hijriDay,
    required this.sehri,
    required this.iftar,
  });
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _RamadanHeader extends StatelessWidget {
  final AppThemeData theme;
  final bool isInRamadan;
  final int daysRemaining;
  final int hijriYear;

  const _RamadanHeader({
    required this.theme,
    required this.isInRamadan,
    required this.daysRemaining,
    required this.hijriYear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primary, theme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'رَمَضَان',
            style: TextStyle(
              fontFamily: 'Hafs',
              color: Colors.white,
              fontSize: 28,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 6),
          Text(
            'Ramadan $hijriYear AH',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isInRamadan
                ? '$daysRemaining days remaining'
                : 'Not in Ramadan — showing next Ramadan timetable',
            style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final AppThemeData theme;
  final String countdown;
  final String label;

  const _CountdownCard({
    required this.theme,
    required this.countdown,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label.isEmpty ? 'Countdown' : label,
            style: TextStyle(color: theme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            countdown,
            style: TextStyle(
              color: theme.accent,
              fontSize: 42,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final AppThemeData theme;
  final _RamadanDay day;

  const _TodayCard({required this.theme, required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Icon(Icons.wb_twilight_outlined,
                    color: theme.accent, size: 22),
                const SizedBox(height: 4),
                Text('Sehri ends at',
                    style:
                        TextStyle(color: theme.textSecondary, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  day.sehri != null
                      ? AppDateUtils.formatTime(day.sehri!)
                      : '--:--',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
              height: 50,
              width: 1,
              color: theme.textSecondary.withAlpha(50)),
          Expanded(
            child: Column(
              children: [
                Icon(Icons.wb_sunny_outlined, color: theme.accent, size: 22),
                const SizedBox(height: 4),
                Text('Iftar at',
                    style:
                        TextStyle(color: theme.textSecondary, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  day.iftar != null
                      ? AppDateUtils.formatTime(day.iftar!)
                      : '--:--',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimetableRow extends StatelessWidget {
  final _RamadanDay day;
  final AppThemeData theme;
  final bool isToday;

  static const _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  const _TimetableRow({
    required this.day,
    required this.theme,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdays[day.gregDate.weekday - 1];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isToday
            ? theme.accent.withAlpha(25)
            : theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: theme.accent.withAlpha(100), width: 1)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${day.hijriDay}',
                  style: TextStyle(
                    color: isToday ? theme.accent : theme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weekday,
                  style:
                      TextStyle(color: theme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Icon(Icons.water_drop_outlined,
                    size: 13, color: theme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  day.sehri != null
                      ? AppDateUtils.formatTime(day.sehri!)
                      : '--:--',
                  style:
                      TextStyle(color: theme.textPrimary, fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined,
                  size: 13, color: theme.textSecondary),
              const SizedBox(width: 4),
              Text(
                day.iftar != null
                    ? AppDateUtils.formatTime(day.iftar!)
                    : '--:--',
                style:
                    TextStyle(color: theme.textPrimary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
