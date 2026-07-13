import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/prayer_model.dart';
import '../../../models/prayer_status.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';

class PrayerListTile extends StatelessWidget {
  final PrayerModel prayer;

  const PrayerListTile({super.key, required this.prayer});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    // Watch settings so tile rebuilds on language change
    context.watch<SettingsProvider>();
    final isNext = prayer.status == PrayerStatus.next;
    final isPassed = prayer.status == PrayerStatus.passed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isNext
            ? theme.accent.withAlpha(25)
            : theme.surface,
        borderRadius: AppRadius.md,
        border: isNext
            ? Border.all(color: theme.accent.withAlpha(100), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 2,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isPassed
                ? Colors.green.withAlpha(30)
                : isNext
                    ? theme.accent.withAlpha(40)
                    : theme.primary.withAlpha(60),
            borderRadius: AppRadius.sm,
          ),
          child: Icon(
            _prayerIcon(prayer.name),
            color: isPassed
                ? Colors.green
                : isNext
                    ? theme.accent
                    : theme.primary,
            size: 20,
          ),
        ),
        title: Text(
          AppStrings.get(prayer.name.toLowerCase()),
          style: TextStyle(
            color: isPassed ? theme.textSecondary : theme.textPrimary,
            fontSize: 15,
            fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppDateUtils.formatTime(prayer.time),
              style: TextStyle(
                color: isPassed
                    ? theme.textSecondary
                    : isNext
                        ? theme.accent
                        : theme.textPrimary,
                fontSize: 15,
                fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isPassed) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  IconData _prayerIcon(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return Icons.nights_stay_outlined;
      case 'dhuhr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.wb_cloudy_outlined;
      case 'maghrib':
        return Icons.wb_twilight_outlined;
      case 'isha':
        return Icons.nightlight_outlined;
      default:
        return Icons.access_time;
    }
  }
}
