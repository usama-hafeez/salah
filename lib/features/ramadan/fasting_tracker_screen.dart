import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/theme_provider.dart';

class FastingTrackerScreen extends StatefulWidget {
  const FastingTrackerScreen({super.key});

  @override
  State<FastingTrackerScreen> createState() => _FastingTrackerScreenState();
}

class _FastingTrackerScreenState extends State<FastingTrackerScreen> {
  late int _hijriYear;
  late List<bool> _fasted; // index 0 = Ramadan day 1

  @override
  void initState() {
    super.initState();
    final h = HijriCalendar.now();
    // If we're past Ramadan this year, still use current Hijri year
    _hijriYear = h.hYear;
    _fasted = List.generate(30, (i) {
      return StorageService.prefs.getBool(_key(i + 1)) ?? false;
    });
  }

  String _key(int day) => 'fast_${_hijriYear}_$day';

  Future<void> _toggle(int dayIndex) async {
    final newValue = !_fasted[dayIndex];
    await StorageService.prefs.setBool(_key(dayIndex + 1), newValue);
    setState(() => _fasted[dayIndex] = newValue);
  }

  int get _totalFasted => _fasted.where((v) => v).length;

  /// Find the Gregorian date of Ramadan day 1 for current Hijri year.
  DateTime _ramadanStart() {
    final h = HijriCalendar.now();
    if (h.hMonth == 9) {
      return DateTime.now()
          .subtract(Duration(days: h.hDay - 1))
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
    }
    // Scan forward to find next Ramadan
    DateTime d = DateTime.now();
    for (int i = 0; i < 380; i++) {
      final hd = HijriCalendar.fromDate(d);
      if (hd.hMonth == 9 && hd.hDay == 1) return d;
      d = d.add(const Duration(days: 1));
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    final ramadanStart = _ramadanStart();
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.primary,
        foregroundColor: theme.textPrimary,
        elevation: 0,
        title: Text('Fasting Tracker',
            style: TextStyle(color: theme.textPrimary)),
      ),
      body: Column(
        children: [
          // ── Summary header ────────────────────────────────────────────────
          Container(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(
                  label: 'Fasted',
                  value: '$_totalFasted',
                  theme: theme,
                ),
                Container(
                    width: 1, height: 40, color: Colors.white.withAlpha(60)),
                _Stat(
                  label: 'Remaining',
                  value: '${30 - _totalFasted}',
                  theme: theme,
                ),
                Container(
                    width: 1, height: 40, color: Colors.white.withAlpha(60)),
                _Stat(
                  label: 'Progress',
                  value: '${(_totalFasted / 30 * 100).round()}%',
                  theme: theme,
                ),
              ],
            ),
          ),

          // ── Progress bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _totalFasted / 30,
                minHeight: 6,
                backgroundColor: theme.surface,
                color: theme.accent,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ── Day list ──────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: 30,
              itemBuilder: (context, index) {
                final dayNum = index + 1;
                final gregDate =
                    ramadanStart.add(Duration(days: index));
                final isToday = gregDate.year == today.year &&
                    gregDate.month == today.month &&
                    gregDate.day == today.day;
                final isFuture = gregDate.isAfter(today);
                final fasted = _fasted[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isToday
                        ? theme.accent.withAlpha(20)
                        : theme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday
                        ? Border.all(
                            color: theme.accent.withAlpha(100), width: 1)
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 2),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: fasted
                            ? const Color(0xFF4CAF50).withAlpha(30)
                            : theme.primary.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          color: fasted
                              ? const Color(0xFF4CAF50)
                              : isToday
                                  ? theme.accent
                                  : theme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      AppDateUtils.shortDateString(gregDate),
                      style: TextStyle(
                        color: isFuture
                            ? theme.textSecondary
                            : theme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: isToday
                        ? Text('Today',
                            style: TextStyle(
                                color: theme.accent, fontSize: 11))
                        : null,
                    trailing: isFuture
                        ? Icon(Icons.lock_outline,
                            color: theme.textSecondary.withAlpha(80),
                            size: 18)
                        : Checkbox(
                            value: fasted,
                            activeColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            onChanged: (_) => _toggle(index),
                          ),
                    onTap: isFuture ? null : () => _toggle(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final AppThemeData theme;

  const _Stat({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(180),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
