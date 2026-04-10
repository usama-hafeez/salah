import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  // We display a Gregorian month, but show corresponding Hijri dates.
  late DateTime _displayMonth; // First day of the displayed Gregorian month
  final DateTime _today = DateTime.now();

  static const _islamicEvents = {
    '1-1': 'Islamic New Year',
    '1-10': 'Ashura',
    '3-12': 'Mawlid an-Nabi',
    '7-27': "Isra and Mi'raj",
    '8-15': 'Shab-e-Barat',
    '9-1': 'Ramadan Begins',
    '9-27': 'Laylat al-Qadr',
    '10-1': 'Eid al-Fitr',
    '12-10': 'Eid al-Adha',
  };

  @override
  void initState() {
    super.initState();
    _displayMonth = DateTime(_today.year, _today.month, 1);
  }

  void _prevMonth() => setState(() {
        _displayMonth =
            DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
      });

  void _nextMonth() => setState(() {
        _displayMonth =
            DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
      });

  int get _daysInMonth {
    final next = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    return next.difference(_displayMonth).inDays;
  }

  // Offset from Sunday for the first day of the month (0=Sun, 1=Mon, ...)
  int get _firstDayOffset => _displayMonth.weekday % 7;

  String? _eventForHijriDate(int month, int day) =>
      _islamicEvents['$month-$day'];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    // Collect events that occur in this Gregorian month
    final eventsThisMonth = <String>[];
    for (int d = 1; d <= _daysInMonth; d++) {
      final date = DateTime(_displayMonth.year, _displayMonth.month, d);
      final h = HijriCalendar.fromDate(date);
      final event = _eventForHijriDate(h.hMonth, h.hDay);
      if (event != null) eventsThisMonth.add('Day $d — $event');
    }

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Hijri Calendar',
            style: TextStyle(color: theme.textPrimary)),
        backgroundColor: theme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _MonthHeader(
              month: _displayMonth,
              theme: theme,
              onPrev: _prevMonth,
              onNext: _nextMonth,
            ),
            _WeekdayRow(theme: theme),
            _CalendarGrid(
              displayMonth: _displayMonth,
              daysInMonth: _daysInMonth,
              offsetDays: _firstDayOffset,
              today: _today,
              theme: theme,
              eventChecker: _eventForHijriDate,
            ),
            if (eventsThisMonth.isNotEmpty)
              _EventList(events: eventsThisMonth, theme: theme),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Month navigation header ─────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final AppThemeData theme;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  const _MonthHeader({
    required this.month,
    required this.theme,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // Get Hijri month for the 15th of the Gregorian month (middle of month)
    final midMonth = DateTime(month.year, month.month, 15);
    final h = HijriCalendar.fromDate(midMonth);
    final hijriMonthName = AppDateUtils.hijriMonthName(h.hMonth);

    return Container(
      color: theme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: theme.textPrimary),
            onPressed: onPrev,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_monthNames[month.month - 1]} ${month.year}',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '$hijriMonthName ${h.hYear} AH',
                  style: TextStyle(color: theme.accent, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: theme.textPrimary),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ── Day-of-week header ──────────────────────────────────────────────────────

class _WeekdayRow extends StatelessWidget {
  final AppThemeData theme;

  const _WeekdayRow({required this.theme});

  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.surface,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: _days
            .map((d) => Expanded(
                  child: Text(
                    d,
                    style: TextStyle(
                      color: d == 'Fri' ? theme.accent : theme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Calendar grid ───────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final DateTime displayMonth;
  final int daysInMonth;
  final int offsetDays;
  final DateTime today;
  final AppThemeData theme;
  final String? Function(int month, int day) eventChecker;

  const _CalendarGrid({
    required this.displayMonth,
    required this.daysInMonth,
    required this.offsetDays,
    required this.today,
    required this.theme,
    required this.eventChecker,
  });

  @override
  Widget build(BuildContext context) {
    final totalCells = offsetDays + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.75,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        final dayNum = index - offsetDays + 1;
        if (dayNum < 1 || dayNum > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date =
            DateTime(displayMonth.year, displayMonth.month, dayNum);
        final h = HijriCalendar.fromDate(date);
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final hasEvent = eventChecker(h.hMonth, h.hDay) != null;
        final isFriday = date.weekday == DateTime.friday;

        return _DayCell(
          gregDay: dayNum,
          hijriDay: h.hDay,
          isToday: isToday,
          hasEvent: hasEvent,
          isFriday: isFriday,
          theme: theme,
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  final int gregDay;
  final int hijriDay;
  final bool isToday;
  final bool hasEvent;
  final bool isFriday;
  final AppThemeData theme;

  const _DayCell({
    required this.gregDay,
    required this.hijriDay,
    required this.isToday,
    required this.hasEvent,
    required this.isFriday,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isToday
        ? Colors.black87
        : isFriday
            ? theme.accent
            : theme.textPrimary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: isToday
              ? BoxDecoration(
                  color: theme.accent,
                  shape: BoxShape.circle,
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$gregDay',
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight:
                      isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                '$hijriDay',
                style: TextStyle(
                  color: isToday
                      ? Colors.black54
                      : theme.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        if (hasEvent)
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          )
        else
          const SizedBox(height: 5),
      ],
    );
  }
}

// ── Islamic events list ─────────────────────────────────────────────────────

class _EventList extends StatelessWidget {
  final List<String> events;
  final AppThemeData theme;

  const _EventList({required this.events, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Islamic Events',
            style: TextStyle(
              color: theme.accent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...events.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
